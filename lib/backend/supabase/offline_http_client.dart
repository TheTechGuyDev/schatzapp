import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '/custom_code/actions/init_offline_store.dart'
    show OfflineStore, ConnectivityMonitor;

/// HTTP client for Supabase that makes every database READ work offline,
/// WhatsApp-style:
///
/// - Successful reads (REST GET, plus a few read-only RPCs) are saved per
///   signed-in user.
/// - With no connection, the last saved answer is returned at once, so pages
///   show the last chat list, threads, stories, wallet etc. with no spinner.
/// - Online, data is always fetched fresh (and the cache updated).
/// - Writes (insert/update/delete, payment/PIN/other RPCs) are never cached
///   or replayed.
class OfflineHttpClient extends http.BaseClient {
  OfflineHttpClient([http.Client? inner]) : _inner = inner ?? http.Client();

  final http.Client _inner;

  static const _boxName = 'schatz_http_cache';
  static const _maxEntries = 800;
  static const _maxBodyBytes = 1536 * 1024; // 1.5 MB per answer
  static Box<String>? _box;
  static Future<void>? _opening;

  /// Read-only RPCs that are safe to answer from cache.
  static const Set<String> _cacheableRpcs = {
    'block_status',
    'blocked_peers',
    'pending_request_peers',
    'pcl_locked_peers',
    'get_user_links',
    'get_party_identity',
  };

  static Future<void> init() => _opening ??= _open();

  static Future<void> _open() async {
    try {
      await OfflineStore.init(); // sets up Hive's folder
      _box = await Hive.openBox<String>(_boxName);
    } catch (e) {
      debugPrint('OfflineHttpClient init failed: $e');
      _opening = null;
    }
  }

  /// Removes every cached answer (e.g. on sign out).
  static Future<void> clear() async {
    try {
      await _box?.clear();
    } catch (_) {}
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final rpcName = _rpcName(request);
    final isRead = request.method == 'GET' &&
        request.url.path.contains('/rest/v1/');
    final isCacheableRpc =
        request.method == 'POST' && rpcName != null && _cacheableRpcs.contains(rpcName);

    if (!isRead && !isCacheableRpc) {
      try {
        return await _inner.send(request);
      } catch (e) {
        if (_isNetworkError(e)) ConnectivityMonitor.reportFailure();
        rethrow;
      }
    }

    // Body is needed for the cache key of RPCs; re-create the request.
    String body = '';
    http.BaseRequest outgoing = request;
    if (request is http.Request) {
      body = request.body;
      outgoing = _copy(request);
    }

    final key = _key(request, body);
    if (_box == null) await init();

    // Known offline: answer from cache immediately, no waiting.
    if (!ConnectivityMonitor.online.value) {
      final cached = _read(key, request);
      if (cached != null) return cached;
    }

    final cached = _read(key, request);

    // Network fetch that also refreshes the cache.
    final net = _inner.send(outgoing).then((res) async {
      final bytes = await res.stream.toBytes();
      if (res.statusCode >= 200 &&
          res.statusCode < 300 &&
          bytes.length <= _maxBodyBytes) {
        _write(key, res.statusCode, res.headers, bytes);
      }
      return http.StreamedResponse(
        Stream.value(bytes),
        res.statusCode,
        contentLength: bytes.length,
        request: request,
        headers: res.headers,
        reasonPhrase: res.reasonPhrase,
        isRedirect: res.isRedirect,
        persistentConnection: res.persistentConnection,
      );
    });

    try {
      // With a saved answer, never make the user wait long (e.g. Wi-Fi with
      // no internet): after 4s show the saved answer; the fetch keeps
      // going in the background and updates the cache for next time.
      return await net.timeout(Duration(seconds: cached != null ? 4 : 20));
    } catch (e) {
      net.ignore();
      if (_isNetworkError(e)) ConnectivityMonitor.reportFailure();
      if (cached != null) return cached;
      rethrow;
    }
  }

  // ---------------------------------------------------------------- helpers

  static String? _rpcName(http.BaseRequest r) {
    final segs = r.url.pathSegments;
    final i = segs.indexOf('rpc');
    if (i < 0 || i + 1 >= segs.length) return null;
    if (!r.url.path.contains('/rest/v1/rpc/')) return null;
    return segs[i + 1];
  }

