// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:ui';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:url_launcher/url_launcher.dart';
import '/custom_code/actions/index.dart';
import '/custom_code/actions/send_pending_web_chat_images.dart';
import '/custom_code/actions/init_offline_store.dart';
import 'dart:async';
import 'dart:convert';
import '/app_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart' show ScrollDirection;

class _PhoneMatch {
  const _PhoneMatch(this.start, this.end, this.normalized);
  final int start;
  final int end;
  final String normalized; // E.164 digits, no leading '+'
}

List<_PhoneMatch> _findPhoneNumbers(String text, IsoCode? callerIso) {
  final matches = <_PhoneMatch>[];
  final regex = RegExp(r'\+?[0-9][0-9\-\s]{6,16}[0-9]');

  for (final m in regex.allMatches(text)) {
    final raw = m.group(0)!;
    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    final digitCount = digitsOnly.replaceAll('+', '').length;
    if (digitCount < 7 || digitCount > 15) continue;

    try {
      final parsed = digitsOnly.startsWith('+')
          ? PhoneNumber.parse(digitsOnly)
          : (callerIso != null
              ? PhoneNumber.parse(digitsOnly, callerCountry: callerIso)
              : PhoneNumber.parse('+$digitsOnly'));
      if (!parsed.isValid()) continue;
      final normalized = parsed.international.replaceFirst('+', '');
      matches.add(_PhoneMatch(m.start, m.end, normalized));
    } catch (_) {
      continue;
    }
  }
  return matches;
}

final RegExp _urlRegex = RegExp(
  r'(https?:\/\/[^\s<>]+)|(www\.[^\s<>]+)',
  caseSensitive: false,
);

class _LinkMatch {
  const _LinkMatch(this.start, this.end, this.url);
  final int start;
  final int end;
  final String url;
}

List<_LinkMatch> _findLinks(String text) {
  final matches = <_LinkMatch>[];
  for (final m in _urlRegex.allMatches(text)) {
    var end = m.end;
    var raw = m.group(0)!;
    // Trim trailing punctuation that is likely sentence punctuation,
    // not part of the URL (e.g. "check this out: www.site.com.").
    while (raw.isNotEmpty && '.,!?;:)]}\'"'.contains(raw[raw.length - 1])) {
      raw = raw.substring(0, raw.length - 1);
      end--;
    }
    if (raw.isEmpty) continue;

    final normalized =
        raw.toLowerCase().startsWith('www.') ? 'https://$raw' : raw;
    matches.add(_LinkMatch(m.start, end, normalized));
  }
  return matches;
}

class _TappableMatch {
  const _TappableMatch(this.start, this.end, this.isLink, this.value);
  final int start;
  final int end;
  final bool isLink; // true = link, false = phone number
  final String value;
}

List<_TappableMatch> _findTappableMatches(String text, IsoCode? callerIso) {
  final combined = <_TappableMatch>[];
  for (final m in _findPhoneNumbers(text, callerIso)) {
    combined.add(_TappableMatch(m.start, m.end, false, m.normalized));
  }
  for (final m in _findLinks(text)) {
    combined.add(_TappableMatch(m.start, m.end, true, m.url));
  }
  combined.sort((a, b) => a.start.compareTo(b.start));

  final result = <_TappableMatch>[];
  var lastEnd = 0;
  for (final m in combined) {
    if (m.start < lastEnd) continue;
    result.add(m);
    lastEnd = m.end;
  }
  return result;
}

final Map<String, Stream<List<Map<String, dynamic>>>> _reactionStreams = {};

Stream<List<Map<String, dynamic>>> _reactionsStreamFor(String messageId) {
  return _reactionStreams.putIfAbsent(messageId, () {
    return SupaFlow.client
        .from('message_reactions')
        .stream(primaryKey: ['id']).eqOrNull('message_id', messageId);
  });
}

final Map<String, Future<Map<String, dynamic>?>> _linkPreviewCache = {};

Future<Map<String, dynamic>?> _fetchLinkPreview(String url) {
  return _linkPreviewCache.putIfAbsent(url, () async {
    try {
      final response = await SupaFlow.client.functions.invoke(
        'link-preview',
        body: {'url': url},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['error'] == null) {
        return data;
      }
      return null;
    } catch (_) {
      return null;
    }
  });
}

