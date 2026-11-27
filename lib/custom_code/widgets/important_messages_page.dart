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

class _ImportantItem {
  _ImportantItem({
    required this.messageId,
    required this.conversationId,
    required this.isGroup,
    required this.otherUserId,
    required this.displayName,
    required this.avatarUrl,
    required this.previewText,
    required this.timeLabel,
    required this.createdAt,
    required this.messageType,
    required this.mediaUrls,
    this.thumbnailUrl,
    this.durationSeconds,
  });

  final String messageId;
  final String conversationId;
  final bool isGroup;
  final String? otherUserId;
  final String displayName;
  final String avatarUrl;
  final String previewText;
  final String timeLabel;
  final DateTime createdAt;
  final String messageType;
  final List<String> mediaUrls;
  final String? thumbnailUrl;
  final int? durationSeconds;

  bool get isVideo => messageType == 'video';

  bool get hasMedia =>
      (messageType == 'image' ||
          messageType == 'image_group' ||
          messageType == 'video') &&
      (mediaUrls.isNotEmpty || (thumbnailUrl ?? '').isNotEmpty);
}

class ImportantMessagesPage extends StatefulWidget {
  const ImportantMessagesPage({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
  });

  final double? width;
  final double? height;
  final String currentUserId;

  @override
  State<ImportantMessagesPage> createState() => _ImportantMessagesPageState();
}

