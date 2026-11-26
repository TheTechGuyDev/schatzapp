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

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/gestures.dart';

class _StarMsg {
  _StarMsg({
    required this.id,
    required this.senderId,
    required this.type,
    required this.content,
    required this.mediaUrl,
    required this.mediaUrls,
    required this.thumbUrl,
    required this.sizeBytes,
    required this.createdAt,
  });
  final String id;
  final String senderId;
  final String type;
  final String content;
  final String mediaUrl;
  final List<String> mediaUrls;
  final String thumbUrl;
  final int sizeBytes;
  final DateTime createdAt;
}

class ChatImportantView extends StatefulWidget {
  const ChatImportantView({
    super.key,
    this.width,
    this.height,
    required this.conversationId,
    required this.currentUserId,
  });

  final double? width;
  final double? height;
  final String conversationId;
  final String currentUserId;

  @override
  State<ChatImportantView> createState() => _ChatImportantViewState();
}

class _ChatImportantViewState extends State<ChatImportantView> {
  static const Color _purple = Color(0xFF935CCC);

  // Same colours as the chat itself, so the page looks like the chat.
  static const Map<String, List<Color>> _themes = {
    'theme1': [Color(0xFFED50E4), Color(0xFFF1F5F9)],
    'theme2': [Color(0xFFED50E4), Color(0xFFF1F5F9)],
    'theme3': [Color(0xFF3B82F6), Color(0xFFFFFFFF)],
    'theme4': [Color(0xFF0E8BAB), Color(0xFFE2E8F0)],
    'theme5': [Color(0xFF935CCC), Color(0xFFF0F0F0)],
  };