Future<void> _openExternalLink(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

String? _youtubeId(String url) {
  final u = Uri.tryParse(url);
  if (u == null) return null;
  final host = u.host.toLowerCase();
  String? id;
  if (host == 'youtu.be') {
    if (u.pathSegments.isNotEmpty) id = u.pathSegments.first;
  } else if (host.endsWith('youtube.com') ||
      host.endsWith('youtube-nocookie.com')) {
    if (u.path == '/watch') {
      id = u.queryParameters['v'];
    } else if (u.pathSegments.length >= 2 &&
        ['shorts', 'embed', 'live', 'v'].contains(u.pathSegments.first)) {
      id = u.pathSegments[1];
    }
  }
  if (id != null && RegExp(r'^[\w-]{6,15}$').hasMatch(id)) return id;
  return null;
}

// 'youtube' | 'facebook' | 'instagram' for video links, '' for anything else.
String _videoPlatform(String url) {
  if (_youtubeId(url) != null) return 'youtube';
  final u = Uri.tryParse(url);
  if (u == null) return '';
  final host = u.host.toLowerCase();
  final path = u.path.toLowerCase();
  if (host == 'fb.watch') return 'facebook';
  if (host.endsWith('facebook.com') || host.endsWith('fb.com')) {
    if (path.contains('/videos/') ||
        path.startsWith('/watch') ||
        path.contains('/reel') ||
        path.startsWith('/share/v/') ||
        path.startsWith('/share/r/')) {
      return 'facebook';
    }
    return '';
  }
  if (host.endsWith('instagram.com') || host == 'instagr.am') {
    if (path.startsWith('/reel/') ||
        path.startsWith('/reels/') ||
        path.startsWith('/p/') ||
        path.startsWith('/tv/')) {
      return 'instagram';
    }
  }
  return '';
}

Widget _platformIcon(String platform, double size, Color color) {
  if (platform == 'youtube') {
    return FaIcon(FontAwesomeIcons.youtube, size: size, color: color);
  }
  if (platform == 'facebook') {
    return FaIcon(FontAwesomeIcons.facebook, size: size, color: color);
  }
  return FaIcon(FontAwesomeIcons.instagram, size: size, color: color);
}

final Map<String, Future<Map<String, String>>> _youtubeMetaCache = {};

Future<Map<String, String>> _fetchYoutubeMeta(String id) {
  return _youtubeMetaCache.putIfAbsent(id, () async {
    final out = <String, String>{'title': '', 'author': ''};
    try {
      final res = await http
          .get(Uri.parse(
              'https://www.youtube.com/oembed?url=${Uri.encodeComponent('https://www.youtube.com/watch?v=$id')}&format=json'))
          .timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        if (d is Map) {
          out['title'] = (d['title'] ?? '').toString();
          out['author'] = (d['author_name'] ?? '').toString();
        }
      }
    } catch (_) {}
    return out;
  });
}

class _LinkPreviewCard extends StatelessWidget {
  const _LinkPreviewCard({required this.url, required this.isOwn});

  final String url;
  final bool isOwn;

  void _open(BuildContext context, String platform, String title) {
    if (platform.isEmpty || kIsWeb) {
      _openExternalLink(url);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => custom_widgets.VideoLinkScreen(url: url, title: title),
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String platform,
    required String title,
    required String siteName,
    required String image,
  }) {
    final hasIcon = platform == 'youtube' ||
        platform == 'facebook' ||
        platform == 'instagram';
    Color iconColor = Colors.white54;
    if (platform == 'youtube') {
      iconColor = const Color(0xFFFF0000);
    } else if (platform == 'facebook') {
      iconColor = const Color(0xFF1877F2);
    } else if (platform == 'instagram') {
      iconColor = const Color(0xFFE1306C);
    }
    final isVideo = platform.isNotEmpty;
    final heroHeight = isVideo ? 130.0 : 120.0;

    final placeholder = Container(
      width: 230,
      height: heroHeight,
      color: Colors.black87,
      alignment: Alignment.center,
      child: hasIcon ? _platformIcon(platform, 34, Colors.white54) : null,
    );

    Widget? hero;
    if (image.isNotEmpty) {
      hero = Image.network(
        image,
        width: 230,
        height: heroHeight,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            isVideo ? placeholder : const SizedBox.shrink(),
      );
    } else if (isVideo) {
      hero = placeholder;
    }

    return GestureDetector(
      onTap: () => _open(context, platform, title),
      child: Container(
        width: 230,
        margin: const EdgeInsets.only(top: 6),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color:
              isOwn ? Colors.white.withOpacity(0.12) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hero != null)
              Stack(
                alignment: Alignment.center,
                children: [
                  hero,
                  if (isVideo)
                    Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black54,
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 32),
                    ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isOwn ? Colors.white : Colors.black87,
                      ),
                    ),
                  if (siteName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Row(
                        children: [
                          if (hasIcon) ...[
                            _platformIcon(platform, 11, iconColor),
                            const SizedBox(width: 5),
                          ],
                          Expanded(
                            child: Text(
                              siteName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: isOwn ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final platform = _videoPlatform(url);

    // YouTube: built here (thumbnail is predictable, title from oEmbed).
    if (platform == 'youtube') {
      final id = _youtubeId(url)!;
      return FutureBuilder<Map<String, String>>(
        future: _fetchYoutubeMeta(id),
        builder: (context, snapshot) {
          final meta = snapshot.data ?? const <String, String>{};
          final title = meta['title'] ?? '';
          final author = meta['author'] ?? '';
          return _card(
            context,
            platform: 'youtube',
            title: title.isNotEmpty ? title : 'YouTube video',
            siteName: author.isNotEmpty ? 'YouTube  •  $author' : 'YouTube',
            image: 'https://i.ytimg.com/vi/$id/hqdefault.jpg',
          );
        },
      );
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchLinkPreview(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data;
        final title = (data?['title'] as String?) ?? '';
        final siteName = (data?['siteName'] as String?) ?? '';
        final image = (data?['image'] as String?) ?? '';

        if (title.isEmpty && image.isEmpty) {
          // Facebook / Instagram often block previews: still show a card.
          if (platform.isEmpty) return const SizedBox.shrink();
          return _card(
            context,
            platform: platform,
            title:
                platform == 'facebook' ? 'Facebook video' : 'Instagram video',
            siteName: Uri.tryParse(url)?.host.replaceFirst('www.', '') ?? '',
            image: '',
          );
        }

        return _card(
          context,
          platform: platform,
          title: title,
          siteName: siteName,
          image: image,
        );
      },
    );
  }
}

class _ChatAppearance {
  const _ChatAppearance({this.themeKey, this.wallpaperUrl});
  final String? themeKey;
  final String? wallpaperUrl;
}

class _ThemeBundle {
  const _ThemeBundle({
    required this.senderColor,
    required this.receiverColor,
    required this.wallpaperUrl,
  });
  final Color senderColor;
  final Color receiverColor;
  final String wallpaperUrl;
}

class _GroupEvent {
  const _GroupEvent(this.time, this.text);
  final DateTime time;
  final String text;
}

class GroupChatThread extends StatefulWidget {
  const GroupChatThread({
    super.key,
    this.width,
    this.height,
    required this.conversationId,
    required this.currentUserId,
    required this.currentUserPhoneNumber,
    required this.onReply,
    this.initialTargetMessageId,
  });

  final double? width;
  final double? height;
  final String conversationId;
  final String currentUserId;
  final String currentUserPhoneNumber;
  // isOwn is sent as the text 'true' or 'false'.
  final Future Function(String messageId, String content, String isOwn) onReply;
  final String? initialTargetMessageId;

  @override
  State<GroupChatThread> createState() => _GroupChatThreadState();
}

// Messages still waiting in the outbox have a local id, not a database id.
bool _isLocalPending(String? id) =>
    id != null && (id.startsWith('c_') || id.startsWith('local_'));

class _GroupChatThreadState extends State<GroupChatThread> {
  bool _hadTextFocus = false;

  // Keeps the keyboard open after a message is sent. If the text field loses
  // focus within 1.5s of the user's own new message appearing, focus returns.
  FocusNode? _textNode;
  DateTime? _focusLostAt;
  DateTime? _ownSentAt;
  DateTime? _lastOwnMessageAt;

  void _onGlobalFocusChange() {
    final primary = FocusManager.instance.primaryFocus;
    final typing = primary?.context?.widget is EditableText;
    if (typing) _textNode = primary;
    if (typing && !_hadTextFocus) _chatCollapseSignal.value++;
    if (!typing && _hadTextFocus) {
      _focusLostAt = DateTime.now();
      _maybeRestoreFocus();
    }
    _hadTextFocus = typing;
  }

  // ---- Offline-first messages: saved copy first, then live updates ----
  StreamController<List<MessagesRow>>? _msgController;
  StreamSubscription<List<Map<String, dynamic>>>? _remoteMsgSub;
  List<Map<String, dynamic>> _remoteRaw = [];
  bool _hasEmitted = false;

  Future<void> _startMessages() async {
    await OfflineStore.init();
    if (!mounted) return;
    final cached = OfflineStore.getMessages(widget.conversationId);
    if (cached.isNotEmpty) {
      _remoteRaw = cached;
      _emitMessages();
    }
    OfflineStore.outboxChanged.addListener(_emitMessages);
    _remoteMsgSub = SupaFlow.client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eqOrNull('conversation_id', widget.conversationId)
        .order('created_at', ascending: true)
        .listen((list) {
          _remoteRaw = List<Map<String, dynamic>>.from(list);
          _emitMessages();
          OfflineStore.putMessages(widget.conversationId, _remoteRaw);
        }, onError: (e) {
          debugPrint('group messages stream failed: $e');
          ConnectivityMonitor.reportFailure();
          if (!_hasEmitted) _emitMessages();
        });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && !_hasEmitted) _emitMessages();
    });
  }

  void _emitMessages() {
    final c = _msgController;
    if (c == null || c.isClosed || !mounted) return;
    final serverClientIds = _remoteRaw
        .map((r) => r['client_id']?.toString())
        .whereType<String>()
        .toSet();
    final rows = <MessagesRow>[];
    for (final r in _remoteRaw) {
      final m = MessagesRow(r);
      if (m.isDeleted == true) continue;
      if (m.deletedForUserIds.contains(widget.currentUserId)) continue;
      rows.add(m);
    }
    for (final o in OfflineStore.outbox(widget.conversationId)) {
      final localId = o['local_id']?.toString() ?? '';
      if (serverClientIds.contains(localId)) continue;
      rows.add(MessagesRow({
        'id': localId,
        'conversation_id': widget.conversationId,
        'sender_id': o['sender_id'],
        'message_type': o['message_type'] ?? 'text',
        'content': o['content'],
        'created_at': o['queued_at'],
        'reply_to_message_id': o['reply_to_message_id'],
        'reply_to_content': o['reply_to_content'],
        'reply_to_is_own': o['reply_to_is_own'],
        'is_deleted': false,
        'is_edited': false,
        'is_pinned': false,
        'deleted_for_user_ids': <String>[],
        'local_status': o['status'] ?? 'pending',
      }));
    }
    rows.sort((a, b) => (a.createdAt ?? DateTime.now())
        .compareTo(b.createdAt ?? DateTime.now()));
    _hasEmitted = true;
    c.add(rows);
  }

  void _noteOwnMessages(List<MessagesRow> messages) {
    DateTime? newest;
    for (final m in messages) {
      if (m.senderId != widget.currentUserId) continue;
      final at = m.createdAt;
      if (at == null) continue;
      if (newest == null || at.isAfter(newest)) newest = at;
    }
    if (newest == null) return;
    final previous = _lastOwnMessageAt;
    _lastOwnMessageAt = newest;
    if (previous != null && newest.isAfter(previous)) {
      _ownSentAt = DateTime.now();
      _maybeRestoreFocus();
    }
  }

  void _maybeRestoreFocus() {
    final lost = _focusLostAt;
    final sent = _ownSentAt;
    if (lost == null || sent == null) return;
    if (lost.difference(sent).abs() > const Duration(milliseconds: 1500)) {
      return;
    }
    final node = _textNode;
    if (node == null || !node.canRequestFocus) return;
    _focusLostAt = null;
    _ownSentAt = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || node.hasFocus || node.context == null) return;
      node.requestFocus();
    });
  }

  Stream<List<MessagesRow>>? _stream;
  Stream<DateTime?>? _otherLastReadStream;
  Stream<_ChatAppearance>? _themeStream;
  final ScrollController _scrollController = ScrollController();
  int _lastCount = 0;
  bool _didFirstScroll = false;
  double _lastBottomInset = 0;
  final Map<String, GlobalKey> _itemKeys = {};

  // Space reserved at the bottom of the list so the floating message bar
  // never covers the last message. Increase if your input bar grows.
  static const double _inputBarClearance = 96;
  static const int _maxPinnedMessages = 4;

  bool _showScrollDown = false;
  StreamSubscription<List<Map<String, dynamic>>>? _starsSub;
  Set<String> _starredIds = {};

  bool _selectionMode = false;
  String _selectionEntryAction = 'forward'; // 'forward' | 'delete'
  final Set<String> _selectedMessageIds = {};
  List<MessagesRow> _latestMessages = [];
  List<Map<String, dynamic>> _participants = [];
  Map<String, dynamic>? _conversation;
  final Map<String, String> _savedNames = {};
  final Map<String, Map<String, dynamic>> _profiles = {};
  final Set<String> _requestedIdentities = {};
  bool _identityFetchScheduled = false;
  StreamSubscription<List<Map<String, dynamic>>>? _participantsSub;
  StreamSubscription<List<Map<String, dynamic>>>? _conversationSub;
  List<Object> _timeline = [];

  int _pinnedBannerIndex = 0;
  String? _highlightedMessageId;
  int _highlightToken = 0;
  bool _didInitialTargetJump = false;

  bool _otherIsTyping = false;

  static const Map<String, _ThemeBundle> _themeBundles = {
    'theme1': _ThemeBundle(
      senderColor: Color(0xFFED50E4),
      receiverColor: Color(0xFFF1F5F9),
      wallpaperUrl:
          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/nexu-xidy5i/assets/hs3ncoawy90q/schatzapp_wallpaper..png',
    ),
    'theme2': _ThemeBundle(
      senderColor: Color(0xFFED50E4),
      receiverColor: Color(0xFFF1F5F9),
      wallpaperUrl:
          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/nexu-xidy5i/assets/okzb2earxxuk/.4.png',
    ),
    'theme3': _ThemeBundle(
      senderColor: Color(0xFF3B82F6),
      receiverColor: Color(0xFFFFFFFF),
      wallpaperUrl:
          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/nexu-xidy5i/assets/pt8bmcae9po5/schatzapp_wallpaper.3.png',
    ),
    'theme4': _ThemeBundle(
      senderColor: Color(0xFF0E8BAB),
      receiverColor: Color(0xFFE2E8F0),
      wallpaperUrl:
          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/nexu-xidy5i/assets/f3oes5poj8fa/schatzapp_wallpaper.2.png',
    ),
    'theme5': _ThemeBundle(
      senderColor: Color(0xFF935CCC),
      receiverColor: Color(0xFFF0F0F0),
      wallpaperUrl:
          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/nexu-xidy5i/assets/f62pmt3pghhs/schatzapp_wallpaper.png',
    ),
  };

  _ThemeBundle _bundleFor(String? themeKey) =>
      _themeBundles[themeKey] ?? _themeBundles['theme5']!;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_onGlobalFocusChange);
    _msgController = StreamController<List<MessagesRow>>();
    _stream = _msgController!.stream;
    _startMessages();

    _otherLastReadStream = Stream<DateTime?>.value(null);

    _themeStream = SupaFlow.client
        .from('conversation_participants')
        .stream(primaryKey: ['id'])
        .eqOrNull('conversation_id', widget.conversationId)
        .map((list) {
          final row = list.firstWhere(
            (r) => r['user_id'] == widget.currentUserId,
            orElse: () => const {},
          );
          return _ChatAppearance(
            themeKey: row['chat_theme'] as String?,
            wallpaperUrl: row['chat_wallpaper_url'] as String?,
          );
        });

    _scrollController.addListener(_onScrollChanged);

    _starsSub = SupaFlow.client
        .from('message_stars')
        .stream(primaryKey: ['user_id', 'message_id'])
        .eq('user_id', widget.currentUserId)
        .listen((rows) {
          if (!mounted) return;
          setState(() {
            _starredIds = rows.map((r) => r['message_id'].toString()).toSet();
          });
        }, onError: (e) => debugPrint('message_stars stream failed: $e'));

    _participantsSub = SupaFlow.client
        .from('conversation_participants')
        .stream(primaryKey: ['id'])
        .eqOrNull('conversation_id', widget.conversationId)
        .listen((rows) {
          if (!mounted) return;
          setState(() => _participants = rows);
          _requestIdentities(rows.expand((r) => [
                r['user_id'] as String?,
                r['added_by'] as String?,
                r['left_by'] as String?,
              ]));
        }, onError: (e) => debugPrint('participants stream failed: $e'));

    _conversationSub = SupaFlow.client
        .from('conversations')
        .stream(primaryKey: ['id'])
        .eq('id', widget.conversationId)
        .listen((rows) {
          if (!mounted) return;
          setState(() => _conversation = rows.isEmpty ? null : rows.first);
          if (rows.isNotEmpty) {
            _requestIdentities([
              rows.first['created_by'] as String?,
              rows.first['deleted_by'] as String?,
            ]);
          }
        }, onError: (e) => debugPrint('conversation stream failed: $e'));
  }

  // Tells the page who sent the replied-to message (through App State, so the
  // page can read it as a Boolean), then raises the page's onReply action.
  Future _emitReply(String messageId, String content, bool isOwn) async {
    FFAppState().update(() {
      FFAppState().groupReplyIsOwn = isOwn;
    });
    return widget.onReply(messageId, content, isOwn.toString());
  }

  void _onScrollChanged() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final shouldShow = (pos.maxScrollExtent - pos.pixels) > 300;
    if (shouldShow != _showScrollDown && mounted) {
      setState(() => _showScrollDown = shouldShow);
    }
  }

  Future<void> _scrollToLatest() async {
    if (!_scrollController.hasClients) return;
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
    // Items just built by the scroll can extend the list; settle at the end.
    if (_scrollController.hasClients) {
      final max = _scrollController.position.maxScrollExtent;
      if (_scrollController.offset < max - 1) {
        await _scrollController.animateTo(max,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    }
  }

  @override
  void dispose() {
    _selectionOverlay?.remove();
    _selectionOverlay = null;
    FocusManager.instance.removeListener(_onGlobalFocusChange);
    _starsSub?.cancel();
    _remoteMsgSub?.cancel();
    OfflineStore.outboxChanged.removeListener(_emitMessages);
    _msgController?.close();
    _participantsSub?.cancel();
    _conversationSub?.cancel();
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Identities: saved contact name, else username, else phone number.
  // ---------------------------------------------------------------------
  void _requestIdentities(Iterable<String?> ids) {
    var added = false;
    for (final id in ids) {
      if (id == null || id.isEmpty || id == widget.currentUserId) continue;
      if (_requestedIdentities.add(id)) added = true;
    }
    if (added && !_identityFetchScheduled) {
      _identityFetchScheduled = true;
      scheduleMicrotask(_fetchIdentities);
    }
  }

  Future<void> _fetchIdentities() async {
    _identityFetchScheduled = false;
    final ids =
        _requestedIdentities.where((id) => !_profiles.containsKey(id)).toList();
    if (ids.isEmpty) return;
    try {
      final profileRows = await SupaFlow.client
          .from('profiles')
          .select('id, username, full_name')
          .inFilter('id', ids);
      final contactRows = await SupaFlow.client
          .from('contacts')
          .select('contact_user_id, saved_name')
          .eq('owner_id', widget.currentUserId)
          .inFilter('contact_user_id', ids);
      if (!mounted) return;
      setState(() {
        for (final id in ids) {
          _profiles[id] = const {};
        }
        for (final row in profileRows) {
          _profiles[row['id'] as String] = Map<String, dynamic>.from(row);
        }
        for (final row in contactRows) {
          final id = row['contact_user_id'] as String?;
          final name = (row['saved_name'] as String?)?.trim() ?? '';
          if (id != null && name.isNotEmpty) _savedNames[id] = name;
        }
      });
    } catch (e) {
      debugPrint('fetchIdentities failed: $e');
    }
  }

  String _nameFor(String? userId) {
    if (userId == null || userId.isEmpty) return 'Someone';
    if (userId == widget.currentUserId) return 'You';
    final saved = _savedNames[userId];
    if (saved != null && saved.isNotEmpty) return saved;
    final profile = _profiles[userId];
    final username = (profile?['username'] as String?)?.trim() ?? '';
    if (username.isNotEmpty) return username;
    final full = (profile?['full_name'] as String?)?.trim() ?? '';
    if (full.isNotEmpty) return full;
    return 'Member';
  }

  static const List<Color> _senderPalette = [
    Color(0xFFE5483B),
    Color(0xFF1E88E5),
    Color(0xFF2E9E5B),
    Color(0xFFD97706),
    Color(0xFF8E44AD),
    Color(0xFF0E8BAB),
    Color(0xFFC2185B),
    Color(0xFF5D6D7E),
  ];

  Color _senderColor(String? userId) {
    if (userId == null || userId.isEmpty) return _senderPalette.first;
    return _senderPalette[userId.hashCode.abs() % _senderPalette.length];
  }

  String _replyAuthor(MessagesRow m) {
    if (m.replyToIsOwn == true) return 'You';
    final replyId = m.replyToMessageId;
    if (replyId == null) return 'Member';
    for (final candidate in _latestMessages) {
      if (candidate.id == replyId) return _nameFor(candidate.senderId);
    }
    return 'Member';
  }

  // ---------------------------------------------------------------------
  // Membership notices, derived from participants + conversation rows.
  // ---------------------------------------------------------------------
  DateTime? _myLeftAt() {
    for (final r in _participants) {
      if (r['user_id'] == widget.currentUserId && r['left_at'] != null) {
        return DateTime.tryParse(r['left_at'].toString());
      }
    }
    return null;
  }

  List<_GroupEvent> _buildEvents(DateTime? cutoff) {
    final events = <_GroupEvent>[];
    final conv = _conversation;
    final createdAt = DateTime.tryParse('${conv?['created_at'] ?? ''}');
    final createdBy = conv?['created_by'] as String?;

    if (createdAt != null) {
      events.add(_GroupEvent(
        createdAt,
        createdBy == widget.currentUserId
            ? 'You created this group'
            : '${_nameFor(createdBy)} created this group',
      ));
    }

    for (final p in _participants) {
      final userId = p['user_id'] as String?;
      if (userId == null) continue;
      final target = _nameFor(userId);
      final joinedAt = DateTime.tryParse('${p['joined_at'] ?? ''}');
      final addedBy = p['added_by'] as String?;

      final isCreatorRow = userId == createdBy;
      final isInitialMember = createdAt != null &&
          joinedAt != null &&
          joinedAt.difference(createdAt).inSeconds.abs() <= 10;

      if (joinedAt != null && !isCreatorRow && !isInitialMember) {
        String text;
        if (addedBy == null || addedBy == userId) {
          text = '$target joined';
        } else if (addedBy == widget.currentUserId) {
          text = 'You added $target';
        } else if (userId == widget.currentUserId) {
          text = '${_nameFor(addedBy)} added you';
        } else {
          text = '${_nameFor(addedBy)} added $target';
        }
        if (userId == widget.currentUserId &&
            (addedBy == null || addedBy == userId)) {
          text = 'You joined';
        }
        events.add(_GroupEvent(joinedAt, text));
      }

      final leftAt = DateTime.tryParse('${p['left_at'] ?? ''}');
      if (leftAt != null) {
        final leftBy = p['left_by'] as String?;
        String text;
        if (leftBy == null || leftBy == userId) {
          text = userId == widget.currentUserId ? 'You left' : '$target left';
        } else if (leftBy == widget.currentUserId) {
          text = 'You removed $target';
        } else if (userId == widget.currentUserId) {
          text = '${_nameFor(leftBy)} removed you';
        } else {
          text = '${_nameFor(leftBy)} removed $target';
        }
        events.add(_GroupEvent(leftAt, text));
      }
    }

    final deletedAt = DateTime.tryParse('${conv?['deleted_at'] ?? ''}');
    if (deletedAt != null) {
      final deletedBy = conv?['deleted_by'] as String?;
      events.add(_GroupEvent(
        deletedAt,
        deletedBy == widget.currentUserId
            ? 'You deleted this group'
            : '${_nameFor(deletedBy)} deleted this group',
      ));
    }

    if (cutoff != null) {
      events.removeWhere((e) => e.time.isAfter(cutoff));
    }
    return events;
  }

  List<Object> _buildTimeline(List<MessagesRow> messages, DateTime? cutoff) {
    final events = _buildEvents(cutoff);
    final items = <Object>[...messages, ...events];
    items.sort((a, b) {
      final ta = a is MessagesRow
          ? (a.createdAt ?? DateTime.now())
          : (a as _GroupEvent).time;
      final tb = b is MessagesRow
          ? (b.createdAt ?? DateTime.now())
          : (b as _GroupEvent).time;
      return ta.compareTo(tb);
    });
    return items;
  }

  Widget _eventChip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.38),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
      ),
    );
  }

  DecorationImage? _wallpaperImage(String? wallpaperUrl) {
    if (wallpaperUrl == null || wallpaperUrl.isEmpty) return null;
    return DecorationImage(
        image: NetworkImage(wallpaperUrl), fit: BoxFit.cover);
  }

  void _maybeScrollToBottom(int newCount, double bottomInset) {
    final changed = newCount != _lastCount || bottomInset != _lastBottomInset;
    _lastCount = newCount;
    _lastBottomInset = bottomInset;
    if (changed) {
      final firstLoad = !_didFirstScroll && newCount > 0;
      if (firstLoad && widget.initialTargetMessageId != null) {
        _didFirstScroll = true;
        _stickToBottom = false;
        return;
      }
      if (firstLoad) _didFirstScroll = true;
      _stickToBottom = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;
        if (firstLoad) {
          // Opening a chat: go straight to the newest message, no animation.
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          for (final ms in [150, 450, 1000]) {
            Future.delayed(Duration(milliseconds: ms), () {
              if (!mounted ||
                  !_stickToBottom ||
                  !_scrollController.hasClients) {
                return;
              }
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            });
          }
        } else {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _markLanded(String messageId, bool highlight) async {
    if (!highlight || !mounted) return;
    setState(() {
      _highlightedMessageId = messageId;
      _highlightToken++;
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_highlightedMessageId == messageId) {
        setState(() => _highlightedMessageId = null);
      }
    });
  }

  Future<void> _scrollToMessage(String? messageId,
      {bool highlight = false}) async {
    if (messageId == null) return;
    _stickToBottom = false;

    // Fast path: the message is already built (on-screen or just off the
    // edge of the viewport), so we can jump straight to it.
    final existingCtx = _itemKeys[messageId]?.currentContext;
    if (existingCtx != null) {
      await Scrollable.ensureVisible(
        existingCtx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
      await _markLanded(messageId, highlight);
      return;
    }

    // The message can be far above the current position, where the list
    // has not built it yet. Jump to an estimate, then keep stepping toward
    // it (up or down) until the real widget exists, then land smoothly.
    final ids = _timeline.map((m) => m is MessagesRow ? m.id : null).toList();
    final index = ids.indexOf(messageId);
    if (index == -1 || !_scrollController.hasClients) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Original message not available')));
      }
      return;
    }
    final totalCount = ids.length;
    if (totalCount <= 1) return;

    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) return;
    _scrollController
        .jumpTo((maxExtent * (index / (totalCount - 1))).clamp(0, maxExtent));

    for (var attempt = 0; attempt < 60; attempt++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted || !_scrollController.hasClients) return;

      final ctx = _itemKeys[messageId]?.currentContext;
      if (ctx != null) {
        await Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.3,
        );
        await _markLanded(messageId, highlight);
        return;
      }

      // Which messages are built right now?
      int minBuilt = totalCount;
      int maxBuilt = -1;
      for (var i = 0; i < totalCount; i++) {
        final id = ids[i];
        if (id != null && _itemKeys[id]?.currentContext != null) {
          if (i < minBuilt) minBuilt = i;
          if (i > maxBuilt) maxBuilt = i;
        }
      }
      final pos = _scrollController.position;
      final step = pos.viewportDimension * 0.8;
      double next = pos.pixels;
      if (maxBuilt == -1) {
        next = (maxExtent * (index / (totalCount - 1)));
      } else if (index < minBuilt) {
        next = pos.pixels - step;
      } else if (index > maxBuilt) {
        next = pos.pixels + step;
      } else {
        next = pos.pixels - 40;
      }
      _scrollController.jumpTo(next.clamp(0.0, maxExtent));
    }
  }

  String _previewFor(MessagesRow m) {
    switch (m.messageType) {
      case 'image':
        return '📷 Photo';
      case 'image_group':
        return '📷 ${m.mediaUrls.length} Photos';
      case 'video':
        return '🎥 Video';
      case 'voice_note':
        return '🎤 Voice message';
      case 'call':
        final parts = (m.content ?? 'voice:missed').split(':');
        final isVideo = parts.isNotEmpty && parts[0] == 'video';
        return isVideo ? '🎥 Video call' : '📞 Voice call';
      case 'gift_card':
        return '🎁 Schatz Gift Card';
      default:
        return m.content ?? '';
    }
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('MMMM d, yyyy').format(date);
  }

  String _timeLabel(DateTime date) => DateFormat('h:mm a').format(date);

  bool _isSameMinute(DateTime a, DateTime b) =>
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day &&
      a.hour == b.hour &&
      a.minute == b.minute;

  void _openFullView(List<String> urls, int startIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullImageViewer(
            urls: urls,
            initialIndex: startIndex,
            conversationId: widget.conversationId,
            currentUserId: widget.currentUserId,
          );
        },
      ),
    );
  }

  OverlayEntry? _selectionOverlay;

  // The selection bar is drawn on the app overlay so the message box on the
  // page can never cover it.
  void _syncSelectionOverlay() {
    if (!mounted) return;
    if (_selectionMode) {
      if (_selectionOverlay == null) {
        final entry = OverlayEntry(
          builder: (_) => Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildSelectionBar(),
          ),
        );
        _selectionOverlay = entry;
        Overlay.of(context).insert(entry);
      } else {
        _selectionOverlay!.markNeedsBuild();
      }
    } else {
      _selectionOverlay?.remove();
      _selectionOverlay = null;
    }
  }

  Widget _buildSelectionBar() {
    return Material(
      color: Colors.white,
      elevation: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: _selectionEntryAction == 'forward'
                    ? _openMultiForwardPicker
                    : _showDeleteDialog,
                child: Icon(
                  _selectionEntryAction == 'forward'
                      ? Icons.reply_all_outlined
                      : Icons.delete_outline,
                  color: _selectionEntryAction == 'forward'
                      ? const Color(0xFF935CCC)
                      : const Color(0xFFE91414),
                  size: 24,
                ),
              ),
              Text(
                '${_selectedMessageIds.length} Selected',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
              Row(
                children: [
                  if (_canShowUnpin())
                    InkWell(
                      onTap: () => _setPinnedForSelection(false),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.push_pin,
                            color: Color(0xFF935CCC), size: 22),
                      ),
                    )
                  else if (_canShowPin())
                    InkWell(
                      onTap: () => _setPinnedForSelection(true),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.push_pin_outlined,
                            color: Color(0xFF935CCC), size: 22),
                      ),
                    ),
                  InkWell(
                    onTap: _openShareSheet,
                    child: const Icon(Icons.share,
                        color: Color(0xFF935CCC), size: 22),
                  ),
                  const SizedBox(width: 20),
                  InkWell(
                    onTap: _cancelSelectionMode,
                    child: const Icon(Icons.close,
                        color: Colors.black54, size: 22),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _stickToBottom = true;

  // Keeps the newest message in view while the list is still measuring
  // itself (images, link cards and receipts change heights after they load).
  bool _onThreadNotification(Notification n) {
    if (n is ScrollMetricsNotification) {
      if (n.depth == 0 &&
          n.metrics.axis == Axis.vertical &&
          _stickToBottom &&
          _scrollController.hasClients &&
          (n.metrics.maxScrollExtent - _scrollController.offset).abs() > 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_stickToBottom || !_scrollController.hasClients) {
            return;
          }
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });
      }
    } else if (n is ScrollNotification &&
        n.depth == 0 &&
        n.metrics.axis == Axis.vertical) {
      if (n is UserScrollNotification &&
          n.direction == ScrollDirection.forward) {
        _stickToBottom = false;
      } else if (n is ScrollEndNotification &&
          n.metrics.maxScrollExtent - n.metrics.pixels < 60) {
        _stickToBottom = true;
      }
    }
    return false;
  }

  void _enterSelectionMode(String messageId, String action) {
    setState(() {
      _selectionMode = true;
      _selectionEntryAction = action;
      _selectedMessageIds.add(messageId);
    });
    _syncSelectionOverlay();
  }

  void _toggleMessageSelection(String messageId) {
    setState(() {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
      } else {
        _selectedMessageIds.add(messageId);
      }
      if (_selectedMessageIds.isEmpty) _selectionMode = false;
    });
    _syncSelectionOverlay();
  }

  void _cancelSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedMessageIds.clear();
    });
    _syncSelectionOverlay();
  }

  List<MessagesRow> get _selectedMessages =>
      _latestMessages.where((m) => _selectedMessageIds.contains(m.id)).toList();

  int get _pinnedCount =>
      _latestMessages.where((m) => m.isPinned == true).length;

  // Unpin: only when every selected message is already pinned.
  bool _canShowUnpin() {
    final sel = _selectedMessages;
    return sel.isNotEmpty && sel.every((m) => m.isPinned == true);
  }

  // Pin: selection has unpinned messages and the total stays within 4.
  bool _canShowPin() {
    final sel = _selectedMessages;
    if (sel.isEmpty) return false;
    final toPin = sel.where((m) => m.isPinned != true).length;
    if (toPin == 0) return false;
    return _pinnedCount + toPin <= _maxPinnedMessages;
  }

  Future<void> _setPinnedForSelection(bool pin) async {
    final ids = _selectedMessages
        .where((m) => (m.isPinned == true) != pin)
        .map((m) => m.id)
        .whereType<String>()
        .toList();
    _cancelSelectionMode();
    if (ids.isEmpty) return;
    try {
      // Any member can pin or unpin, including other people's messages.
      await SupaFlow.client
          .rpc('set_messages_pinned', params: {'p_ids': ids, 'p_pin': pin});
    } catch (e) {
      debugPrint('_setPinnedForSelection failed: $e');
    }
  }

  void _openMultiForwardPicker() {
    final selectedMessages = _latestMessages
        .where((m) => _selectedMessageIds.contains(m.id))
        .toList();
    _cancelSelectionMode();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MultiForwardSheet(
        currentUserId: widget.currentUserId,
        messages: selectedMessages,
      ),
    );
  }

  void _openShareSheet() {
    final selectedMessages = _latestMessages
        .where((m) => _selectedMessageIds.contains(m.id))
        .toList();
    _cancelSelectionMode();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ShareSheet(
        currentUserId: widget.currentUserId,
        messages: selectedMessages,
      ),
    );
  }

  // Delete for everyone rules. The database enforces the same rules.
  Future<String?> _deleteBlockReason(List<String> ids) async {
    try {
      final rows = await SupaFlow.client
          .from('messages')
          .select('id, created_at, seen_at, conversation_id')
          .inFilter('id', ids);
      final now = DateTime.now();
      for (final r in rows) {
        final seenRaw = r['seen_at'];
        if (seenRaw == null) continue; // unseen: always allowed
        final seenAt = DateTime.parse(seenRaw.toString());
        if (now.difference(seenAt) > const Duration(minutes: 5)) {
          return 'Seen more than 5 minutes ago, so it can only be deleted for you.';
        }
        final created = DateTime.parse(r['created_at'].toString());
        final window = await SupaFlow.client
            .from('messages')
            .select('sender_id')
            .eq('conversation_id', r['conversation_id'])
            .gt(
                'created_at',
                created
                    .subtract(const Duration(minutes: 5))
                    .toUtc()
                    .toIso8601String())
            .lte('created_at', created.toUtc().toIso8601String());
        final senders = (window as List).map((e) => e['sender_id']).toSet();
        if (window.length > 7 && senders.length > 1) {
          return 'Too many messages exchanged in 5 minutes, so it can only be deleted for you.';
        }
      }
    } catch (e) {
      debugPrint('_deleteBlockReason failed: $e');
    }
    return null;
  }

  Future<void> _showDeleteDialog() async {
    final selectedMessages = _latestMessages
        .where((m) => _selectedMessageIds.contains(m.id))
        .toList();
    final allOwn =
        selectedMessages.every((m) => m.senderId == widget.currentUserId);
    final ids = _selectedMessageIds.toList();
    _cancelSelectionMode();
    final blockReason = allOwn ? await _deleteBlockReason(ids) : null;
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Delete message?',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              if (allOwn && blockReason == null)
                _deleteDialogButton(
                  dialogContext,
                  'Delete for everyone',
                  const Color(0xFFE05C6E),
                  () async {
                    Navigator.pop(dialogContext);
                    try {
                      await SupaFlow.client
                          .from('messages')
                          .update({'is_deleted': true}).inFilter('id', ids);
                    } catch (e) {
                      debugPrint('delete for everyone failed: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'This message can no longer be deleted for everyone'),
                          ),
                        );
                      }
                    }
                  },
                ),
              if (allOwn && blockReason != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(blockReason,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12.5)),
                ),
              if (allOwn) const SizedBox(height: 10),
              _deleteDialogButton(
                dialogContext,
                'Delete for me',
                const Color(0xFF935CCC),
                () async {
                  Navigator.pop(dialogContext);
                  for (final m in selectedMessages) {
                    final current = List<String>.from(m.deletedForUserIds);
                    if (!current.contains(widget.currentUserId)) {
                      current.add(widget.currentUserId);
                      await SupaFlow.client
                          .from('messages')
                          .update({'deleted_for_user_ids': current}).eq(
                              'id', m.id ?? '');
                    }
                  }
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deleteDialogButton(
      BuildContext context, String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildPinnedBanner(
      List<MessagesRow> pinnedMessages, Color accentColor) {
    final ordered = pinnedMessages.reversed.toList();
    if (_pinnedBannerIndex >= ordered.length) _pinnedBannerIndex = 0;
    final current = ordered[_pinnedBannerIndex];

    return InkWell(
      onTap: () async {
        final targetId = current.id;
        setState(() {
          _pinnedBannerIndex = (_pinnedBannerIndex + 1) % ordered.length;
        });
        await _scrollToMessage(targetId, highlight: true);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        color: accentColor.withOpacity(0.12),
        child: Row(
          children: [
            Icon(Icons.push_pin, size: 16, color: accentColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _previewFor(current),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
            if (ordered.length > 1)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(ordered.length, (i) {
                    final isActive = i == _pinnedBannerIndex;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Container(
                        width: isActive ? 6 : 5,
                        height: isActive ? 6 : 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? accentColor
                              : accentColor.withOpacity(0.3),
                        ),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: StreamBuilder<List<MessagesRow>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final myLeftAt = _myLeftAt();
          // A member who left or was removed keeps the history up to that
          // moment, but nothing newer.
          final messages = snapshot.data!
              .where((m) =>
                  myLeftAt == null ||
                  !(m.createdAt ?? DateTime.now()).isAfter(myLeftAt))
              .toList();
          _latestMessages = messages;
          _noteOwnMessages(messages);
          _timeline = _buildTimeline(messages, myLeftAt);
          _requestIdentities(messages.map((m) => m.senderId));
          final timeline = _timeline;
          final pinnedMessages = messages
              .where((m) => m.isPinned == true)
              .take(_maxPinnedMessages)
              .toList();

          if (!_didInitialTargetJump &&
              widget.initialTargetMessageId != null &&
              messages.isNotEmpty) {
            _didInitialTargetJump = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToMessage(widget.initialTargetMessageId, highlight: true);
            });
          }

          return StreamBuilder<DateTime?>(
            stream: _otherLastReadStream,
            builder: (context, readSnapshot) {
              final otherLastRead = readSnapshot.data;

              return StreamBuilder<_ChatAppearance>(
                stream: _themeStream,
                builder: (context, themeSnapshot) {
                  final appearance = themeSnapshot.data;
                  final bundle = _bundleFor(appearance?.themeKey);
                  final wallpaperImage = _wallpaperImage(
                      appearance?.wallpaperUrl ?? bundle.wallpaperUrl);
                  final ownBubbleColor = bundle.senderColor;
                  final otherBubbleColor = bundle.receiverColor;

                  return ValueListenableBuilder<List<PendingChatSend>>(
                    valueListenable: pendingChatSendsNotifier,
                    builder: (context, allPending, _) {
                      final pending = allPending
                          .where(
                              (p) => p.conversationId == widget.conversationId)
                          .toList();

                      final totalCount = timeline.length + pending.length;
                      final itemCount = totalCount + (_otherIsTyping ? 1 : 0);
                      final bottomInset =
                          MediaQuery.viewInsetsOf(context).bottom;
                      _maybeScrollToBottom(itemCount, bottomInset);

                      return Column(
                        children: [
                          if (pinnedMessages.isNotEmpty && !_selectionMode)
                            _buildPinnedBanner(
                                pinnedMessages, bundle.senderColor),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(image: wallpaperImage),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: NotificationListener<Notification>(
                                      onNotification: _onThreadNotification,
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 8, 10, _inputBarClearance),
                                        itemCount: itemCount,
                                        itemBuilder: (context, index) {
                                          if (index >= totalCount) {
                                            return _typingBubble(
                                                otherBubbleColor);
                                          }
                                          if (index < timeline.length) {
                                            final item = timeline[index];
                                            final itemTime = item is MessagesRow
                                                ? (item.createdAt ??
                                                    DateTime.now())
                                                : (item as _GroupEvent).time;
                                            final prevItem = index > 0
                                                ? timeline[index - 1]
                                                : null;
                                            final prevTime = prevItem == null
                                                ? null
                                                : (prevItem is MessagesRow
                                                    ? (prevItem.createdAt ??
                                                        DateTime.now())
                                                    : (prevItem as _GroupEvent)
                                                        .time);
                                            final showDateSeparator =
                                                prevTime == null ||
                                                    !_isSameDay(
                                                        itemTime, prevTime);

                                            if (item is _GroupEvent) {
                                              return Column(
                                                key: ValueKey(
                                                    'event_${item.time.microsecondsSinceEpoch}_$index'),
                                                children: [
                                                  if (showDateSeparator)
                                                    _dateSeparator(itemTime),
                                                  _eventChip(item.text),
                                                ],
                                              );
                                            }

                                            final message = item as MessagesRow;
                                            final isOwn = message.senderId ==
                                                widget.currentUserId;
                                            final createdAt = itemTime;

                                            final nextItem =
                                                index + 1 < timeline.length
                                                    ? timeline[index + 1]
                                                    : null;
                                            final nextMessage =
                                                nextItem is MessagesRow
                                                    ? nextItem
                                                    : null;
                                            final showTimestamp =
                                                nextMessage == null ||
                                                    nextMessage.senderId !=
                                                        message.senderId ||
                                                    !_isSameMinute(
                                                        createdAt,
                                                        nextMessage.createdAt ??
                                                            createdAt);

                                            final showSender = !isOwn &&
                                                (prevItem is! MessagesRow ||
                                                    prevItem.senderId !=
                                                        message.senderId ||
                                                    showDateSeparator);

                                            final isRead = false;

                                            final itemKey =
                                                _itemKeys.putIfAbsent(
                                                    message.id ?? 'msg_$index',
                                                    () => GlobalKey());

                                            final isSelected =
                                                _selectedMessageIds
                                                    .contains(message.id ?? '');

                                            return Column(
                                              key: ValueKey(message.id),
                                              crossAxisAlignment: isOwn
                                                  ? CrossAxisAlignment.end
                                                  : CrossAxisAlignment.start,
                                              children: [
                                                if (showDateSeparator)
                                                  _dateSeparator(createdAt),
                                                Container(
                                                  key: itemKey,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      if (_selectionMode)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 6),
                                                          child: Icon(
                                                            isSelected
                                                                ? Icons
                                                                    .check_circle
                                                                : Icons
                                                                    .radio_button_unchecked,
                                                            size: 20,
                                                            color: isSelected
                                                                ? const Color(
                                                                    0xFF935CCC)
                                                                : Colors
                                                                    .black26,
                                                          ),
                                                        ),
                                                      Flexible(
                                                        child: GestureDetector(
                                                          onTap: _selectionMode
                                                              ? () =>
                                                                  _toggleMessageSelection(
                                                                      message.id ??
                                                                          '')
                                                              : null,
                                                          child:
                                                              _AnimatedBubbleEntrance(
                                                            child:
                                                                _SwipeToReplyWrapper(
                                                              isOwn: isOwn,
                                                              enabled:
                                                                  !_selectionMode,
                                                              onReplyTriggered:
                                                                  () =>
                                                                      _emitReply(
                                                                message.id ??
                                                                    '',
                                                                _previewFor(
                                                                    message),
                                                                isOwn,
                                                              ),
                                                              child:
                                                                  _MessageBubble(
                                                                message:
                                                                    message,
                                                                isOwn: isOwn,
                                                                isRead: isRead,
                                                                ownBubbleColor:
                                                                    ownBubbleColor,
                                                                otherBubbleColor:
                                                                    otherBubbleColor,
                                                                replyAuthorName:
                                                                    _replyAuthor(
                                                                        message),
                                                                senderName: showSender
                                                                    ? _nameFor(
                                                                        message
                                                                            .senderId)
                                                                    : null,
                                                                senderColor:
                                                                    _senderColor(
                                                                        message
                                                                            .senderId),
                                                                timeLabel:
                                                                    _timeLabel(
                                                                        createdAt),
                                                                showTimestamp:
                                                                    showTimestamp,
                                                                currentUserId:
                                                                    widget
                                                                        .currentUserId,
                                                                currentUserPhoneNumber:
                                                                    widget
                                                                        .currentUserPhoneNumber,
                                                                conversationId:
                                                                    widget
                                                                        .conversationId,
                                                                onImageTap:
                                                                    _openFullView,
                                                                onReply:
                                                                    _emitReply,
                                                                selectionMode:
                                                                    _selectionMode,
                                                                onReplyTap: (id) =>
                                                                    _scrollToMessage(
                                                                        id,
                                                                        highlight:
                                                                            true),
                                                                onEnterSelection:
                                                                    _enterSelectionMode,
                                                                isHighlighted: message
                                                                            .id !=
                                                                        null &&
                                                                    message.id ==
                                                                        _highlightedMessageId,
                                                                highlightToken:
                                                                    _highlightToken,
                                                                starred: _starredIds
                                                                    .contains(
                                                                        message.id ??
                                                                            ''),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }

                                          // Optimistic (still-sending, or failed) bubble.
                                          final p =
                                              pending[index - timeline.length];
                                          final firstIsVideo =
                                              p.mediaTypes.isNotEmpty &&
                                                  p.mediaTypes.first == 'video';
                                          final firstIsDoc =
                                              p.mediaTypes.isNotEmpty &&
                                                  p.mediaTypes.first
                                                      .startsWith('document:');

                                          return Padding(
                                            key: ValueKey('pending_${p.id}'),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 3),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: p.hasError
                                                    ? () =>
                                                        removePendingChatSend(
                                                            p.id)
                                                    : null,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 260),
                                                  decoration: BoxDecoration(
                                                    color: p.hasError
                                                        ? const Color(
                                                            0xFFB33A3A)
                                                        : const Color(
                                                            0xFF935CCC),
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(16),
                                                      topRight:
                                                          Radius.circular(16),
                                                      bottomLeft:
                                                          Radius.circular(16),
                                                      bottomRight:
                                                          Radius.circular(4),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(14),
                                                        child: SizedBox(
                                                          width: 200,
                                                          height: 200,
                                                          child: Stack(
                                                            alignment: Alignment
                                                                .center,
                                                            children: [
                                                              if (firstIsVideo ||
                                                                  firstIsDoc)
                                                                Container(
                                                                    color: Colors
                                                                        .black)
                                                              else
                                                                Image.memory(
                                                                    p.previewBytesList
                                                                        .first,
                                                                    width: 200,
                                                                    height: 200,
                                                                    fit: BoxFit
                                                                        .cover),
                                                              Container(
                                                                width: 200,
                                                                height: 200,
                                                                color: Colors
                                                                    .black38,
                                                              ),
                                                              if (p.hasError)
                                                                const Icon(
                                                                    Icons
                                                                        .error_outline,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 36)
                                                              else if (firstIsDoc)
                                                                const Icon(
                                                                    Icons
                                                                        .insert_drive_file_outlined,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 36)
                                                              else if (firstIsVideo)
                                                                const Icon(
                                                                    Icons
                                                                        .videocam_outlined,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 36)
                                                              else
                                                                const CircularProgressIndicator(
                                                                    color: Colors
                                                                        .white),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      if (p.caption.isNotEmpty)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 6),
                                                          child: Text(p.caption,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      14)),
                                                        ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 4),
                                                        child: Text(
                                                          p.hasError
                                                              ? p.errorText
                                                              : 'Sending...',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white70,
                                                                  fontSize: 11),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 14,
                                    bottom: _inputBarClearance - 6,
                                    child: IgnorePointer(
                                      ignoring: !_showScrollDown,
                                      child: AnimatedOpacity(
                                        opacity: _showScrollDown ? 1 : 0,
                                        duration:
                                            const Duration(milliseconds: 180),
                                        child: AnimatedScale(
                                          scale: _showScrollDown ? 1 : 0.7,
                                          duration:
                                              const Duration(milliseconds: 180),
                                          child: Material(
                                            color: Colors.white,
                                            elevation: 4,
                                            shape: const CircleBorder(),
                                            child: InkWell(
                                              customBorder:
                                                  const CircleBorder(),
                                              onTap: _scrollToLatest,
                                              child: const SizedBox(
                                                width: 38,
                                                height: 38,
                                                child: Icon(
                                                  Icons
                                                      .keyboard_arrow_down_rounded,
                                                  color: Color(0xFF935CCC),
                                                  size: 28,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _typingBubble(Color otherBubbleColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: otherBubbleColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const _TypingDots(),
        ),
      ),
    );
  }

  Widget _dateSeparator(DateTime createdAt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.38),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _dateLabel(createdAt),
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ---------------------------------------------------------------------
// Long message collapse: first 250 words, "See more" / "See less".
// ---------------------------------------------------------------------
final ValueNotifier<int> _chatCollapseSignal = ValueNotifier<int>(0);
const int _collapseWordLimit = 250;

/// Index just after the 250th word, or -1 when the text has 250 words or less.
int _collapseCutIndex(String text) {
  var count = 0;
  var lastEnd = -1;
  for (final m in RegExp(r'\S+').allMatches(text)) {
    if (count == _collapseWordLimit) return lastEnd;
    count++;
    lastEnd = m.end;
  }
  return -1;
}

class _CollapsibleMessageText extends StatefulWidget {
  const _CollapsibleMessageText({
    required this.text,
    required this.isOwn,
    required this.builder,
  });

  final String text;
  final bool isOwn;
  final Widget Function(String shown) builder;

  @override
  State<_CollapsibleMessageText> createState() =>
      _CollapsibleMessageTextState();
}

class _CollapsibleMessageTextState extends State<_CollapsibleMessageText> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _chatCollapseSignal.addListener(_collapse);
  }

  @override
  void dispose() {
    _chatCollapseSignal.removeListener(_collapse);
    super.dispose();
  }

  void _collapse() {
    if (_expanded && mounted) setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final cut = _collapseCutIndex(widget.text);
    if (cut < 0) return widget.builder(widget.text);

    final shown =
        _expanded ? widget.text : '${widget.text.substring(0, cut)}...';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.builder(shown),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
            child: Text(
              _expanded ? 'See less' : 'See more',
              style: TextStyle(
                color: widget.isOwn ? Colors.white : Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedBubbleEntrance extends StatefulWidget {
  const _AnimatedBubbleEntrance({required this.child});
  final Widget child;

  @override
  State<_AnimatedBubbleEntrance> createState() =>
      _AnimatedBubbleEntranceState();
}

class _AnimatedBubbleEntranceState extends State<_AnimatedBubbleEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
      child: FadeTransition(
        opacity: _controller,
        child: widget.child,
      ),
    );
  }
}

class _SwipeToReplyWrapper extends StatefulWidget {
  const _SwipeToReplyWrapper({
    required this.child,
    required this.isOwn,
    required this.onReplyTriggered,
    this.enabled = true,
  });

  final Widget child;
  final bool isOwn;
  final VoidCallback onReplyTriggered;
  final bool enabled;

  @override
  State<_SwipeToReplyWrapper> createState() => _SwipeToReplyWrapperState();
}

class _SwipeToReplyWrapperState extends State<_SwipeToReplyWrapper> {
  double _dragExtent = 0;
  static const double _threshold = 64;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragExtent =
              (_dragExtent + details.delta.dx).clamp(0.0, _threshold + 20);
        });
      },
      onHorizontalDragEnd: (details) {
        if (_dragExtent >= _threshold) {
          widget.onReplyTriggered();
        }
        setState(() => _dragExtent = 0);
      },
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          if (_dragExtent > 8)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Opacity(
                opacity: (_dragExtent / _threshold).clamp(0.0, 1.0),
                child: const Icon(Icons.reply, color: Color(0xFF935CCC)),
              ),
            ),
          Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _ReactionPickerBar extends StatefulWidget {
  const _ReactionPickerBar({
    required this.onSelected,
    required this.alignEnd,
  });

  final void Function(String emoji) onSelected;
  final bool alignEnd;

  @override
  State<_ReactionPickerBar> createState() => _ReactionPickerBarState();
}

class _ReactionPickerBarState extends State<_ReactionPickerBar>
    with SingleTickerProviderStateMixin {
  static const _quickEmojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
  static const _moreEmojis = [
    '😍',
    '😡',
    '👏',
    '🔥',
    '🎉',
    '🙌',
    '😅',
    '😎',
    '🤔',
    '😴',
    '😱',
    '💯',
    '✅',
    '❌',
    '👀',
    '🥳',
    '💔',
    '🤝',
  ];

  late final AnimationController _controller;
  bool _showingMore = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _emojiButton(String emoji, int index) {
    final delay = (index * 0.04).clamp(0.0, 0.5);
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(delay, (delay + 0.5).clamp(0.0, 1.0),
          curve: Curves.easeOutBack),
    );
    return ScaleTransition(
      scale: animation,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => widget.onSelected(emoji),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(emoji, style: const TextStyle(fontSize: 26)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emojis = _showingMore ? _moreEmojis : _quickEmojis;

    return ScaleTransition(
      scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
      alignment: widget.alignEnd ? Alignment.bottomRight : Alignment.bottomLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (var i = 0; i < emojis.length; i++) _emojiButton(emojis[i], i),
            if (!_showingMore)
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => setState(() => _showingMore = true),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.add, size: 22, color: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(int index) {
    final start = index * 0.2;
    final end = (start + 0.4).clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Interval(start, end, curve: Curves.easeInOut)
            .transform(_controller.value);
        final bounce = -4 * (1 - (2 * t - 1).abs());
        return Transform.translate(
          offset: Offset(0, bounce),
          child: child,
        );
      },
      child: Container(
        width: 7,
        height: 7,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: const BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [_dot(0), _dot(1), _dot(2)],
    );
  }
}

class _HighlightPulse extends StatefulWidget {
  const _HighlightPulse({
    required this.child,
    required this.highlight,
    required this.highlightToken,
  });

  final Widget child;
  final bool highlight;
  final int highlightToken;

  @override
  State<_HighlightPulse> createState() => _HighlightPulseState();
}

class _HighlightPulseState extends State<_HighlightPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _opacity = Tween<double>(begin: 0.55, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    if (widget.highlight) _controller.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant _HighlightPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlight &&
        (!oldWidget.highlight ||
            widget.highlightToken != oldWidget.highlightToken)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            if (_controller.value > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFF2C230).withOpacity(_opacity.value),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      child: widget.child,
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isOwn,
    required this.isRead,
    required this.ownBubbleColor,
    required this.otherBubbleColor,
    required this.replyAuthorName,
    required this.senderName,
    required this.senderColor,
    required this.timeLabel,
    required this.showTimestamp,
    required this.currentUserId,
    required this.currentUserPhoneNumber,
    required this.conversationId,
    required this.onImageTap,
    required this.onReply,
    required this.selectionMode,
    required this.onEnterSelection,
    required this.isHighlighted,
    required this.highlightToken,
    required this.starred,
    this.onReplyTap,
  });

  final MessagesRow message;
  final bool isOwn;
  final bool isRead;
  final Color ownBubbleColor;
  final Color otherBubbleColor;
  final String replyAuthorName;
  final String? senderName;
  final Color senderColor;
  final String timeLabel;
  final bool showTimestamp;
  final String currentUserId;
  final String currentUserPhoneNumber;
  final String conversationId;
  final void Function(List<String> urls, int startIndex) onImageTap;
  final Future Function(String messageId, String content, bool isOwn) onReply;
  final bool selectionMode;
  final void Function(String messageId, String action) onEnterSelection;
  final bool isHighlighted;
  final int highlightToken;
  final bool starred;
  final void Function(String messageId)? onReplyTap;

  BorderRadius get _radius => BorderRadius.only(
        topLeft: const Radius.circular(16),
        topRight: const Radius.circular(16),
        bottomLeft: Radius.circular(isOwn ? 16 : 4),
        bottomRight: Radius.circular(isOwn ? 4 : 16),
      );

  Widget _forwardedTag() {
    if (message.isForwarded != true) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.reply_all_outlined,
              size: 13, color: isOwn ? Colors.white70 : Colors.black45),
          const SizedBox(width: 4),
          Text('Forwarded',
              style: TextStyle(
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                  color: isOwn ? Colors.white70 : Colors.black45)),
        ],
      ),
    );
  }

  Widget _replyPreview() {
    final hasReply = message.replyToMessageId != null &&
        message.replyToMessageId!.isNotEmpty;
    if (!hasReply) return const SizedBox.shrink();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: selectionMode
          ? null
          : () => onReplyTap?.call(message.replyToMessageId!),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: (isOwn ? Colors.white : ownBubbleColor).withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(
              color: isOwn ? Colors.white : ownBubbleColor,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.replyToIsOwn == true ? 'You' : replyAuthorName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isOwn ? Colors.white : ownBubbleColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              message.replyToContent ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isOwn ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusReplyPreview(BuildContext context) {
    final statusId = message.replyToStatusId;
    if (statusId == null || statusId.isEmpty) return const SizedBox.shrink();

    final mediaUrl = message.replyToStatusMediaUrl ?? '';
    final mediaType = message.replyToStatusMediaType ?? '';

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _StatusPreviewViewer(statusId: statusId),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: (isOwn ? Colors.white : ownBubbleColor).withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(
              color: isOwn ? Colors.white : ownBubbleColor,
              width: 3,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mediaUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: mediaType == 'video'
                    ? Container(
                        width: 36,
                        height: 36,
                        color: Colors.black26,
                        alignment: Alignment.center,
                        child: const Icon(Icons.videocam,
                            size: 18, color: Colors.white70),
                      )
                    : Image.network(
                        mediaUrl,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 36,
                          height: 36,
                          color: Colors.black12,
                        ),
                      ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                'Replied to a status',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isOwn ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Small thumbnail that uploadStagedAssets stores next to every new photo
  // as "<name>_thumb.jpg". Older photos have none, so this falls back to the
  // full image when the thumbnail does not exist.
  Widget _gridThumb(String url, {double? height}) {
    final dot = url.lastIndexOf('.');
    final slash = url.lastIndexOf('/');
    final thumb = (dot > slash && url.contains('/upload_media/'))
        ? '${url.substring(0, dot)}_thumb.jpg'
        : url;
    return Image.network(
      thumb,
      fit: BoxFit.cover,
      height: height,
      errorBuilder: (_, __, ___) =>
          Image.network(url, fit: BoxFit.cover, height: height),
    );
  }

  Widget _imageGrid(List<String> urls) {
    final count = urls.length;

    if (count == 2) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 200,
          height: 260,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: selectionMode ? null : () => onImageTap(urls, 0),
                  child: _gridThumb(urls[0], height: double.infinity),
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: GestureDetector(
                  onTap: selectionMode ? null : () => onImageTap(urls, 1),
                  child: _gridThumb(urls[1], height: double.infinity),
                ),
              ),
            ],
          ),
        ),
      );
    }

    const tileGap = 3.0;
    const gridSize = 200.0;
    final shown = count > 4 ? 4 : count;
    final extra = count - 4;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: gridSize,
        height: gridSize,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: tileGap,
            mainAxisSpacing: tileGap,
          ),
          itemCount: shown,
          itemBuilder: (context, i) {
            final isLastOverlay = i == 3 && extra > 0;
            return GestureDetector(
              onTap: selectionMode ? null : () => onImageTap(urls, i),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _gridThumb(urls[i]),
                  if (isLastOverlay)
                    Container(
                      color: Colors.black.withOpacity(0.45),
                      alignment: Alignment.center,
                      child: Text(
                        '+$extra',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _singleImage(String url, [String? thumbUrl]) {
    // The bubble loads the small thumbnail for speed; tapping opens the
    // full quality image. Falls back to the full image if there is no
    // thumbnail (older messages) or it fails to load.
    final hasThumb = (thumbUrl ?? '').isNotEmpty;
    final shown = hasThumb ? thumbUrl! : url;
    return GestureDetector(
      onTap: selectionMode ? null : () => onImageTap([url], 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 244,
          height: 244,
          child: Image.network(
            shown,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : Container(color: const Color(0xFFE5E7EB)),
            errorBuilder: (_, __, ___) => hasThumb
                ? Image.network(url, fit: BoxFit.cover)
                : Container(color: const Color(0xFFE5E7EB)),
          ),
        ),
      ),
    );
  }

  Widget _documentBubble(BuildContext context) {
    final name = (message.content ?? '').trim().isEmpty
        ? 'Document'
        : message.content!.trim();
    return AbsorbPointer(
      absorbing: selectionMode,
      child: custom_widgets.DocumentMessageCard(
        width: 244,
        url: message.mediaUrl ?? '',
        name: name,
        sizeBytes: message.mediaSizeBytes,
        pages: message.getField<int>('media_pages'),
        thumbnailUrl: message.thumbnailUrl,
      ),
    );
  }

  Widget _content(BuildContext context) {
    switch (message.messageType) {
      case 'image':
        return _singleImage(message.mediaUrl ?? '', message.thumbnailUrl);
      case 'image_group':
        return _imageGrid(message.mediaUrls);
      case 'video':
        return _videoBubble(context);
      case 'document':
        return _documentBubble(context);
      case 'voice_note':
        return custom_widgets.VoiceNoteBubble(
          width: 220,
          height: 56,
          audioUrl: message.mediaUrl ?? '',
          durationSeconds: message.durationSeconds ?? 0,
          avatarUrl: '',
          isOwnMessage: isOwn,
        );
      case 'call':
        return _callContent(context);
      case 'gift_card':
        return _giftCardContent(context);
      default:
        return _richMessageContent(context, message.content ?? '');
    }
  }

  // Call summary bubble (WhatsApp-style): "Voice call · 2:14", "Voice call ·
  // No answer" on the caller's own side, "Missed voice call" / "Declined
  // voice call" on the other side. `message.content` is written by
  // endCall/declineCall as "<voice|video>:<answered|missed|declined>", and
  // `message.durationSeconds` is only set when the call was answered.
  Widget _callContent(BuildContext context) {
    final parts = (message.content ?? 'voice:missed').split(':');
    final callType = parts.isNotEmpty ? parts[0] : 'voice';
    final outcome = parts.length > 1 ? parts[1] : 'missed';
    final isVideo = callType == 'video';
    final isMissedOrDeclined = outcome == 'missed' || outcome == 'declined';

    String label;
    if (outcome == 'answered') {
      final secs = message.durationSeconds ?? 0;
      final m = secs ~/ 60;
      final s = secs % 60;
      label =
          '${isVideo ? 'Video' : 'Voice'} call · $m:${s.toString().padLeft(2, '0')}';
    } else if (outcome == 'declined') {
      label = isOwn
          ? '${isVideo ? 'Video' : 'Voice'} call · Declined'
          : 'Declined ${isVideo ? 'video' : 'voice'} call';
    } else {
      label = isOwn
          ? '${isVideo ? 'Video' : 'Voice'} call · No answer'
          : 'Missed ${isVideo ? 'video' : 'voice'} call';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isVideo ? Icons.videocam : Icons.call,
          size: 18,
          color: isMissedOrDeclined
              ? (isOwn ? Colors.white70 : const Color(0xFFE91414))
              : (isOwn ? Colors.white : Colors.black87),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isOwn ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _giftCardContent(BuildContext context) {
    Map<String, dynamic> data;
    try {
      data = jsonDecode(message.content ?? '{}') as Map<String, dynamic>;
    } catch (_) {
      data = {};
    }

    final rawAmount = data['amount'];
    final amount = rawAmount is num
        ? rawAmount
        : num.tryParse(rawAmount?.toString() ?? '') ?? 0;
    final amountLabel = amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
    final code = (data['code'] ?? '').toString();

    final amountBlock = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          amountLabel,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        Text(
          'SCHATZ',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 10,
            color: FlutterFlowTheme.of(context).primary,
          ),
        ),
      ],
    );

    if (isOwn) {
      // Compact back view: what the sender's own bubble shows.
      return Container(
        width: 185.7,
        height: 109.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: Image.asset(
              'assets/images/WhatsApp_Image_2026-10-26_at_9.41.55_AM.jpeg',
            ).image,
          ),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: FlutterFlowTheme.of(context).alternate),
        ),
        child: Align(
          alignment: AlignmentDirectional(1.0, -1.0),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 5.0, 0.0),
            child: amountBlock,
          ),
        ),
      );
    }

    // Front/detail view: what the recipient's bubble shows, with the code.
    return Container(
      width: 290.0,
      height: 180.0,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image: Image.asset(
            'assets/images/WhatsApp_Image_2026-10-26_at_7.31.03_AM.png',
          ).image,
        ),
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: AlignmentDirectional(1.0, -1.0),
            child: Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 12.0, 0.0),
              child: amountBlock,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 21.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 16.0),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied')),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: FaIcon(
                      FaIconData(const IconData(0xf0c5,
                          fontFamily: 'FontAwesomeRegular',
                          fontPackage: 'font_awesome_flutter')),
                      color: FlutterFlowTheme.of(context).primary,
                      size: 12.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IsoCode? _callerIsoCode() {
    try {
      final normalized = currentUserPhoneNumber.startsWith('+')
          ? currentUserPhoneNumber
          : '+$currentUserPhoneNumber';
      return PhoneNumber.parse(normalized).isoCode;
    } catch (_) {
      return null;
    }
  }

  Widget _richMessageContent(BuildContext context, String text) {
    return _CollapsibleMessageText(
      text: text,
      isOwn: isOwn,
      builder: (shown) => _buildRichContent(context, shown),
    );
  }

  Widget _buildRichContent(BuildContext context, String text) {
    final baseStyle = TextStyle(
      color: isOwn ? Colors.white : Colors.black87,
      fontSize: 15,
    );

    final matches = _findTappableMatches(text, _callerIsoCode());

    String? firstLinkUrl;
    for (final m in matches) {
      if (m.isLink) {
        firstLinkUrl = m.value;
        break;
      }
    }

    Widget textWidget;
    if (matches.isEmpty) {
      textWidget = Text(text, style: baseStyle);
    } else {
      final spans = <InlineSpan>[];
      var cursor = 0;
      for (final match in matches) {
        if (match.start > cursor) {
          spans.add(TextSpan(text: text.substring(cursor, match.start)));
        }
        final displayText = text.substring(match.start, match.end);
        spans.add(
          TextSpan(
            text: displayText,
            style: baseStyle.copyWith(
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w700,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (match.isLink) {
                  _openExternalLink(match.value);
                } else {
                  _handlePhoneNumberTap(context, match.value, displayText);
                }
              },
          ),
        );
        cursor = match.end;
      }
      if (cursor < text.length) {
        spans.add(TextSpan(text: text.substring(cursor)));
      }
      textWidget = RichText(text: TextSpan(style: baseStyle, children: spans));
    }

    if (firstLinkUrl == null) {
      return textWidget;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        textWidget,
        _LinkPreviewCard(url: firstLinkUrl, isOwn: isOwn),
      ],
    );
  }

  Future<void> _handlePhoneNumberTap(
      BuildContext context, String normalizedNumber, String rawText) async {
    final matchRows = await SupaFlow.client
        .from('profiles')
        .select('id, full_name, avatar_url')
        .eq('phone_number', normalizedNumber)
        .limit(1);

    if (matchRows.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$rawText is not on SchatzApp')),
      );
      return;
    }

    final profile = matchRows.first;
    final targetUserId = profile['id'] as String;
    if (targetUserId == currentUserId) return;

    final targetAvatar = (profile['avatar_url'] as String?) ?? '';
    final targetFullName = (profile['full_name'] as String?) ?? '';

    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _PhoneNumberActionSheet(
        pageContext: context,
        currentUserId: currentUserId,
        targetUserId: targetUserId,
        normalizedNumber: normalizedNumber,
        displayNumber: rawText,
        targetAvatarUrl: targetAvatar,
        targetFullName: targetFullName,
      ),
    );
  }

  Widget _videoBubble(BuildContext context) {
    return GestureDetector(
      onTap: selectionMode
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _FullVideoViewer(url: message.mediaUrl ?? ''),
                ),
              ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: _VideoPreviewTile(
          key: ValueKey('vid_${message.id}'),
          url: message.mediaUrl ?? '',
          thumbnailUrl: message.thumbnailUrl,
          durationSeconds: message.mediaDurationSeconds,
        ),
      ),
    );
  }

  void _openOptions(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black26,
      barrierDismissible: true,
      barrierLabel: 'options',
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (dialogContext, anim1, anim2) {
        return SafeArea(
          child: Align(
            alignment: isOwn ? Alignment.bottomRight : Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: isOwn ? 0 : 16,
                right: isOwn ? 16 : 0,
                bottom: 90,
              ),
              child: Column(
                crossAxisAlignment:
                    isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ReactionPickerBar(
                    alignEnd: isOwn,
                    onSelected: (emoji) async {
                      Navigator.pop(dialogContext);
                      if (message.id != null) {
                        await _setReaction(emoji);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  MessageOptionsSheet(
                    messageId: message.id ?? '',
                    messageType: message.messageType ?? 'text',
                    messageContent: message.content ?? '',
                    mediaUrl: message.mediaUrl ?? '',
                    isOwn: isOwn,
                    isPinned: message.isPinned == true,
                    isImportant: starred,
                    currentUserId: currentUserId,
                    otherUserId: message.senderId ?? '',
                    conversationId: conversationId,
                    onReply: onReply,
                    onEnterSelection: (id, action) async =>
                        onEnterSelection(id, action),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _setReaction(String emoji) async {
    if (message.id == null) return;
    try {
      await SupaFlow.client.from('message_reactions').upsert({
        'message_id': message.id,
        'user_id': currentUserId,
        'emoji': emoji,
      }, onConflict: 'message_id,user_id');
    } catch (e) {
      debugPrint('_setReaction failed: $e');
    }
  }

  Future<void> _clearMyReaction() async {
    if (message.id == null) return;
    try {
      await SupaFlow.client
          .from('message_reactions')
          .delete()
          .eq('message_id', message.id!)
          .eq('user_id', currentUserId);
    } catch (e) {
      debugPrint('_clearMyReaction failed: $e');
    }
  }

  Widget _reactionsBadge() {
    if (message.id == null) return const SizedBox.shrink();
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _reactionsStreamFor(message.id!),
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const [];
        if (rows.isEmpty) return const SizedBox.shrink();

        final counts = <String, int>{};
        for (final row in rows) {
          final emoji = row['emoji'] as String? ?? '';
          if (emoji.isEmpty) continue;
          counts[emoji] = (counts[emoji] ?? 0) + 1;
        }
        if (counts.isEmpty) return const SizedBox.shrink();

        final topEmojis = counts.keys.take(3).join();
        final myReacted = rows.any((r) => r['user_id'] == currentUserId);

        return Padding(
          padding: const EdgeInsets.only(top: 2),
          child: GestureDetector(
            onTap: myReacted ? _clearMyReaction : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: myReacted
                    ? Border.all(color: const Color(0xFF935CCC), width: 1)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                rows.length > 1 ? '$topEmojis ${rows.length}' : topEmojis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMedia = message.messageType == 'image' ||
        message.messageType == 'image_group' ||
        message.messageType == 'video';
    final hasCaption =
        isMedia && message.content != null && message.content!.isNotEmpty;
    final isStarred = starred;

    return GestureDetector(
      onLongPress: (selectionMode || _isLocalPending(message.id))
          ? null
          : () => _openOptions(context),
      child: Column(
        crossAxisAlignment:
            isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _HighlightPulse(
            highlight: isHighlighted,
            highlightToken: highlightToken,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              padding: EdgeInsets.all(isMedia ? 3 : 8),
              constraints: const BoxConstraints(maxWidth: 260),
              decoration: BoxDecoration(
                color: isOwn ? ownBubbleColor : otherBubbleColor,
                borderRadius: _radius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isOwn && senderName != null)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          isMedia ? 6 : 0, isMedia ? 4 : 0, 6, 3),
                      child: Text(
                        senderName!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: senderColor,
                        ),
                      ),
                    ),
                  _forwardedTag(),
                  _replyPreview(),
                  _statusReplyPreview(context),
                  _content(context),
                  if (hasCaption)
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 6, left: 4, right: 4, bottom: 2),
                      child: Text(
                        message.content!,
                        style: TextStyle(
                          color: isOwn ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          _reactionsBadge(),
          if (isStarred || showTimestamp)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.28),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isStarred) ...[
                      const Icon(Icons.star,
                          size: 10, color: Color(0xFFF2B705)),
                      const SizedBox(width: 3),
                    ],
                    if (showTimestamp) ...[
                      if (message.isEdited == true) ...[
                        const Text(
                          'edited',
                          style: TextStyle(
                              fontSize: 9,
                              color: Colors.white70,
                              fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(width: 3),
                      ],
                      Text(
                        timeLabel,
                        style:
                            const TextStyle(fontSize: 9, color: Colors.white),
                      ),
                      if (_isLocalPending(message.id)) ...[
                        const SizedBox(width: 3),
                        Icon(
                            message.data['local_status'] == 'failed'
                                ? Icons.error_outline
                                : Icons.schedule,
                            size: 10,
                            color: message.data['local_status'] == 'failed'
                                ? const Color(0xFFFF6B6B)
                                : Colors.white70),
                      ],
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MultiForwardSheet extends StatefulWidget {
  const _MultiForwardSheet({
    required this.currentUserId,
    required this.messages,
  });

  final String currentUserId;
  final List<MessagesRow> messages;

  @override
  State<_MultiForwardSheet> createState() => _MultiForwardSheetState();
}

class _MultiForwardSheetState extends State<_MultiForwardSheet> {
  bool _loading = true;
  List<Map<String, dynamic>> _friends = [];
  final Set<String> _selectedIds = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await SupaFlow.client
        .from('contacts')
        .select(
            'contact_user_id, profiles!contacts_contact_user_id_fkey(full_name, avatar_url)')
        .eq('owner_id', widget.currentUserId)
        .not('contact_user_id', 'is', null);

    final friends = rows
        .where((row) => row['profiles'] != null)
        .map((row) => {
              'id': row['contact_user_id'] as String,
              'fullName': (row['profiles']['full_name'] as String?) ?? '',
              'avatarUrl': (row['profiles']['avatar_url'] as String?) ?? '',
            })
        .toList();

    if (!mounted) return;
    setState(() {
      _friends = friends;
      _loading = false;
    });
  }

  void _toggle(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _confirmForward() {
    if (_selectedIds.isEmpty) return;
    final targets = _selectedIds.toList();
    final senderId = widget.currentUserId;
    final messagesToForward = widget.messages;

    Navigator.pop(context);

    Future(() async {
      await Future.wait(targets.map((targetUserId) async {
        final conversationId =
            await findOrCreateConversation(senderId, targetUserId);
        for (final m in messagesToForward) {
          await SupaFlow.client.from('messages').insert({
            'conversation_id': conversationId,
            'sender_id': senderId,
            'message_type': m.messageType ?? 'text',
            'content':
                (m.content != null && m.content!.isNotEmpty) ? m.content : null,
            'media_url': (m.mediaUrl != null && m.mediaUrl!.isNotEmpty)
                ? m.mediaUrl
                : null,
            'is_forwarded': true,
          });
        }
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _friends
        .where((f) => (f['fullName'] as String)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Forward ${widget.messages.length} message${widget.messages.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: const InputDecoration(
                  hintText: 'Search contacts...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text('No contacts found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final f = filtered[i];
                          final id = f['id'] as String;
                          final selected = _selectedIds.contains(id);
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundImage:
                                  (f['avatarUrl'] as String).isNotEmpty
                                      ? NetworkImage(f['avatarUrl'])
                                      : null,
                            ),
                            title: Text(f['fullName']),
                            trailing: Checkbox(
                              value: selected,
                              activeColor: const Color(0xFF935CCC),
                              onChanged: (_) => _toggle(id),
                            ),
                            onTap: () => _toggle(id),
                          );
                        },
                      ),
          ),
          if (_selectedIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: _confirmForward,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF935CCC),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Forward',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({
    required this.currentUserId,
    required this.messages,
  });

  final String currentUserId;
  final List<MessagesRow> messages;

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  bool _loading = true;
  List<Map<String, dynamic>> _friends = [];
  final Set<String> _selectedIds = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await SupaFlow.client
        .from('contacts')
        .select(
            'contact_user_id, profiles!contacts_contact_user_id_fkey(full_name, avatar_url)')
        .eq('owner_id', widget.currentUserId)
        .not('contact_user_id', 'is', null);

    final friends = rows
        .where((row) => row['profiles'] != null)
        .map((row) => {
              'id': row['contact_user_id'] as String,
              'fullName': (row['profiles']['full_name'] as String?) ?? '',
              'avatarUrl': (row['profiles']['avatar_url'] as String?) ?? '',
            })
        .toList();

    if (!mounted) return;
    setState(() {
      _friends = friends;
      _loading = false;
    });
  }

  void _toggle(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _shareToOtherApps() {
    Navigator.pop(context);
    final parts = widget.messages.map((m) {
      if (m.content != null && m.content!.isNotEmpty) return m.content!;
      if (m.mediaUrl != null && m.mediaUrl!.isNotEmpty) return m.mediaUrl!;
      return '';
    }).where((s) => s.isNotEmpty);
    final text = parts.join('\n');
    if (text.isNotEmpty) {
      Share.share(text);
    }
  }

  void _confirmShareToContacts() {
    if (_selectedIds.isEmpty) return;
    final targets = _selectedIds.toList();
    final senderId = widget.currentUserId;
    final messagesToShare = widget.messages;

    Navigator.pop(context);

    Future(() async {
      await Future.wait(targets.map((targetUserId) async {
        final conversationId =
            await findOrCreateConversation(senderId, targetUserId);
        for (final m in messagesToShare) {
          await SupaFlow.client.from('messages').insert({
            'conversation_id': conversationId,
            'sender_id': senderId,
            'message_type': m.messageType ?? 'text',
            'content':
                (m.content != null && m.content!.isNotEmpty) ? m.content : null,
            'media_url': (m.mediaUrl != null && m.mediaUrl!.isNotEmpty)
                ? m.mediaUrl
                : null,
            // No is_forwarded flag — this is a plain share, not a forward.
          });
        }
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _friends
        .where((f) => (f['fullName'] as String)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Share ${widget.messages.length} message${widget.messages.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: _shareToOtherApps,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.ios_share, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('Share to other apps',
                      style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: const InputDecoration(
                  hintText: 'Search contacts...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text('No contacts found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final f = filtered[i];
                          final id = f['id'] as String;
                          final selected = _selectedIds.contains(id);
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundImage:
                                  (f['avatarUrl'] as String).isNotEmpty
                                      ? NetworkImage(f['avatarUrl'])
                                      : null,
                            ),
                            title: Text(f['fullName']),
                            trailing: Checkbox(
                              value: selected,
                              activeColor: const Color(0xFF935CCC),
                              onChanged: (_) => _toggle(id),
                            ),
                            onTap: () => _toggle(id),
                          );
                        },
                      ),
          ),
          if (_selectedIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: _confirmShareToContacts,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF935CCC),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Share',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FullImageViewer extends StatefulWidget {
  const _FullImageViewer({
    required this.urls,
    required this.initialIndex,
    this.conversationId,
    this.currentUserId,
  });
  final List<String> urls;
  final int initialIndex;
  final String? conversationId;
  final String? currentUserId;

  @override
  State<_FullImageViewer> createState() => _FullImageViewerState();
}

class _FullImageViewerState extends State<_FullImageViewer> {
  late PageController _controller;
  late int _currentIndex;
  bool _loadingEdit = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openEditor() async {
    if (_loadingEdit) return;
    setState(() => _loadingEdit = true);
    try {
      final response = await http.get(Uri.parse(widget.urls[_currentIndex]));
      if (response.statusCode != 200) return;
      final bytes = Uint8List.fromList(response.bodyBytes);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EditImagePage(
            imageBytes: bytes,
            mode: 'resend',
            conversationId: widget.conversationId,
            currentUserId: widget.currentUserId,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingEdit = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.urls.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, i) => Center(
                child: InteractiveViewer(
                  panEnabled: false,
                  scaleEnabled: true,
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Image.network(widget.urls[i]),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: InkWell(
                onTap: _openEditor,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: _loadingEdit
                      ? const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
            ),
            if (widget.urls.length > 1)
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.urls.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusPreviewViewer extends StatefulWidget {
  const _StatusPreviewViewer({required this.statusId});
  final String statusId;

  @override
  State<_StatusPreviewViewer> createState() => _StatusPreviewViewerState();
}

class _StatusPreviewViewerState extends State<_StatusPreviewViewer> {
  late Future<StatusesRow?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<StatusesRow?> _load() async {
    final rows = await StatusesTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', widget.statusId),
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    final expiresAt = row.expiresAt;
    if (expiresAt != null && expiresAt.isBefore(DateTime.now())) return null;
    return row;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder<StatusesRow?>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                final status = snapshot.data;
                if (status == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'This status is no longer available',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ),
                  );
                }
                if (status.mediaType == 'video') {
                  return _StatusPreviewVideo(url: status.mediaUrl ?? '');
                }
                return Center(
                  child: Image.network(
                    status.mediaUrl ?? '',
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 12,
              left: 12,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Video bubble preview: real first frame (or stored thumbnail), play badge,
// duration label.
// ---------------------------------------------------------------------
class _VideoPreviewTile extends StatefulWidget {
  const _VideoPreviewTile({
    super.key,
    required this.url,
    this.thumbnailUrl,
    this.durationSeconds,
  });

  final String url;
  final String? thumbnailUrl;
  final int? durationSeconds;

  @override
  State<_VideoPreviewTile> createState() => _VideoPreviewTileState();
}

class _VideoPreviewTileState extends State<_VideoPreviewTile> {
  VideoPlayerController? _controller;
  bool _ready = false;

  bool get _hasThumb => (widget.thumbnailUrl ?? '').isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (!_hasThumb) _initFrame();
  }

  Future<void> _initFrame() async {
    if (widget.url.isEmpty) return;
    final c = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _controller = c;
    try {
      await c.initialize();
      await c.setVolume(0);
      await c.seekTo(const Duration(milliseconds: 150));
      await c.pause();
      if (!mounted) return;
      setState(() => _ready = true);
    } catch (_) {
      // Keep the dark placeholder with the play badge.
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _fmt(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    const double w = 220;
    double h = 220;
    Widget media = const SizedBox.shrink();

    if (_hasThumb) {
      media = Image.network(
        widget.thumbnailUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    } else if (_ready && _controller != null) {
      final c = _controller!;
      final aspect = c.value.aspectRatio;
      if (aspect.isFinite && aspect > 0) {
        h = (w / aspect).clamp(140.0, 300.0).toDouble();
      }
      media = FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: c.value.size.width,
          height: c.value.size.height,
          child: VideoPlayer(c),
        ),
      );
    }

    final secs = widget.durationSeconds ?? 0;
    return Container(
      width: w,
      height: h,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          media,
          Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 36),
            ),
          ),
          if (secs > 0)
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _fmt(secs),
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusPreviewVideo extends StatefulWidget {
  const _StatusPreviewVideo({required this.url});
  final String url;

  @override
  State<_StatusPreviewVideo> createState() => _StatusPreviewVideoState();
}

class _StatusPreviewVideoState extends State<_StatusPreviewVideo> {
  late VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    return Center(
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      ),
    );
  }
}

class _FullVideoViewer extends StatefulWidget {
  const _FullVideoViewer({required this.url});
  final String url;

  @override
  State<_FullVideoViewer> createState() => _FullVideoViewerState();
}

class _FullVideoViewerState extends State<_FullVideoViewer> {
  late VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: _ready
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const CircularProgressIndicator(color: Colors.white),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
            if (_ready)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                    child: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhoneNumberActionSheet extends StatefulWidget {
  const _PhoneNumberActionSheet({
    required this.pageContext,
    required this.currentUserId,
    required this.targetUserId,
    required this.normalizedNumber,
    required this.displayNumber,
    required this.targetAvatarUrl,
    required this.targetFullName,
  });

  // The chat page's own BuildContext, captured BEFORE this sheet was shown.
  // The sheet's own context becomes unmounted the moment it's popped, so any
  // navigation that happens after an `await` (i.e. after the sheet closes)
  // must use this context instead, or the navigation silently does nothing.
  final BuildContext pageContext;
  final String currentUserId;
  final String targetUserId;
  final String normalizedNumber;
  final String displayNumber;
  final String targetAvatarUrl;
  final String targetFullName;

  @override
  State<_PhoneNumberActionSheet> createState() =>
      _PhoneNumberActionSheetState();
}

class _PhoneNumberActionSheetState extends State<_PhoneNumberActionSheet> {
  Future<void> _openChat(BuildContext context) async {
    Navigator.pop(context);
    final conversationId = await findOrCreateConversation(
        widget.currentUserId, widget.targetUserId);
    if (!widget.pageContext.mounted) return;
    widget.pageContext.pushNamed(
      'chatpage',
      queryParameters: {
        'conversationId': serializeParam(conversationId, ParamType.String),
        'otherUserId': serializeParam(widget.targetUserId, ParamType.String),
        'displayName': serializeParam(widget.displayNumber, ParamType.String),
        'displayAvatar':
            serializeParam(widget.targetAvatarUrl, ParamType.String),
      }.withoutNulls,
    );
  }

  Future<void> _startCall(BuildContext context, String callType) async {
    Navigator.pop(context);
    final conversationId = await findOrCreateConversation(
        widget.currentUserId, widget.targetUserId);
    final callResult =
        await startCall(conversationId, widget.currentUserId, callType);
    if (callResult == null) return;
    if (!widget.pageContext.mounted) return;
    widget.pageContext.pushNamed(
      'ActiveCallScreen',
      queryParameters: {
        'callId': serializeParam(callResult.callId, ParamType.String),
        'conversationId': serializeParam(conversationId, ParamType.String),
        'calleeName': serializeParam(widget.displayNumber, ParamType.String),
        'calleeAvatar':
            serializeParam(widget.targetAvatarUrl, ParamType.String),
        'callType': serializeParam(callType, ParamType.String),
        'agoraChannelName':
            serializeParam(callResult.agoraChannelName, ParamType.String),
        'agoraToken': serializeParam(callResult.agoraToken, ParamType.String),
        'agoraUid': serializeParam(callResult.agoraUid, ParamType.int),
      }.withoutNulls,
    );
  }

  void _openInfo(BuildContext context) {
    Navigator.pop(context);
    if (!widget.pageContext.mounted) return;
    widget.pageContext.pushNamed(
      'User_profile',
      queryParameters: {
        'otherUserId': serializeParam(widget.targetUserId, ParamType.String),
      }.withoutNulls,
    );
  }

  Future<void> _createNewContact(BuildContext context) async {
    final theme = FlutterFlowTheme.of(context);
    final nameController = TextEditingController(text: widget.targetFullName);

    final savedName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.primaryBackground,
        title: Text('Save contact', style: TextStyle(color: theme.primaryText)),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: TextStyle(color: theme.primaryText),
          decoration: InputDecoration(
            hintText: 'Contact name',
            hintStyle: TextStyle(color: theme.secondaryText),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: theme.secondaryText)),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, nameController.text.trim()),
            child: Text('Save', style: TextStyle(color: theme.primary)),
          ),
        ],
      ),
    );

    if (savedName == null || savedName.isEmpty) return;

    await SupaFlow.client.from('contacts').upsert({
      'owner_id': widget.currentUserId,
      'contact_user_id': widget.targetUserId,
      'saved_name': savedName,
      'phone_number': widget.normalizedNumber,
    }, onConflict: 'owner_id,phone_number');

    if (!context.mounted) return;
    Navigator.pop(context);
    if (!widget.pageContext.mounted) return;
    ScaffoldMessenger.of(widget.pageContext).showSnackBar(
      SnackBar(content: Text('$savedName saved to your contacts')),
    );
  }

  Widget _pillButton(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final theme = FlutterFlowTheme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: theme.primaryText, size: 22),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(color: theme.primaryText, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listRow(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.primaryText),
            const SizedBox(width: 16),
            Text(label,
                style: TextStyle(color: theme.primaryText, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final hasAvatar = widget.targetAvatarUrl.isNotEmpty;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child:
                        Icon(Icons.close, size: 18, color: theme.primaryText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              width: 90,
              height: 90,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primary.withOpacity(0.85),
              ),
              child: hasAvatar
                  ? Image.network(widget.targetAvatarUrl, fit: BoxFit.cover)
                  : const Icon(Icons.person, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 14),
            Text(
              widget.displayNumber,
              style: TextStyle(
                color: theme.primaryText,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.targetFullName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '~${widget.targetFullName}',
                  style: TextStyle(color: theme.secondaryText, fontSize: 14),
                ),
              ),
            const SizedBox(height: 18),
            Row(
              children: [
                _pillButton(context, Icons.chat_bubble_outline, 'Message',
                    () => _openChat(context)),
                _pillButton(context, Icons.call_outlined, 'Voice',
                    () => _startCall(context, 'voice')),
                _pillButton(context, Icons.videocam_outlined, 'Video',
                    () => _startCall(context, 'video')),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _listRow(context, Icons.person_add_alt_1_outlined,
                      'Create new contact', () => _createNewContact(context)),
                  Divider(height: 1, color: theme.alternate),
                  _listRow(context, Icons.info_outline, 'Info',
                      () => _openInfo(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