class _ImportantMessagesPageState extends State<ImportantMessagesPage> {
  bool _loading = true;
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};
  List<_ImportantItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadImportantMessages();
  }

  String _previewFor(String? type, String? content) {
    switch (type) {
      case 'image':
        return '📷 Photo';
      case 'image_group':
        return '📷 Photos';
      case 'video':
        return '🎥 Video';
      case 'voice_note':
        return '🎤 Voice message';
      default:
        return content ?? '';
    }
  }

  Future<void> _loadImportantMessages() async {
    if (mounted) setState(() => _loading = true);
    try {
      final myConvRows = await SupaFlow.client
          .from('conversation_participants')
          .select('conversation_id')
          .eq('user_id', widget.currentUserId);
      final myConvIds =
          myConvRows.map((r) => r['conversation_id'] as String).toList();

      if (myConvIds.isEmpty) {
        if (mounted)
          setState(() {
            _items = [];
            _loading = false;
          });
        return;
      }

      final starRows = await SupaFlow.client
          .from('message_stars')
          .select('message_id')
          .eq('user_id', widget.currentUserId);
      final starredIds =
          starRows.map((r) => r['message_id'].toString()).toList();

      if (starredIds.isEmpty) {
        if (mounted)
          setState(() {
            _items = [];
            _loading = false;
          });
        return;
      }

      final msgRows = await SupaFlow.client
          .from('messages')
          .select(
              'id, conversation_id, sender_id, content, message_type, created_at, media_url, media_urls, thumbnail_url, media_duration_seconds')
          .inFilter('id', starredIds)
          .inFilter('conversation_id', myConvIds)
          .order('created_at', ascending: false);

      if (msgRows.isEmpty) {
        if (mounted)
          setState(() {
            _items = [];
            _loading = false;
          });
        return;
      }

      final convIds =
          msgRows.map((m) => m['conversation_id'] as String).toSet().toList();

      final convRows = await SupaFlow.client
          .from('conversations')
          .select('id, type, name, avatar_url, user_a_id, user_b_id')
          .inFilter('id', convIds);
      final convById = {
        for (final c in convRows) c['id'] as String: c,
      };

      final otherUserIds = <String>{};
      for (final c in convRows) {
        if (c['type'] == 'group') continue;
        final a = c['user_a_id'] as String?;
        final b = c['user_b_id'] as String?;
        final other = (a == widget.currentUserId) ? b : a;
        if (other != null) otherUserIds.add(other);
      }

      var profileById = <String, Map<String, dynamic>>{};
      if (otherUserIds.isNotEmpty) {
        final profileRows = await SupaFlow.client
            .from('profiles')
            .select('id, full_name, avatar_url, username')
            .inFilter('id', otherUserIds.toList());
        profileById = {
          for (final p in profileRows) p['id'] as String: p,
        };
      }

      // Same name rule as the chat list: saved name, then uname, then profile.
      final savedNameByUser = <String, String>{};
      if (otherUserIds.isNotEmpty) {
        try {
          final contactRows = await SupaFlow.client
              .from('contacts')
              .select('contact_user_id, saved_name')
              .eq('owner_id', widget.currentUserId)
              .inFilter('contact_user_id', otherUserIds.toList());
          for (final r in contactRows) {
            final id = r['contact_user_id'] as String?;
            final name = (r['saved_name'] as String?) ?? '';
            if (id != null && name.trim().isNotEmpty) {
              savedNameByUser[id] = name;
            }
          }
        } catch (e) {
          debugPrint('important saved names failed: $e');
        }
      }
      String cleanName(String n) => n.replaceAll(RegExp(r'\s+'), ' ').trim();

      final items = <_ImportantItem>[];
      for (final m in msgRows) {
        final conv = convById[m['conversation_id']];
        if (conv == null) continue;

        final isGroup = conv['type'] == 'group';
        String displayName;
        String avatarUrl;
        String? otherUserId;

        if (isGroup) {
          displayName = (conv['name'] as String?) ?? 'Group';
          avatarUrl = (conv['avatar_url'] as String?) ?? '';
        } else {
          final a = conv['user_a_id'] as String?;
          final b = conv['user_b_id'] as String?;
          otherUserId = (a == widget.currentUserId) ? b : a;
          final profile = profileById[otherUserId];
          final saved = savedNameByUser[otherUserId] ?? '';
          final uname = (profile?['username'] as String?) ?? '';
          final full = (profile?['full_name'] as String?) ?? '';
          displayName = cleanName(saved).isNotEmpty
              ? cleanName(saved)
              : cleanName(uname).isNotEmpty
                  ? cleanName(uname)
                  : cleanName(full).isNotEmpty
                      ? cleanName(full)
                      : 'Unknown';
          avatarUrl = (profile?['avatar_url'] as String?) ?? '';
        }

        final createdAt = DateTime.tryParse(m['created_at'] as String? ?? '') ??
            DateTime.now();

        items.add(_ImportantItem(
          messageId: m['id'] as String,
          conversationId: m['conversation_id'] as String,
          isGroup: isGroup,
          otherUserId: otherUserId,
          displayName: displayName,
          avatarUrl: avatarUrl,
          previewText: _previewFor(
              m['message_type'] as String?, m['content'] as String?),
          timeLabel: DateFormat('h:mm a').format(createdAt),
          createdAt: createdAt,
          messageType: (m['message_type'] as String?) ?? 'text',
          mediaUrls: () {
            final list = (m['media_urls'] as List?)
                    ?.map((e) => e.toString())
                    .where((e) => e.isNotEmpty)
                    .toList() ??
                <String>[];
            final single = (m['media_url'] as String?) ?? '';
            if (list.isEmpty && single.isNotEmpty) return <String>[single];
            return list;
          }(),
          thumbnailUrl: m['thumbnail_url'] as String?,
          durationSeconds: (m['media_duration_seconds'] as num?)?.toInt(),
        ));
      }

      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      debugPrint('loadImportantMessages failed: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _unmarkSelected() async {
    if (_selectedIds.isEmpty) {
      setState(() => _selectionMode = false);
      return;
    }
    final idsToRemove = Set<String>.from(_selectedIds);
    try {
      for (final id in idsToRemove) {
        await SupaFlow.client
            .from('message_stars')
            .delete()
            .eq('user_id', widget.currentUserId)
            .eq('message_id', id);
      }
    } catch (e) {
      debugPrint('unmark important failed: $e');
    }
    if (!mounted) return;
    setState(() {
      _items.removeWhere((it) => idsToRemove.contains(it.messageId));
      _selectedIds.clear();
      _selectionMode = false;
    });
  }

  void _onEditTap() {
    if (_selectionMode) {
      _unmarkSelected();
    } else {
      setState(() => _selectionMode = true);
    }
  }

  void _openItem(_ImportantItem item) {
    if (_selectionMode) {
      setState(() {
        if (_selectedIds.contains(item.messageId)) {
          _selectedIds.remove(item.messageId);
        } else {
          _selectedIds.add(item.messageId);
        }
      });
      return;
    }

    if (item.isGroup) {
      context.pushNamed(
        'Group_chatpage',
        queryParameters: {
          'groupConversationId':
              serializeParam(item.conversationId, ParamType.String),
          'groupNameParam': serializeParam(item.displayName, ParamType.String),
          'groupAvatarParam': serializeParam(item.avatarUrl, ParamType.String),
          'initialTargetMessageId':
              serializeParam(item.messageId, ParamType.String),
        }.withoutNulls,
      );
    } else {
      context.pushNamed(
        'chatpage',
        queryParameters: {
          'conversationId':
              serializeParam(item.conversationId, ParamType.String),
          'otherUserId': serializeParam(item.otherUserId, ParamType.String),
          'displayName': serializeParam(item.displayName, ParamType.String),
          'displayAvatar': serializeParam(item.avatarUrl, ParamType.String),
          'initialTargetMessageId':
              serializeParam(item.messageId, ParamType.String),
        }.withoutNulls,
      );
    }
  }

  void _openViewer(_ImportantItem item) {
    if (_selectionMode) {
      _openItem(item);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _ImportantMediaViewer(item: item)),
    );
  }

  Widget _mediaBubble(_ImportantItem item) {
    final url = item.mediaUrls.isNotEmpty ? item.mediaUrls.first : '';
    final extra = item.mediaUrls.length > 1 ? item.mediaUrls.length - 1 : 0;
    return GestureDetector(
      onTap: () => _openViewer(item),
      onLongPress: () {
        if (!_selectionMode) {
          setState(() {
            _selectionMode = true;
            _selectedIds.add(item.messageId);
          });
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF935CCC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0),
          ),
        ),
        padding: const EdgeInsets.all(4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: SizedBox(
            width: 220,
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              children: [
                item.isVideo
                    ? _ImportantVideoFrame(
                        url: url,
                        thumbnailUrl: item.thumbnailUrl,
                      )
                    : Image.network(
                        url,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: Colors.black26,
                          child: Icon(Icons.broken_image,
                              color: Colors.white70, size: 32),
                        ),
                        loadingBuilder: (c, child, progress) => progress == null
                            ? child
                            : const ColoredBox(color: Colors.black12),
                      ),
                if (item.isVideo)
                  Center(
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 32),
                    ),
                  ),
                if (extra > 0)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('+$extra',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Material(
                  color: const Color(0x7FE0E3E7),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      if (_selectionMode) {
                        setState(() {
                          _selectionMode = false;
                          _selectedIds.clear();
                        });
                      } else {
                        context.pop();
                      }
                    },
                    child: SizedBox(
                      width: 50.0,
                      height: 50.0,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: theme.primaryText,
                        size: 30.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                  child: Text(
                    'Important',
                    style: theme.headlineMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: theme.headlineMedium.fontWeight,
                        fontStyle: theme.headlineMedium.fontStyle,
                      ),
                      color: theme.primaryText,
                      fontSize: 20.0,
                      letterSpacing: 0.0,
                      fontWeight: theme.headlineMedium.fontWeight,
                      fontStyle: theme.headlineMedium.fontStyle,
                    ),
                  ),
                ),
                InkWell(
                  onTap: _items.isEmpty ? null : _onEditTap,
                  child: Container(
                    width: 70.0,
                    height: 45.0,
                    decoration: BoxDecoration(
                      color: const Color(0x7FE0E3E7),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.center,
                      child: Text(
                        _selectionMode ? 'Done' : 'Edit',
                        style: theme.bodyMedium.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontStyle: theme.bodyMedium.fontStyle,
                          ),
                          fontSize: _selectionMode ? 15.0 : 18.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontStyle: theme.bodyMedium.fontStyle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(
                        child: Text(
                          'No important messages yet',
                          style: TextStyle(
                            color: theme.secondaryText,
                            fontSize: 14.0,
                          ),
                        ),
                      )
                    : Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0.0),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: _items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 20.0),
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            final isSelected =
                                _selectedIds.contains(item.messageId);

                            return InkWell(
                              onTap: () => _openItem(item),
                              onLongPress: () {
                                if (!_selectionMode) {
                                  setState(() {
                                    _selectionMode = true;
                                    _selectedIds.add(item.messageId);
                                  });
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  if (_selectionMode)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 8.0, top: 4.0),
                                      child: Icon(
                                        isSelected
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: isSelected
                                            ? theme.primary
                                            : theme.secondaryText,
                                        size: 22.0,
                                      ),
                                    ),
                                  Container(
                                    width: 30.0,
                                    height: 30.0,
                                    decoration: BoxDecoration(
                                      color: theme.secondaryBackground,
                                      image: item.avatarUrl.isNotEmpty
                                          ? DecorationImage(
                                              fit: BoxFit.cover,
                                              image:
                                                  NetworkImage(item.avatarUrl),
                                            )
                                          : null,
                                      shape: BoxShape.circle,
                                    ),
                                    child: item.avatarUrl.isEmpty
                                        ? Center(
                                            child: Text(
                                              getInitial(item.displayName),
                                              style: TextStyle(
                                                color: theme.primaryText,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13.0,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          5.0, 0.0, 10.0, 0.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            textBaseline:
                                                TextBaseline.alphabetic,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.displayName,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      theme.bodyMedium.override(
                                                    font: GoogleFonts
                                                        .plusJakartaSans(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle: theme
                                                          .bodyMedium.fontStyle,
                                                    ),
                                                    fontSize: 15.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle: theme
                                                        .bodyMedium.fontStyle,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                item.timeLabel,
                                                style:
                                                    theme.bodyMedium.override(
                                                  font: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: theme
                                                        .bodyMedium.fontStyle,
                                                  ),
                                                  color: theme.secondaryText,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle: theme
                                                      .bodyMedium.fontStyle,
                                                ),
                                              ),
                                            ],
                                          ),
                                          item.hasMedia
                                              ? _mediaBubble(item)
                                              : Container(
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFF935CCC),
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(15.0),
                                                      topRight:
                                                          Radius.circular(15.0),
                                                      bottomRight:
                                                          Radius.circular(15.0),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    child: Text(
                                                      item.previewText,
                                                      maxLines: 5,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: theme.bodyMedium
                                                          .override(
                                                        font: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontWeight: theme
                                                              .bodyMedium
                                                              .fontWeight,
                                                          fontStyle: theme
                                                              .bodyMedium
                                                              .fontStyle,
                                                        ),
                                                        color: theme
                                                            .secondaryBackground,
                                                        letterSpacing: 0.0,
                                                        fontWeight: theme
                                                            .bodyMedium
                                                            .fontWeight,
                                                        fontStyle: theme
                                                            .bodyMedium
                                                            .fontStyle,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                        ].divide(const SizedBox(height: 10.0)),
                                      ),
                                    ),
                                  ),
                                  if (!_selectionMode)
                                    Icon(
                                      Icons.keyboard_arrow_right,
                                      color: theme.secondaryText,
                                      size: 22.0,
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// First frame (or stored thumbnail) of a video, never a bare icon.
class _ImportantVideoFrame extends StatefulWidget {
  const _ImportantVideoFrame({required this.url, this.thumbnailUrl});
  final String url;
  final String? thumbnailUrl;

  @override
  State<_ImportantVideoFrame> createState() => _ImportantVideoFrameState();
}

class _ImportantVideoFrameState extends State<_ImportantVideoFrame> {
  VideoPlayerController? _controller;
  bool _ready = false;

  bool get _hasThumb => (widget.thumbnailUrl ?? '').isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (!_hasThumb && widget.url.isNotEmpty) _init();
  }

  Future<void> _init() async {
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
      if (mounted) setState(() => _ready = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasThumb) {
      return Image.network(widget.thumbnailUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black));
    }
    final c = _controller;
    if (_ready && c != null) {
      return FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: c.value.size.width,
          height: c.value.size.height,
          child: VideoPlayer(c),
        ),
      );
    }
    return const ColoredBox(color: Colors.black);
  }
}