  bool _loading = true;
  bool _isGroup = false;
  String _chatName = '';
  String _chatAvatar = '';
  String _otherUserId = '';
  Color _ownColor = const Color(0xFF935CCC);
  Color _otherColor = const Color(0xFFF0F0F0);
  List<_StarMsg> _items = [];
  final Map<String, String> _names = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _clean(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

  Future<void> _load() async {
    try {
      final conv = await SupaFlow.client
          .from('conversations')
          .select('id, type, name, avatar_url, user_a_id, user_b_id')
          .eq('id', widget.conversationId)
          .limit(1);
      if (conv.isNotEmpty) {
        final c = conv.first;
        _isGroup = c['type'] == 'group';
        if (_isGroup) {
          _chatName = _clean((c['name'] as String?) ?? 'Group');
          _chatAvatar = (c['avatar_url'] as String?) ?? '';
        } else {
          final a = c['user_a_id'] as String?;
          final b = c['user_b_id'] as String?;
          _otherUserId = ((a == widget.currentUserId) ? b : a) ?? '';
        }
      }

      final me = await SupaFlow.client
          .from('conversation_participants')
          .select('chat_theme')
          .eq('conversation_id', widget.conversationId)
          .eq('user_id', widget.currentUserId)
          .limit(1);
      if (me.isNotEmpty) {
        final t = _themes[me.first['chat_theme'] as String?];
        if (t != null) {
          _ownColor = t[0];
          _otherColor = t[1];
        }
      }

      final stars = await SupaFlow.client
          .from('message_stars')
          .select('message_id')
          .eq('user_id', widget.currentUserId);
      final starIds = stars.map((r) => r['message_id'].toString()).toList();

      final items = <_StarMsg>[];
      if (starIds.isNotEmpty) {
        final rows = await SupaFlow.client
            .from('messages')
            .select(
                'id, sender_id, message_type, content, media_url, media_urls, thumbnail_url, media_size_bytes, created_at, is_deleted, deleted_for_user_ids')
            .eq('conversation_id', widget.conversationId)
            .inFilter('id', starIds)
            .order('created_at', ascending: false);
        for (final m in rows) {
          if (m['is_deleted'] == true) continue;
          final hidden = (m['deleted_for_user_ids'] as List?)
                  ?.contains(widget.currentUserId) ==
              true;
          if (hidden) continue;
          items.add(_StarMsg(
            id: m['id'].toString(),
            senderId: (m['sender_id'] ?? '').toString(),
            type: (m['message_type'] as String?) ?? 'text',
            content: (m['content'] as String?) ?? '',
            mediaUrl: (m['media_url'] as String?) ?? '',
            mediaUrls: (m['media_urls'] as List?)
                    ?.map((e) => e.toString())
                    .where((e) => e.isNotEmpty)
                    .toList() ??
                <String>[],
            thumbUrl: (m['thumbnail_url'] as String?) ?? '',
            sizeBytes: (m['media_size_bytes'] as num?)?.toInt() ?? 0,
            createdAt:
                DateTime.tryParse('${m['created_at'] ?? ''}')?.toLocal() ??
                    DateTime.now(),
          ));
        }
      }

      // Sender names: saved name, then username, then full name.
      final ids = <String>{
        ...items.map((e) => e.senderId),
        if (_otherUserId.isNotEmpty) _otherUserId,
      }..remove(widget.currentUserId);
      ids.removeWhere((e) => e.isEmpty);
      if (ids.isNotEmpty) {
        final saved = await SupaFlow.client
            .from('contacts')
            .select('contact_user_id, saved_name')
            .eq('owner_id', widget.currentUserId)
            .inFilter('contact_user_id', ids.toList());
        final savedBy = <String, String>{
          for (final r in saved)
            if (r['contact_user_id'] != null)
              r['contact_user_id'] as String:
                  _clean((r['saved_name'] ?? '').toString())
        };
        final profs = await SupaFlow.client
            .from('profiles')
            .select('id, full_name, username, avatar_url')
            .inFilter('id', ids.toList());
        for (final p in profs) {
          final id = p['id'] as String;
          final s = savedBy[id] ?? '';
          final u = _clean((p['username'] ?? '').toString());
          final f = _clean((p['full_name'] ?? '').toString());
          _names[id] = s.isNotEmpty
              ? s
              : (u.isNotEmpty ? u : (f.isNotEmpty ? f : 'Member'));
          if (!_isGroup && id == _otherUserId) {
            _chatAvatar = (p['avatar_url'] as String?) ?? '';
          }
        }
        if (!_isGroup && _otherUserId.isNotEmpty) {
          _chatName = _names[_otherUserId] ?? '';
        }
      }

      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      debugPrint('chat important load failed: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _unstar(_StarMsg m) async {
    try {
      await SupaFlow.client
          .from('message_stars')
          .delete()
          .eq('user_id', widget.currentUserId)
          .eq('message_id', m.id);
      if (mounted) setState(() => _items.removeWhere((e) => e.id == m.id));
    } catch (_) {}
  }

  void _openOriginal(_StarMsg m) {
    if (_isGroup) {
      context.pushNamed('Group_chatpage', queryParameters: {
        'groupConversationId': widget.conversationId,
        'conversationId': widget.conversationId,
        'groupNameParam': _chatName,
        'displayName': _chatName,
        'groupAvatarParam': _chatAvatar,
        'displayAvatar': _chatAvatar,
        'initialTargetMessageId': m.id,
      });
    } else {
      context.pushNamed('chatpage', queryParameters: {
        'conversationId': widget.conversationId,
        'otherUserId': _otherUserId,
        'displayName': _chatName,
        'displayAvatar': _chatAvatar,
        'initialTargetMessageId': m.id,
      });
    }
  }

  void _openFile(_StarMsg m) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => DocumentPreviewScreen(
            url: m.mediaUrl, name: m.content.isEmpty ? 'File' : m.content)));
  }

