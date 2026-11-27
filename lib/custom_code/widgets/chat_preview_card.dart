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

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/custom_code/actions/index.dart';

class ChatPreviewCard extends StatefulWidget {
  const ChatPreviewCard({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
    required this.conversationId,
    required this.otherUserId,
    required this.displayName,
    required this.displayAvatar,
    required this.isGroup,
    required this.isPinned,
    required this.isArchived,
    required this.pinnedCount,
    required this.onOpenChat,
    required this.onChanged,
  });

  final double? width;
  final double? height;
  final String currentUserId;
  final String conversationId;
  final String otherUserId;
  final String displayName;
  final String displayAvatar;
  final bool isGroup;
  final bool isPinned;
  final bool isArchived;
  final int pinnedCount;
  final Future Function() onOpenChat;
  final Future Function() onChanged;

  @override
  State<ChatPreviewCard> createState() => _ChatPreviewCardState();
}

class _PreviewTheme {
  const _PreviewTheme(this.sender, this.receiver, this.wallpaper);
  final Color sender;
  final Color receiver;
  final String wallpaper;
}

class _ChatPreviewCardState extends State<ChatPreviewCard> {
  static const int _maxPinnedChats = 4;

  static const Map<String, _PreviewTheme> _themes = {
    'theme1': _PreviewTheme(Color(0xFFED50E4), Color(0xFFF1F5F9),
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/nexu-xidy5i/assets/hs3ncoawy90q/schatzapp_wallpaper..png'),
    'theme2': _PreviewTheme(Color(0xFFED50E4), Color(0xFFF1F5F9),
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/nexu-xidy5i/assets/okzb2earxxuk/.4.png'),
    'theme3': _PreviewTheme(Color(0xFF3B82F6), Color(0xFFFFFFFF),
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/nexu-xidy5i/assets/pt8bmcae9po5/schatzapp_wallpaper.3.png'),
    'theme4': _PreviewTheme(Color(0xFF0E8BAB), Color(0xFFE2E8F0),
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/nexu-xidy5i/assets/f3oes5poj8fa/schatzapp_wallpaper.2.png'),
    'theme5': _PreviewTheme(Color(0xFF935CCC), Color(0xFFF0F0F0),
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/nexu-xidy5i/assets/f62pmt3pghhs/schatzapp_wallpaper.png'),
  };

  // Only the newest messages are shown, so the preview can never scroll
  // through a whole long chat.
  static const int _previewMessageLimit = 25;
  final GlobalKey _captureKey = GlobalKey();
  bool _busy = false;
  bool _iBlocked = false;

  Stream<List<MessagesRow>>? _messagesStream;
  Stream<Map<String, String?>>? _appearanceStream;

  @override
  void initState() {
    super.initState();
    _loadBlockState();
    _messagesStream = SupaFlow.client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eqOrNull('conversation_id', widget.conversationId)
        .order('created_at', ascending: false)
        .limit(40)
        .map((list) => list
            .map((item) => MessagesRow(item))
            .where((m) => m.isDeleted != true)
            .where((m) => !m.deletedForUserIds.contains(widget.currentUserId))
            .toList());

    _appearanceStream = SupaFlow.client
        .from('conversation_participants')
        .stream(primaryKey: ['id'])
        .eqOrNull('conversation_id', widget.conversationId)
        .map((list) {
          final row = list.firstWhere(
            (r) => r['user_id'] == widget.currentUserId,
            orElse: () => const {},
          );
          return {
            'theme': row['chat_theme'] as String?,
            'wallpaper': row['chat_wallpaper_url'] as String?,
          };
        });
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

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _sameMinute(DateTime a, DateTime b) =>
      _sameDay(a, b) && a.hour == b.hour && a.minute == b.minute;

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _toggleArchive() async {
    await SupaFlow.client
        .from('conversation_participants')
        .update({'is_archived': !widget.isArchived})
        .eq('conversation_id', widget.conversationId)
        .eq('user_id', widget.currentUserId);
    await widget.onChanged();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _togglePin() async {
    if (!widget.isPinned && widget.pinnedCount >= _maxPinnedChats) {
      _toast('You can only pin up to $_maxPinnedChats chats');
      return;
    }
    await SupaFlow.client
        .from('conversation_participants')
        .update({'is_pinned': !widget.isPinned})
        .eq('conversation_id', widget.conversationId)
        .eq('user_id', widget.currentUserId);
    await widget.onChanged();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _loadBlockState() async {
    if (widget.isGroup) return;
    try {
      final res = await SupaFlow.client
          .rpc('block_status', params: {'p_other': widget.otherUserId});
      if (!mounted) return;
      setState(() => _iBlocked = (res ?? '').toString() == 'i_blocked');
    } catch (_) {}
  }

  Future<void> _block() async {
    if (_iBlocked) {
      final done =
          await unblockUser(context, widget.currentUserId, widget.otherUserId);
      if (!done) return;
    } else {
      await blockUser(context, widget.currentUserId, widget.otherUserId);
    }
    await widget.onChanged();
    if (mounted) Navigator.pop(context);
  }

  Widget _actionTile(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    final c = color ?? Colors.black87;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(color: c, fontSize: 14.5)),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, thickness: 1, color: Color(0xFFEDEDED));

  Widget _dateChip(DateTime d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.38),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(_dateLabel(d),
              style: const TextStyle(fontSize: 12, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _content(MessagesRow m, bool isOwn) {
    final textColor = isOwn ? Colors.white : Colors.black87;
    switch (m.messageType) {
      case 'image':
      case 'image_group':
        final urls = m.mediaUrls;
        final url = urls.isNotEmpty ? urls.first : (m.mediaUrl ?? '');
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Image.network(url,
                  width: 170,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      width: 170, height: 150, color: Colors.black12)),
              if (urls.length > 1)
                Container(
                  margin: const EdgeInsets.all(6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('+${urls.length - 1}',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 11)),
                ),
            ],
          ),
        );
      case 'video':
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 170,
            height: 150,
            color: Colors.black,
            alignment: Alignment.center,
            child: const Icon(Icons.play_circle_fill,
                color: Colors.white, size: 40),
          ),
        );
      case 'gift_card':
        String label = '🎁 Schatz Gift';
        try {
          final data = jsonDecode(m.content ?? '') as Map<String, dynamic>;
          label = '🎁 ${data['amount'] ?? ''} Schatz Gift';
        } catch (_) {}
        return Text(label, style: TextStyle(color: textColor, fontSize: 13.5));
      case 'voice_note':
        return Text('🎤 Voice message',
            style: TextStyle(color: textColor, fontSize: 13.5));
      default:
        return Text(m.content ?? '',
            style: TextStyle(color: textColor, fontSize: 13.5));
    }
  }

  Widget _bubble(MessagesRow m, _PreviewTheme t, bool showTime) {
    final isOwn = m.senderId == widget.currentUserId;
    final isMedia = m.messageType == 'image' ||
        m.messageType == 'image_group' ||
        m.messageType == 'video';
    final created = m.createdAt ?? DateTime.now();
    return Column(
      crossAxisAlignment:
          isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: EdgeInsets.all(isMedia ? 3 : 8),
          constraints: const BoxConstraints(maxWidth: 220),
          decoration: BoxDecoration(
            color: isOwn ? t.sender : t.receiver,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isOwn ? 16 : 4),
              bottomRight: Radius.circular(isOwn ? 4 : 16),
            ),
          ),
          child: _content(m, isOwn),
        ),
        if (showTime)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.28),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(DateFormat('h:mm a').format(created),
                  style: const TextStyle(fontSize: 9, color: Colors.white)),
            ),
          ),
      ],
    );
  }

  Widget _messages() {
    return StreamBuilder<Map<String, String?>>(
      stream: _appearanceStream,
      builder: (context, themeSnap) {
        final themeKey = themeSnap.data?['theme'];
        final t = _themes[themeKey] ?? _themes['theme5']!;
        final wallpaper = (themeSnap.data?['wallpaper'] ?? '').isNotEmpty
            ? themeSnap.data!['wallpaper']!
            : t.wallpaper;
        return RepaintBoundary(
          key: _captureKey,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(wallpaper), fit: BoxFit.cover),
            ),
            child: StreamBuilder<List<MessagesRow>>(
              stream: _messagesStream,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Newest first; the ListView is reversed so index 0 sits at the bottom.
                final sorted = snap.data!
                  ..sort((a, b) => (b.createdAt ?? DateTime(0))
                      .compareTo(a.createdAt ?? DateTime(0)));
                final msgs = sorted.take(_previewMessageLimit).toList();
                if (msgs.isEmpty) {
                  return const Center(
                      child: Text('No messages yet',
                          style: TextStyle(color: Colors.black54)));
                }
                return ListView.builder(
                  reverse: true,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final m = msgs[i];
                    final created = m.createdAt ?? DateTime.now();
                    final newer = i > 0 ? msgs[i - 1] : null;
                    final older = i + 1 < msgs.length ? msgs[i + 1] : null;
                    final showTime = newer == null ||
                        newer.senderId != m.senderId ||
                        !_sameMinute(created, newer.createdAt ?? created);
                    final showDate = older == null ||
                        !_sameDay(created, older.createdAt ?? created);
                    final isOwn = m.senderId == widget.currentUserId;
                    return Column(
                      crossAxisAlignment: isOwn
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (showDate) _dateChip(created),
                        _bubble(m, t, showTime),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // The messages exactly as they appear in the preview, as a PNG.
  Future<Uint8List?> _capture() async {
    try {
      final boundary = _captureKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  // Puts the chat picture on a designed story background (9:16).
  Future<Uint8List> _composeStory(Uint8List chatPng) async {
    const double w = 1080, h = 1920;
    final palettes = <List<Color>>[
      [
        const Color(0xFF6A3DE8),
        const Color(0xFFC45BD9),
        const Color(0xFFFF8FA3)
      ],
      [
        const Color(0xFF1B6EF3),
        const Color(0xFF22C1C3),
        const Color(0xFF9BF2C5)
      ],
      [
        const Color(0xFFFF6B6B),
        const Color(0xFFFF9F43),
        const Color(0xFFFFD66B)
      ],
      [
        const Color(0xFF0F2C67),
        const Color(0xFF6A3DE8),
        const Color(0xFFE95FD1)
      ],
      [
        const Color(0xFF11998E),
        const Color(0xFF38EF7D),
        const Color(0xFFD4FC79)
      ],
    ];
    final p = palettes[DateTime.now().millisecond % palettes.length];

    final codec = await ui.instantiateImageCodec(chatPng);
    final chat = (await codec.getNextFrame()).image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, w, h));

    // Gradient background with soft glows.
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = ui.Gradient.linear(
            const Offset(0, 0), const Offset(w, h), p, [0.0, 0.55, 1.0]),
    );
    canvas.drawCircle(
      const Offset(w * 0.9, h * 0.08),
      380,
      Paint()
        ..shader = ui.Gradient.radial(const Offset(w * 0.9, h * 0.08), 380,
            [Colors.white.withOpacity(0.28), Colors.white.withOpacity(0)]),
    );
    canvas.drawCircle(
      const Offset(w * 0.05, h * 0.92),
      460,
      Paint()
        ..shader = ui.Gradient.radial(const Offset(w * 0.05, h * 0.92), 460,
            [Colors.white.withOpacity(0.22), Colors.white.withOpacity(0)]),
    );

    // Card geometry.
    const double cardX = 70, cardW = w - 140, pad = 30, headerH = 130;
    final innerW = cardW - pad * 2;
    final scale = innerW / chat.width;
    double imgH = chat.height * scale;
    const double maxImgH = 1180;
    Rect src =
        Rect.fromLTWH(0, 0, chat.width.toDouble(), chat.height.toDouble());
    if (imgH > maxImgH) {
      // Keep the newest messages (the bottom of the picture).
      final keep = maxImgH / scale;
      src = Rect.fromLTWH(0, chat.height - keep, chat.width.toDouble(), keep);
      imgH = maxImgH;
    }
    final cardH = headerH + imgH + pad;
    final cardY = (h - cardH) / 2 - 40;
    final card = RRect.fromRectAndRadius(
        Rect.fromLTWH(cardX, cardY, cardW, cardH), const Radius.circular(56));

    canvas.drawRRect(
        card.shift(const Offset(0, 18)),
        Paint()
          ..color = Colors.black.withOpacity(0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 36));
    canvas.drawRRect(card, Paint()..color = Colors.white);

    // Header: initial circle + name.
    final name = widget.displayName.trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final circleC = Offset(cardX + pad + 44, cardY + headerH / 2 + 4);
    canvas.drawCircle(circleC, 44, Paint()..color = const Color(0xFF935CCC));
    final ip = TextPainter(
      text: TextSpan(
          text: initial,
          style: const TextStyle(
              fontSize: 46, fontWeight: FontWeight.w800, color: Colors.white)),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    ip.paint(canvas, circleC - Offset(ip.width / 2, ip.height / 2));

    final np = TextPainter(
      text: TextSpan(
          text: name,
          style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B1230))),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    )..layout(maxWidth: innerW - 130);
    np.paint(canvas, Offset(circleC.dx + 44 + 24, circleC.dy - np.height / 2));

    // Chat picture with rounded corners.
    final imgRect = Rect.fromLTWH(cardX + pad, cardY + headerH, innerW, imgH);
    canvas.save();
    canvas
        .clipRRect(RRect.fromRectAndRadius(imgRect, const Radius.circular(32)));
    canvas.drawImageRect(
        chat, src, imgRect, Paint()..filterQuality = FilterQuality.high);
    canvas.restore();

    // Brand footer.
    final bp = TextPainter(
      text: const TextSpan(
          text: 'SchatzApp',
          style: TextStyle(
              fontSize: 64, fontWeight: FontWeight.w800, color: Colors.white)),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    bp.paint(canvas, Offset((w - bp.width) / 2, cardY + cardH + 70));
    final sp = TextPainter(
      text: TextSpan(
          text: 'Connect, Share, Together.',
          style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.88))),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    sp.paint(
        canvas, Offset((w - sp.width) / 2, cardY + cardH + 70 + bp.height + 6));

    final picture = recorder.endRecording();
    final out = await picture.toImage(w.toInt(), h.toInt());
    final data = await out.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<void> _saveImage() async {
    if (_busy) return;
    _busy = true;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await _capture();
      if (bytes == null) {
        messenger.showSnackBar(
            const SnackBar(content: Text('Could not create the image')));
      } else if (kIsWeb) {
        messenger.showSnackBar(const SnackBar(
            content: Text('Saving images is available in the phone app')));
      } else {
        await Gal.putImageBytes(bytes);
        messenger.showSnackBar(
            const SnackBar(content: Text('Image saved to your gallery')));
      }
    } catch (_) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Could not save. Check photo permission.')));
    }
    _busy = false;
  }

  Future<void> _shareToStory() async {
    if (_busy) return;
    _busy = true;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final bytes = await _capture();
      if (bytes == null) {
        messenger.showSnackBar(
            const SnackBar(content: Text('Could not create the image')));
      } else {
        // Put the picture in the story draft, then open the Create Story
        // page so the user can add a caption, tags, privacy and duration.
        final app = FFAppState();
        final designed = await _composeStory(bytes);
        app.storyDraftOriginalImages = [base64Encode(designed)];
        app.storyDraftEditedImages = [''];
        app.storyDraftMediaTypes = ['image'];
        app.storyDraftCaptions = [''];
        app.storyDraftCarousel = [false];
        app.storyDraftEditingIndex = -1;
        app.storyDraftDurationHours = 24;
        app.storyDraftRefreshTick = app.storyDraftRefreshTick + 1;
        if (mounted) Navigator.pop(context);
        router.pushNamed('create_a_story');
      }
    } catch (_) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Could not share to your story. Try again.')));
    }
    _busy = false;
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.78;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: widget.width ?? MediaQuery.of(context).size.width * 0.86,
          constraints: BoxConstraints(maxHeight: maxH),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 18),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    await widget.onOpenChat();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFFEFEBF2),
                          backgroundImage: (widget.displayAvatar
                                      .toLowerCase()
                                      .startsWith('http') &&
                                  !widget.displayAvatar
                                      .toLowerCase()
                                      .contains('unsplash.com'))
                              ? NetworkImage(widget.displayAvatar)
                              : null,
                          child: (widget.displayAvatar
                                      .toLowerCase()
                                      .startsWith('http') &&
                                  !widget.displayAvatar
                                      .toLowerCase()
                                      .contains('unsplash.com'))
                              ? null
                              : const Icon(Icons.person_outline,
                                  color: Color(0xFF935CCC), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(widget.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.black38),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: maxH * 0.5, child: _messages()),
                _actionTile(
                    widget.isArchived
                        ? Icons.unarchive_outlined
                        : Icons.archive_outlined,
                    widget.isArchived ? 'Unarchive' : 'Archive',
                    _toggleArchive),
                _divider(),
                _actionTile(
                    widget.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    widget.isPinned ? 'Unpin' : 'Pin',
                    _togglePin),
                if (!widget.isGroup) ...[
                  _divider(),
                  _actionTile(
                      _iBlocked ? Icons.lock_open_rounded : Icons.block_sharp,
                      _iBlocked ? 'Unblock' : 'Block',
                      _block,
                      color: _iBlocked
                          ? const Color(0xFF935CCC)
                          : const Color(0xFFE91414)),
                ],
                _divider(),
                _actionTile(Icons.playlist_add_circle_outlined,
                    'Share to story', _shareToStory),
                _divider(),
                _actionTile(Icons.save_alt, 'Save Image', _saveImage),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