// Full screen viewer: pinch-zoom photos (swipe through a group), play videos.
class _ImportantMediaViewer extends StatefulWidget {
  const _ImportantMediaViewer({required this.item});
  final _ImportantItem item;

  @override
  State<_ImportantMediaViewer> createState() => _ImportantMediaViewerState();
}

class _ImportantMediaViewerState extends State<_ImportantMediaViewer> {
  VideoPlayerController? _video;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.isVideo && widget.item.mediaUrls.isNotEmpty) {
      final c = VideoPlayerController.networkUrl(
          Uri.parse(widget.item.mediaUrls.first));
      _video = c;
      c.initialize().then((_) {
        if (!mounted) return;
        setState(() => _videoReady = true);
        c.play();
      }).catchError((_) {});
      c.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (widget.item.isVideo) {
      final c = _video;
      body = (_videoReady && c != null)
          ? GestureDetector(
              onTap: () => c.value.isPlaying ? c.pause() : c.play(),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: c.value.aspectRatio,
                      child: VideoPlayer(c),
                    ),
                    if (!c.value.isPlaying)
                      const Icon(Icons.play_circle_fill,
                          color: Colors.white70, size: 72),
                  ],
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator(color: Colors.white));
    } else {
      body = PageView(
        children: [
          for (final u in widget.item.mediaUrls)
            InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Center(
                child: Image.network(u,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
                        color: Colors.white54, size: 48)),
              ),
            ),
        ],
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(child: body),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
