// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future initOfflineStore() async {
  await OfflineStore.init();
  OutboxSync.hook();
  ConnectivityMonitor.start();
}

/// Local cache shared by every page. Safe to call init() many times.
class OfflineStore {
  static bool _ready = false;
  static Box<String>? _box;
  static Future<void>? _initFuture;

  static Future<void> init() {
    return _initFuture ??= _doInit();
  }

  static Future<void> _doInit() async {
    try {
      if (!kIsWeb) {
        final dir = await getApplicationDocumentsDirectory();
        Hive.init(dir.path);
      }
      _box = await Hive.openBox<String>('schatz_offline_store');
      _ready = true;
    } catch (e) {
      debugPrint('OfflineStore init failed: $e');
      _initFuture = null;
    }
  }

  static bool get ready => _ready;

  static Future<void> putJson(String key, Object value) async {
    if (!_ready) return;
    try {
      await _box!.put(key, jsonEncode(value));
    } catch (e) {
      debugPrint('OfflineStore.putJson($key) failed: $e');
    }
  }

  static dynamic getJson(String key) {
    if (!_ready) return null;
    try {
      final raw = _box!.get(key);
      if (raw == null) return null;
      return jsonDecode(raw);
    } catch (e) {
      debugPrint('OfflineStore.getJson($key) failed: $e');
      return null;
    }
  }

  static List<Map<String, dynamic>> getList(String key) {
    final v = getJson(key);
    if (v is! List) return [];
    return v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Map<String, dynamic>? getMap(String key) {
    final v = getJson(key);
    return v is Map ? Map<String, dynamic>.from(v) : null;
  }

  static Future<void> remove(String key) async {
    if (!_ready) return;
    await _box!.delete(key);
  }

  /// Call on logout so the next person never sees cached data.
  static Future<void> clearAll() async {
    if (!_ready) return;
    await _box!.clear();
  }

  // ---- Messages (newest 300 per conversation) ----
  static const int maxMessagesPerChat = 300;

  static Future<void> putMessages(
      String conversationId, List<Map<String, dynamic>> rows) async {
    final trimmed = rows.length > maxMessagesPerChat
        ? rows.sublist(rows.length - maxMessagesPerChat)
        : rows;
    await putJson('msgs:$conversationId', trimmed);
  }

  static List<Map<String, dynamic>> getMessages(String conversationId) =>
      getList('msgs:$conversationId');

  // ---- Outbox (messages written while offline) ----
  static const String _outboxKey = 'outbox';

  /// Bumps whenever the outbox changes so chat screens can refresh.
  static final ValueNotifier<int> outboxChanged = ValueNotifier<int>(0);

  static List<Map<String, dynamic>> outbox([String? conversationId]) {
    final all = getList(_outboxKey);
    if (conversationId == null) return all;
    return all.where((e) => e['conversation_id'] == conversationId).toList();
  }

  /// status: pending | sending | failed
  static Future<String> enqueue(Map<String, dynamic> item,
      {String? localId}) async {
    final id = localId ?? 'local_${DateTime.now().microsecondsSinceEpoch}';
    final all = outbox();
    all.add({
      ...item,
      'local_id': id,
      'status': 'pending',
      'queued_at': DateTime.now().toUtc().toIso8601String(),
    });
    await putJson(_outboxKey, all);
    outboxChanged.value++;
    return id;
  }

  static Future<void> updateOutbox(
      String localId, Map<String, dynamic> patch) async {
    final all = outbox();
    for (final e in all) {
      if (e['local_id'] == localId) e.addAll(patch);
    }
    await putJson(_outboxKey, all);
    outboxChanged.value++;
  }

  static Future<void> removeOutbox(String localId) async {
    final all = outbox()..removeWhere((e) => e['local_id'] == localId);
    await putJson(_outboxKey, all);
    outboxChanged.value++;
  }
}

/// Real reachability check against Supabase (not just "wifi is on").
class ConnectivityMonitor {
  static final ValueNotifier<bool> online = ValueNotifier<bool>(true);
  static bool _started = false;
  static Timer? _timer;
  static bool _checking = false;

  static void start() {
    if (_started) return;
    _started = true;
    OutboxSync.hook();
    WidgetsBinding.instance.addObserver(_LifecycleHook());
    check();
  }