  void _openMedia(List<String> urls, int index, {bool video = false}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            _StarMediaViewer(urls: urls, index: index, video: video)));
  }

  Future<void> _openLink(String url) async {
    var u = url;
    if (u.toLowerCase().startsWith('www.')) u = 'https://$u';
    try {
      await launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  String _size(int b) {
    if (b <= 0) return '';
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(0)} KB';
    return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    final t = DateTime(now.year, now.month, now.day);
    final x = DateTime(d.year, d.month, d.day);
    final diff = t.difference(x).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('MMMM d, yyyy').format(d);
  }

  // ----------------------------- Bubble content -----------------------------
  Widget _content(_StarMsg m, bool own, Color textColor) {
    switch (m.type) {
      case 'image':
      case 'image_group':
        final urls = m.mediaUrls.isNotEmpty
            ? m.mediaUrls
            : [if (m.mediaUrl.isNotEmpty) m.mediaUrl];
        if (urls.isEmpty)
          return Text('📷 Photo', style: TextStyle(color: textColor));
        final shown = urls.take(4).toList();
        final more = urls.length - shown.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: shown.length == 1 ? 1 : 2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: shown.length == 1 ? 1.3 : 1,
              children: [
                for (var i = 0; i < shown.length; i++)
                  GestureDetector(
                    onTap: () => _openMedia(urls, i),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(fit: StackFit.expand, children: [
                        cachedNetworkImage(shown[i],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const ColoredBox(
                                color: Colors.black12,
                                child: Icon(Icons.broken_image))),
                        if (i == shown.length - 1 && more > 0)
                          Container(
                              color: Colors.black45,
                              alignment: Alignment.center,
                              child: Text('+$more',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700))),
                      ]),
                    ),
                  ),
              ],
            ),
            if (m.content.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(m.content, style: TextStyle(color: textColor)),
              ),
          ],
        );
      case 'video':
        return GestureDetector(
          onTap: () => _openMedia([m.mediaUrl], 0, video: true),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 1.4,
              child: Stack(fit: StackFit.expand, children: [
                m.thumbUrl.isNotEmpty
                    ? cachedNetworkImage(m.thumbUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const ColoredBox(color: Colors.black))
                    : const ColoredBox(color: Colors.black),
                Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                        color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 30),
                  ),
                ),
              ]),
            ),
          ),
        );
      case 'document':
        final name = m.content.isEmpty ? 'File' : m.content;
        final ext =
            name.contains('.') ? name.split('.').last.toUpperCase() : 'FILE';
        return Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: (own ? Colors.white : _purple).withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.insert_drive_file_rounded,
                  color: own ? Colors.white : _purple),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: textColor, fontWeight: FontWeight.w600)),
                  Text(
                      [ext, _size(m.sizeBytes)]
                          .where((e) => e.isNotEmpty)
                          .join('  •  '),
                      style: TextStyle(
                          color: textColor.withOpacity(0.7), fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Open file',
              icon: Icon(Icons.open_in_new_rounded, color: textColor, size: 20),
              onPressed: () => _openFile(m),
            ),
          ],
        );
      case 'voice_note':
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.mic_rounded, color: textColor, size: 20),
          const SizedBox(width: 6),
          Text('Voice message', style: TextStyle(color: textColor)),
        ]);
      case 'gift_card':
        return Text('🎁 Schatz Gift Card', style: TextStyle(color: textColor));
      case 'call':
        return Text('📞 Call', style: TextStyle(color: textColor));
      default:
        return _LinkText(
          text: m.content,
          color: textColor,
          linkColor: own ? Colors.white : _purple,
          onLink: _openLink,
        );
    }
  }

  Widget _card(_StarMsg m) {
    final own = m.senderId == widget.currentUserId;
    final bubble = own ? _ownColor : _otherColor;
    final textColor = own ? Colors.white : Colors.black87;
    final who = own ? 'Me' : (_names[m.senderId] ?? 'Member');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Align(
        alignment: own ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.82),
          child: Column(
            crossAxisAlignment:
                own ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 4, right: 4),
                child: Text(who,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade600)),
              ),
              GestureDetector(
                onTap: () => _openOriginal(m),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  decoration: BoxDecoration(
                    color: bubble,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(own ? 16 : 4),
                      bottomRight: Radius.circular(own ? 4 : 16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _content(m, own, textColor),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(DateFormat('h:mm a').format(m.createdAt),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: textColor.withOpacity(0.7))),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _unstar(m),
                            child: Icon(Icons.star_rounded,
                                size: 18,
                                color: own
                                    ? Colors.white
                                    : const Color(0xFFF5B301)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    String? lastDay;
    for (final m in _items) {
      final day = _dayLabel(m.createdAt);
      if (day != lastDay) {
        children.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(day,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
            ),
          ),
        ));
        lastDay = day;
      }
      children.add(_card(m));
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, size: 28),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text('Important',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20, fontWeight: FontWeight.w700)),
                          if (_chatName.isNotEmpty)
                            Text(_chatName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _items.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                  'No important messages in this chat yet.\nLong press a message and choose Important.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 15)),
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.only(bottom: 24),
                            children: children,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Text with tappable links.
class _LinkText extends StatefulWidget {
  const _LinkText({
    required this.text,
    required this.color,
    required this.linkColor,
    required this.onLink,
  });
  final String text;
  final Color color;
  final Color linkColor;
  final void Function(String url) onLink;

  @override
  State<_LinkText> createState() => _LinkTextState();
}

class _LinkTextState extends State<_LinkText> {
  final List<TapGestureRecognizer> _rec = [];

  @override
  void dispose() {
    for (final r in _rec) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _rec) {
      r.dispose();
    }
    _rec.clear();
    final spans = <InlineSpan>[];
    final pattern =
        RegExp(r'((https?:\/\/)|(www\.))[^\s]+', caseSensitive: false);
    var last = 0;
    for (final m in pattern.allMatches(widget.text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: widget.text.substring(last, m.start)));
      }
      final url = m.group(0)!;
      final r = TapGestureRecognizer()..onTap = () => widget.onLink(url);
      _rec.add(r);
      spans.add(TextSpan(
        text: url,
        recognizer: r,
        style: TextStyle(
            color: widget.linkColor, decoration: TextDecoration.underline),
      ));
      last = m.end;
    }
    if (last < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(last)));
    }
    return Text.rich(
      TextSpan(
          style: TextStyle(color: widget.color, fontSize: 15), children: spans),
    );
  }
}

