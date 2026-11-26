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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';

class _MediaEntry {
  _MediaEntry({
    required this.url,
    required this.isVideo,
    required this.createdAt,
    required this.messageId,
    required this.senderId,
    this.thumbnailUrl,
    this.durationSeconds,
  });
  final String messageId;
  final String senderId;
  String get key => '$messageId|$url';
  final String url;
  final bool isVideo;
  final DateTime createdAt;
  final String? thumbnailUrl;
  final int? durationSeconds;
}

class _FileEntry {
  _FileEntry({
    required this.name,
    required this.url,
    required this.sizeBytes,
    required this.createdAt,
  });
  final String name;
  final String url;
  final int sizeBytes;
  final DateTime createdAt;
}

class _LinkEntry {
  _LinkEntry({required this.url, required this.createdAt});
  final String url;
  final DateTime createdAt;
}

class MediaLinksFilesView extends StatefulWidget {
  const MediaLinksFilesView({
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
  State<MediaLinksFilesView> createState() => _MediaLinksFilesViewState();
}

class _MediaLinksFilesViewState extends State<MediaLinksFilesView>
    with SingleTickerProviderStateMixin {
  static const Color _purple = Color(0xFF935CCC);

  late final TabController _tabs;
  bool _loading = true;
  String _title = '';
  int _mediaFilter = 0; // 0 all, 1 photos, 2 videos
  List<_MediaEntry> _media = [];
  List<_FileEntry> _files = [];
  List<_LinkEntry> _links = [];

  // Selection mode (Media tab)
  final Set<String> _selected = {};
  bool get _selecting => _selected.isNotEmpty;
  String _otherUserId = '';
  String _otherAvatar = '';
  bool _isGroup = false;
  String _groupAvatar = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  String _clean(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

  Future<void> _loadTitle() async {
    try {
      final conv = await SupaFlow.client
          .from('conversations')
          .select('type, name')
          .eq('id', widget.conversationId)
          .limit(1);
      if (conv.isNotEmpty && conv.first['type'] == 'group') {
        _isGroup = true;
        _title = _clean((conv.first['name'] as String?) ?? 'Group');
        return;
      }
      final parts = await SupaFlow.client
          .from('conversation_participants')
          .select('user_id')
          .eq('conversation_id', widget.conversationId)
          .neq('user_id', widget.currentUserId)
          .limit(1);
      if (parts.isEmpty) return;
      final otherId = parts.first['user_id'] as String;
      _otherUserId = otherId;

      try {
        final p = await SupaFlow.client
            .from('profiles')
            .select('avatar_url')
            .eq('id', otherId)
            .limit(1);
        if (p.isNotEmpty)
          _otherAvatar = (p.first['avatar_url'] as String?) ?? '';
      } catch (_) {}
      final contacts = await SupaFlow.client
          .from('contacts')
          .select('saved_name')
          .eq('owner_id', widget.currentUserId)
          .eq('contact_user_id', otherId)
          .limit(1);
      if (contacts.isNotEmpty) {
        final saved = _clean((contacts.first['saved_name'] as String?) ?? '');
        if (saved.isNotEmpty) {
          _title = saved;
          return;
        }
      }
      final prof = await SupaFlow.client
          .from('profiles')
          .select('full_name, username, avatar_url')
          .eq('id', otherId)
          .limit(1);
      if (prof.isNotEmpty) {
        _otherAvatar = (prof.first['avatar_url'] as String?) ?? '';
        final uname = _clean((prof.first['username'] as String?) ?? '');
        final full = _clean((prof.first['full_name'] as String?) ?? '');
        _title = uname.isNotEmpty ? uname : full;
      }
    } catch (e) {
      debugPrint('media title failed: $e');
    }
  }

  Future<void> _load() async {
    await _loadTitle();
    final media = <_MediaEntry>[];
    final files = <_FileEntry>[];
    final links = <_LinkEntry>[];
    try {
      final rows = await SupaFlow.client
          .from('messages')
          .select(
              'id, sender_id, message_type, content, media_url, media_urls, thumbnail_url, media_duration_seconds, media_size_bytes, created_at, deleted_for_user_ids')
          .eq('conversation_id', widget.conversationId)
          .inFilter(
              'message_type', ['image', 'image_group', 'video', 'document'])
          .not('is_deleted', 'eq', true)
          .order('created_at', ascending: false);

      for (final m in rows) {
        final hidden = (m['deleted_for_user_ids'] as List?)
                ?.contains(widget.currentUserId) ==
            true;
        if (hidden) continue;
        final type = (m['message_type'] as String?) ?? '';
        final mid = '${m['id']}';
        final sid = '${m['sender_id'] ?? ''}';
        final createdAt =
            DateTime.tryParse('${m['created_at'] ?? ''}')?.toLocal() ??
                DateTime.now();
        final single = (m['media_url'] as String?) ?? '';
        final list = (m['media_urls'] as List?)
                ?.map((e) => e.toString())
                .where((e) => e.isNotEmpty)
                .toList() ??
            <String>[];

        if (type == 'image' || type == 'image_group') {
          final urls = list.isNotEmpty ? list : [if (single.isNotEmpty) single];
          for (final u in urls) {
            media.add(_MediaEntry(
                url: u,
                isVideo: false,
                createdAt: createdAt,
                messageId: mid,
                senderId: sid));
          }
        } else if (type == 'video') {
          if (single.isNotEmpty) {
            media.add(_MediaEntry(
              url: single,
              isVideo: true,
              createdAt: createdAt,
              messageId: mid,
              senderId: sid,
              thumbnailUrl: m['thumbnail_url'] as String?,
              durationSeconds: (m['media_duration_seconds'] as num?)?.toInt(),
            ));
          }
        } else if (type == 'document') {
          if (single.isNotEmpty) {
            var name = _clean((m['content'] as String?) ?? '');
            if (name.isEmpty)
              name = Uri.decodeComponent(single.split('/').last);
            files.add(_FileEntry(
              name: name,
              url: single,
              sizeBytes: (m['media_size_bytes'] as num?)?.toInt() ?? 0,
              createdAt: createdAt,
            ));
          }
        }
      }
    } catch (e) {
      debugPrint('media load failed: $e');
    }

    try {
      final textRows = await SupaFlow.client
          .from('messages')
          .select('content, created_at, deleted_for_user_ids')
          .eq('conversation_id', widget.conversationId)
          .eq('message_type', 'text')
          .not('is_deleted', 'eq', true)
          .or('content.ilike.%http%,content.ilike.%www.%')
          .order('created_at', ascending: false);
      final pattern =
          RegExp(r'((https?:\/\/)|(www\.))[^\s]+', caseSensitive: false);
      for (final m in textRows) {
        final hidden = (m['deleted_for_user_ids'] as List?)
                ?.contains(widget.currentUserId) ==
            true;
        if (hidden) continue;
        final createdAt =
            DateTime.tryParse('${m['created_at'] ?? ''}')?.toLocal() ??
                DateTime.now();
        for (final match
            in pattern.allMatches((m['content'] as String?) ?? '')) {
          links.add(_LinkEntry(url: match.group(0)!, createdAt: createdAt));
        }
      }
    } catch (e) {
      debugPrint('links load failed: $e');
    }

    if (!mounted) return;
    setState(() {
      _media = media;
      _files = files;
      _links = links;
      _loading = false;
    });
  }

  // ----------------------------- Selection -----------------------------
  List<_MediaEntry> _visibleMedia() => _media.where((e) {
        if (_mediaFilter == 1) return !e.isVideo;
        if (_mediaFilter == 2) return e.isVideo;
        return true;
      }).toList();

  void _toggle(_MediaEntry e) {
    setState(() {
      if (!_selected.add(e.key)) _selected.remove(e.key);
    });
  }

  void _selectAll() {
    final all = _visibleMedia();
    setState(() {
      if (_selected.length == all.length) {
        _selected.clear();
      } else {
        _selected
          ..clear()
          ..addAll(all.map((e) => e.key));
      }
    });
  }

  void _toast(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  void _goToMessage() {
    if (_selected.length != 1) return;
    final entry = _media.firstWhere((e) => e.key == _selected.first);
    final id = entry.messageId;
    setState(() => _selected.clear());
    if (_isGroup) {
      context.pushNamed('Group_chatpage', queryParameters: {
        'groupConversationId': widget.conversationId,
        'conversationId': widget.conversationId,
        'groupNameParam': _title,
        'displayName': _title,
        'groupAvatarParam': _groupAvatar,
        'displayAvatar': _groupAvatar,
        'initialTargetMessageId': id,
      });
    } else {
      context.pushNamed('chatpage', queryParameters: {
        'conversationId': widget.conversationId,
        'otherUserId': _otherUserId,
        'displayName': _title,
        'displayAvatar': _otherAvatar,
        'initialTargetMessageId': id,
      });
    }
  }

  Future<void> _deleteSelected() async {
    final chosen = _media.where((e) => _selected.contains(e.key)).toList();
    if (chosen.isEmpty) return;
    final allMine = chosen.every((e) => e.senderId == widget.currentUserId);
    final ids = chosen.map((e) => e.messageId).toSet().toList();
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            'Delete ${chosen.length} item${chosen.length == 1 ? '' : 's'}?'),
        content: const Text(
            'Photos sent together in one message are deleted together.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, 'me'),
              child: const Text('Delete for me',
                  style: TextStyle(color: _purple))),
          if (allMine)
            TextButton(
                onPressed: () => Navigator.pop(ctx, 'all'),
                child: const Text('Delete for everyone',
                    style: TextStyle(color: _purple))),
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(color: Colors.grey.shade600))),
        ],
      ),
    );
    if (choice == null) return;
    try {
      if (choice == 'all') {
        await SupaFlow.client
            .from('messages')
            .update({'is_deleted': true}).inFilter('id', ids);
      } else {
        final rows = await SupaFlow.client
            .from('messages')
            .select('id, deleted_for_user_ids')
            .inFilter('id', ids);
        for (final r in rows) {
          final list = ((r['deleted_for_user_ids'] as List?) ?? [])
              .map((e) => e.toString())
              .toList();
          if (!list.contains(widget.currentUserId)) {
            list.add(widget.currentUserId);
          }
          await SupaFlow.client
              .from('messages')
              .update({'deleted_for_user_ids': list}).eq('id', r['id']);
        }
      }
      if (!mounted) return;
      setState(() {
        _media.removeWhere((e) => ids.contains(e.messageId));
        _selected.clear();
      });
    } catch (e) {
      _toast('Could not delete. Please try again.');
    }
  }

  String _monthLabel(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month) return 'This Month';
    return DateFormat('MMMM yyyy').format(d);
  }

  Future<void> _openExternal(String url) async {
    var u = url;
    if (u.toLowerCase().startsWith('www.')) u = 'https://$u';
    try {
      await launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _openFile(_FileEntry f) async {
    if (kIsWeb) {
      await _openExternal(f.url);
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DocumentPreviewScreen(url: f.url, name: f.name),
      ),
    );
  }

  String _size(int bytes) {
    if (bytes <= 0) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _empty(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
        ),
      );

  Widget _sectionHeader(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
        child: Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16, fontWeight: FontWeight.w700)),
      );

  // ----------------------------- Media tab -----------------------------
  Widget _segment(String label, int index) {
    final selected = _mediaFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mediaFilter = index),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? _purple.withOpacity(0.28) : Colors.transparent,
            borderRadius: BorderRadius.circular(21),
          ),
          child: Text(label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selected ? _purple : Colors.grey.shade600,
              )),
        ),
      ),
    );
  }

  Widget _mediaTab() {
    final visible = _visibleMedia();

    final sections = <String, List<_MediaEntry>>{};
    for (final e in visible) {
      sections.putIfAbsent(_monthLabel(e.createdAt), () => []).add(e);
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(children: [
            _segment('All', 0),
            _segment('Photos', 1),
            _segment('Videos', 2),
          ]),
        ),
        Expanded(
          child: visible.isEmpty
              ? _empty(_mediaFilter == 2
                  ? 'No videos yet'
                  : _mediaFilter == 1
                      ? 'No photos yet'
                      : 'No media shared yet')
              : CustomScrollView(
                  slivers: [
                    for (final entry in sections.entries) ...[
                      SliverToBoxAdapter(child: _sectionHeader(entry.key)),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 6,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => _mediaTile(entry.value[i], visible),
                            childCount: entry.value.length,
                          ),
                        ),
                      ),
                    ],
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _mediaTile(_MediaEntry e, List<_MediaEntry> all) {
    final picked = _selected.contains(e.key);
    return GestureDetector(
      onLongPress: () {
        if (!_selecting) _toggle(e);
      },
      onTap: () {
        if (_selecting) {
          _toggle(e);
          return;
        }
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => _MediaPager(items: all, startIndex: all.indexOf(e)),
        ));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            e.isVideo
                ? _VideoFrame(url: e.url, thumbnailUrl: e.thumbnailUrl)
                : cachedNetworkImage(
                    e.url,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Colors.black12,
                      child: Icon(Icons.broken_image, color: Colors.black38),
                    ),
                    loadingBuilder: (c, child, p) => p == null
                        ? child
                        : const ColoredBox(color: Colors.black12),
                  ),
            if (e.isVideo)
              Center(
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                      color: Colors.black45, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 24),
                ),
              ),
            if (picked) Container(color: _purple.withOpacity(0.28)),
            if (_selecting)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: picked ? _purple : Colors.black26,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: picked
                      ? const Icon(Icons.check, color: Colors.white, size: 15)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ----------------------------- Files tab -----------------------------
  IconData _fileIcon(String name) {
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Icons.table_chart_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'zip':
      case 'rar':
        return Icons.folder_zip_rounded;
      case 'mp3':
      case 'wav':
      case 'm4a':
        return Icons.music_note_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Widget _filesTab() {
    if (_files.isEmpty) return _empty('No files shared yet');
    final sections = <String, List<_FileEntry>>{};
    for (final f in _files) {
      sections.putIfAbsent(_monthLabel(f.createdAt), () => []).add(f);
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (final entry in sections.entries) ...[
          _sectionHeader(entry.key),
          for (final f in entry.value)
            InkWell(
              onTap: () => _openFile(f),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _purple.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_fileIcon(f.name), color: _purple),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (_size(f.sizeBytes).isNotEmpty)
                                _size(f.sizeBytes),
                              if (f.name.contains('.'))
                                f.name.split('.').last.toUpperCase(),
                            ].join('  •  '),
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(DateFormat('MMM d, yyyy').format(f.createdAt),
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                    const SizedBox(width: 8),
                    Icon(Icons.download_rounded,
                        color: Colors.grey.shade600, size: 22),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  // ----------------------------- Links tab -----------------------------
  String _host(String url) {
    try {
      var u = url;
      if (u.toLowerCase().startsWith('www.')) u = 'https://$u';
      final h = Uri.parse(u).host;
      return h.isEmpty ? url : h.replaceFirst(RegExp(r'^www\.'), '');
    } catch (_) {
      return url;
    }
  }

  Widget _linksTab() {
    if (_links.isEmpty) return _empty('No links shared yet');
    final sections = <String, List<_LinkEntry>>{};
    for (final l in _links) {
      sections.putIfAbsent(_monthLabel(l.createdAt), () => []).add(l);
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (final entry in sections.entries) ...[
          _sectionHeader(entry.key),
          for (final l in entry.value)
            InkWell(
              onTap: () => _openExternal(l.url),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _purple.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.link_rounded, color: _purple),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_host(l.url),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(l.url,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: _purple, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(DateFormat('MMM d').format(l.createdAt),
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: PopScope(
        canPop: !_selecting,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && _selecting) setState(() => _selected.clear());
        },
        child: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                  child: _selecting
                      ? Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 28),
                              onPressed: () =>
                                  setState(() => _selected.clear()),
                            ),
                            Expanded(
                              child: Text(
                                '${_selected.length} selected',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 19, fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (_selected.length == 1)
                              IconButton(
                                tooltip: 'Go to Message',
                                icon: const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    color: _purple),
                                onPressed: _goToMessage,
                              ),
                            IconButton(
                              tooltip: 'Select All',
                              icon: const Icon(Icons.select_all_rounded,
                                  color: _purple),
                              onPressed: _selectAll,
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: Colors.red),
                              onPressed: _deleteSelected,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded,
                                  size: 28),
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                            Expanded(
                              child: Text(
                                _title,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 22, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                ),
                TabBar(
                  controller: _tabs,
                  labelColor: _purple,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorColor: _purple,
                  labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 17, fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Media'),
                    Tab(text: 'Files'),
                    Tab(text: 'Links'),
                  ],
                ),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          controller: _tabs,
                          children: [_mediaTab(), _filesTab(), _linksTab()],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// First frame (or stored thumbnail) of a video.
class _VideoFrame extends StatefulWidget {
  const _VideoFrame({required this.url, this.thumbnailUrl});
  final String url;
  final String? thumbnailUrl;

  @override
  State<_VideoFrame> createState() => _VideoFrameState();
}

class _VideoFrameState extends State<_VideoFrame> {
  VideoPlayerController? _c;
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
    _c = c;
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
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasThumb) {
      return cachedNetworkImage(widget.thumbnailUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black));
    }
    final c = _c;
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

// Full screen pager: pinch-zoom photos, tap to play videos.
class _MediaPager extends StatelessWidget {
  const _MediaPager({required this.items, required this.startIndex});
  final List<_MediaEntry> items;
  final int startIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: PageView.builder(
          controller:
              PageController(initialPage: startIndex < 0 ? 0 : startIndex),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final e = items[i];
            if (e.isVideo) return _PagerVideo(url: e.url);
            return InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Center(
                child: cachedNetworkImage(e.url,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
                        color: Colors.white54, size: 48)),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PagerVideo extends StatefulWidget {
  const _PagerVideo({required this.url});
  final String url;

  @override
  State<_PagerVideo> createState() => _PagerVideoState();
}

class _PagerVideoState extends State<_PagerVideo> {
  late final VideoPlayerController _c;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _c = cachedVideoController(widget.url);
    _c.initialize().then((_) {
      if (!mounted) return;
      setState(() => _ready = true);
    }).catchError((_) {});
    _c.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    return GestureDetector(
      onTap: () => _c.value.isPlaying ? _c.pause() : _c.play(),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _c.value.aspectRatio,
              child: VideoPlayer(_c),
            ),
            if (!_c.value.isPlaying)
              const Icon(Icons.play_circle_fill,
                  color: Colors.white70, size: 72),
          ],
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