  static http.Request _copy(http.Request r) {
    final c = http.Request(r.method, r.url)
      ..headers.addAll(r.headers)
      ..followRedirects = r.followRedirects
      ..maxRedirects = r.maxRedirects
      ..persistentConnection = r.persistentConnection;
    if (r.bodyBytes.isNotEmpty) c.bodyBytes = r.bodyBytes;
    return c;
  }

  static bool _isNetworkError(Object e) {
    if (e is TimeoutException) return true;
    if (e is http.ClientException) return true;
    final s = e.toString();
    return s.contains('SocketException') ||
        s.contains('Failed host lookup') ||
        s.contains('Connection') ||
        s.contains('XMLHttpRequest');
  }

  /// Signed-in user id from the request's JWT, so one user never sees
  /// another user's cached data.
  static String _uid(http.BaseRequest r) {
    final auth = r.headers['Authorization'] ?? r.headers['authorization'];
    if (auth == null || !auth.startsWith('Bearer ')) return 'anon';
    try {
      final parts = auth.substring(7).split('.');
      if (parts.length < 2) return 'anon';
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final sub = (jsonDecode(payload) as Map)['sub'];
      return sub is String && sub.isNotEmpty ? sub : 'anon';
    } catch (_) {
      return 'anon';
    }
  }

  // Timestamps in filters (e.g. "expires_at > now") change every call;
  // treat them as one query shape so the last answer is reused offline.
  static final RegExp _ts = RegExp(
      r'\d{4}-\d{2}-\d{2}(T|%20| )\d{2}(:|%3A)\d{2}(:|%3A)\d{2}[0-9.]*(Z|%2B\d{2}(:|%3A)?\d{2}|\+\d{2}:?\d{2})?');

  static String _key(http.BaseRequest r, String body) {
    String h(String name) =>
        r.headers[name] ?? r.headers[name.toLowerCase()] ?? '';
    final url = r.url.toString().replaceAll(_ts, 'TS');
    return [
      _uid(r),
      r.method,
      url,
      h('Accept'),
      h('Range'),
      h('Prefer'),
      body.replaceAll(_ts, 'TS'),
    ].join('|');
  }

  static void _write(
      String key, int status, Map<String, String> headers, List<int> bytes) {
    final box = _box;
    if (box == null) return;
    final keep = <String, String>{};
    for (final k in ['content-type', 'content-range', 'preference-applied']) {
      final v = headers[k];
      if (v != null) keep[k] = v;
    }
    final entry = jsonEncode({
      's': status,
      'h': keep,
      'b': base64Encode(bytes),
      't': DateTime.now().millisecondsSinceEpoch,
    });
    final id = _hash(key);
    // Delete + put moves the key to the end, so the oldest are first.
    box.delete(id).then((_) => box.put(id, entry)).then((_) {
      if (box.length > _maxEntries) {
        final extra = box.length - _maxEntries;
        box.deleteAll(box.keys.take(extra).toList());
      }
    }).catchError((_) {});
  }

  static http.StreamedResponse? _read(String key, http.BaseRequest request) {
    final raw = _box?.get(_hash(key));
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final bytes = base64Decode(m['b'] as String);
      final headers = Map<String, String>.from(m['h'] as Map);
      return http.StreamedResponse(
        Stream.value(bytes),
        (m['s'] as int?) ?? 200,
        contentLength: bytes.length,
        request: request,
        headers: headers,
      );
    } catch (_) {
      return null;
    }
  }

  /// Hive keys are limited to 255 chars, so long URLs are hashed (FNV-1a 64).
  static String _hash(String s) {
    var h1 = 0x811c9dc5;
    var h2 = 0x01000193;
    for (final c in utf8.encode(s)) {
      h1 = ((h1 ^ c) * 0x01000193) & 0xFFFFFFFF;
      h2 = ((h2 ^ c) * 0x811c9dc5 + 7) & 0xFFFFFFFF;
    }
    return 'q_${h1.toRadixString(16)}${h2.toRadixString(16)}_${s.length}';
  }

  @override
  void close() => _inner.close();
}