// Full screen viewer for photos and a video.
class _StarMediaViewer extends StatefulWidget {
  const _StarMediaViewer(
      {required this.urls, required this.index, required this.video});
  final List<String> urls;
  final int index;
  final bool video;

  @override
  State<_StarMediaViewer> createState() => _StarMediaViewerState();
}

class _StarMediaViewerState extends State<_StarMediaViewer> {
  VideoPlayerController? _c;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    if (widget.video) {
      final c = cachedVideoController(widget.urls.first);
      _c = c;
      c.initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        c.play();
      }).catchError((_) {});
      c.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (widget.video) {
      final c = _c!;
      body = !_ready
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : GestureDetector(
              onTap: () => c.value.isPlaying ? c.pause() : c.play(),
              child: Center(
                child: Stack(alignment: Alignment.center, children: [
                  AspectRatio(
                      aspectRatio: c.value.aspectRatio, child: VideoPlayer(c)),
                  if (!c.value.isPlaying)
                    const Icon(Icons.play_circle_fill,
                        color: Colors.white70, size: 72),
                ]),
              ),
            );
    } else {
      body = PageView.builder(
        controller: PageController(initialPage: widget.index),
        itemCount: widget.urls.length,
        itemBuilder: (_, i) => InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Center(
            child: cachedNetworkImage(widget.urls[i],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
                    color: Colors.white54, size: 48)),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0),
      body: SafeArea(child: body),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