  static Future<void> check() async {
    if (_checking) return;
    _checking = true;
    bool ok = false;
    try {
      final base = SupaFlow.client.rest.url;
      // Any HTTP answer (even 401) means the server is reachable.
      await http.get(Uri.parse(base)).timeout(const Duration(seconds: 4));
      ok = true;
    } catch (_) {
      ok = false;
    }
    _checking = false;
    if (online.value != ok) online.value = ok;
    if (ok && OfflineStore.ready && OfflineStore.outbox().isNotEmpty) {
      OutboxSync.flush();
    }
    _timer?.cancel();
    _timer = Timer(Duration(seconds: ok ? 10 : 3), check);
  }

  /// Call after a failed network request to flip to offline quickly.
  static void reportFailure() {
    check();
  }
}

class _LifecycleHook with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ConnectivityMonitor.check();
  }
}

/// Sends messages written while offline, in order, once the server is back.
class OutboxSync {
  static bool _flushing = false;
  static bool _hooked = false;

  static void hook() {
    if (_hooked) return;
    _hooked = true;
    ConnectivityMonitor.online.addListener(() {
      if (ConnectivityMonitor.online.value) flush();
    });
  }

  static bool isNetworkError(Object e) {
    final t = e.toString();
    return e is TimeoutException ||
        t.contains('SocketException') ||
        t.contains('ClientException') ||
        t.contains('Failed host lookup') ||
        t.contains('XMLHttpRequest') ||
        t.contains('Connection closed') ||
        t.contains('Connection reset') ||
        t.contains('Network is unreachable');
  }

  static bool _isDuplicate(Object e) {
    final t = e.toString();
    return t.contains('23505') || t.contains('duplicate key');
  }

  static Future<void> _insert(Map<String, dynamic> item) async {
    final payload = <String, dynamic>{
      'conversation_id': item['conversation_id'],
      'sender_id': item['sender_id'],
      'message_type': item['message_type'] ?? 'text',
      'content': item['content'],
      'client_id': item['local_id'],
      'created_at': item['queued_at'],
    };
    for (final k in const [
      'reply_to_message_id',
      'reply_to_content',
      'reply_to_is_own',
      'media_url',
    ]) {
      final v = item[k];
      if (v != null && v != '') payload[k] = v;
    }
    await SupaFlow.client
        .from('messages')
        .insert(payload)
        .timeout(const Duration(seconds: 15));
  }

  /// Sends now when online, otherwise saves to the outbox.
  /// Returns true when the message reached the server right away.
  static Future<bool> sendOrQueue(Map<String, dynamic> message) async {
    await OfflineStore.init();
    hook();
    final clientId = 'c_${DateTime.now().microsecondsSinceEpoch}';
    if (ConnectivityMonitor.online.value) {
      try {
        await SupaFlow.client
            .from('messages')
            .insert({...message, 'client_id': clientId}).timeout(
                const Duration(seconds: 8));
        return true;
      } catch (e) {
        if (!isNetworkError(e)) rethrow;
        ConnectivityMonitor.reportFailure();
      }
    }
    await OfflineStore.enqueue(message, localId: clientId);
    return false;
  }

  static Future<void> retry(String localId) async {
    await OfflineStore.updateOutbox(localId, {'status': 'pending'});
    flush();
  }

  static Future<void> flush() async {
    if (_flushing) return;
    _flushing = true;
    try {
      await OfflineStore.init();
      // Anything still marked "sending" was cut off by an app restart.
      for (final e in OfflineStore.outbox()) {
        if (e['status'] == 'sending') {
          await OfflineStore.updateOutbox(
              e['local_id'].toString(), {'status': 'pending'});
        }
      }
      final items = OfflineStore.outbox()
        ..sort((a, b) => '${a['queued_at']}'.compareTo('${b['queued_at']}'));
      for (final item in items) {
        if (item['status'] == 'failed') continue;
        final localId = item['local_id'].toString();
        await OfflineStore.updateOutbox(localId, {'status': 'sending'});
        try {
          await _insert(item);
          await OfflineStore.removeOutbox(localId);
        } catch (e) {
          if (_isDuplicate(e)) {
            await OfflineStore.removeOutbox(localId);
            continue;
          }
          if (isNetworkError(e)) {
            await OfflineStore.updateOutbox(localId, {'status': 'pending'});
            ConnectivityMonitor.reportFailure();
            break;
          }
          debugPrint('outbox send failed: $e');
          await OfflineStore.updateOutbox(localId, {'status': 'failed'});
        }
      }
    } finally {
      _flushing = false;
    }
  }
}
