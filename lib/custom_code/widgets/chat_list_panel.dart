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
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/custom_code/actions/index.dart';
import '/custom_code/actions/init_offline_store.dart';

// Signals sent from the Home page 3-dots menu (via custom actions).
final ValueNotifier<int> chatListSelectModeRequest = ValueNotifier<int>(0);
final ValueNotifier<int> chatListReadAllRequest = ValueNotifier<int>(0);

class ChatListPanel extends StatefulWidget {
  const ChatListPanel({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
    required this.filter,
    required this.onOpenChat,
    required this.onAddFriend,
  });

  final double? width;
  final double? height;
  final String currentUserId;
  final String filter; // 'all' | 'unread' | 'groups' | 'archived'
  final Future Function(String conversationId, String otherUserId,
      String displayName, String displayAvatar) onOpenChat;
  final Future Function() onAddFriend;

  @override
  State<ChatListPanel> createState() => _ChatListPanelState();
}

class _ChatListPanelState extends State<ChatListPanel> {
  List<Map<String, dynamic>> _rows = [];
  Map<String, String> _savedNameByUser = {};
  Map<String, String> _usernameByUser = {};
  // people with a block between us and them (either direction)
  Set<String> _blockedPeers = {};
  // strangers whose message request is still waiting for accept or decline
  Set<String> _requestPeers = {};
  bool _loading = true;
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};
  StreamSubscription? _sub;
  StreamSubscription? _partSub;
  Timer? _debounce;
  // conversation_id -> when the other person last read the chat
  Map<String, DateTime> _otherReadAt = {};
  // people who switched read receipts off
  Set<String> _noReceiptUsers = {};
  static const int _maxPinnedChats = 4;
  int _lastSelectRequest = chatListSelectModeRequest.value;
  int _lastReadAllRequest = chatListReadAllRequest.value;

  @override
  void initState() {
    super.initState();
    chatListSelectModeRequest.addListener(_onSelectModeRequest);
    chatListReadAllRequest.addListener(_onReadAllRequest);
    _restoreFromCache();
    _refresh();
    _sub = SupaFlow.client
        .from('messages')
        .stream(primaryKey: ['id']).listen((_) => _refresh(), onError: (_) {});
    // The other person opening the chat updates last_read_at: refresh then.
    _partSub = SupaFlow.client.from('conversation_participants').stream(
        primaryKey: ['id']).listen((_) => _scheduleRefresh(), onError: (_) {});
  }

  bool _gotRemote = false;
  String get _cacheKey => 'chatlist:${widget.currentUserId}';

  // Opens instantly from the saved copy, like WhatsApp does offline.
  Future<void> _restoreFromCache() async {
    await OfflineStore.init();
    final cached = OfflineStore.getMap(_cacheKey);
    if (cached == null || _gotRemote || !mounted) return;
    Map<String, String> strMap(dynamic v) => v is Map
        ? v.map((k, val) => MapEntry(k.toString(), val.toString()))
        : <String, String>{};
    final read = <String, DateTime>{};
    final rawRead = cached['other_read_at'];
    if (rawRead is Map) {
      rawRead.forEach((k, v) {
        final d = DateTime.tryParse('$v');
        if (d != null) read[k.toString()] = d;
      });
    }
    setState(() {
      _rows = (cached['rows'] as List? ?? [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      _savedNameByUser = strMap(cached['saved_names']);
      _usernameByUser = strMap(cached['usernames']);
      _otherReadAt = read;
      _noReceiptUsers =
          (cached['no_receipt'] as List? ?? []).map((e) => '$e').toSet();
      _blockedPeers =
          (cached['blocked_peers'] as List? ?? []).map((e) => '$e').toSet();
      _loading = false;
    });
  }

  Future<void> _saveToCache() async {
    await OfflineStore.putJson(_cacheKey, {
      'rows': _rows,
      'saved_names': _savedNameByUser,
      'usernames': _usernameByUser,
      'other_read_at':
          _otherReadAt.map((k, v) => MapEntry(k, v.toUtc().toIso8601String())),
      'no_receipt': _noReceiptUsers.toList(),
      'blocked_peers': _blockedPeers.toList(),
    });
  }

  void _scheduleRefresh() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) _refresh();
    });
  }

  @override
  void dispose() {
    chatListSelectModeRequest.removeListener(_onSelectModeRequest);
    chatListReadAllRequest.removeListener(_onReadAllRequest);
    _sub?.cancel();
    _partSub?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSelectModeRequest() {
    if (chatListSelectModeRequest.value == _lastSelectRequest) return;
    _lastSelectRequest = chatListSelectModeRequest.value;
    if (!mounted) return;
    setState(() {
      _selectionMode = true;
      _selectedIds.clear();
    });
  }

  void _onReadAllRequest() {
    if (chatListReadAllRequest.value == _lastReadAllRequest) return;
    _lastReadAllRequest = chatListReadAllRequest.value;
    _readAll();
  }

  Future<void> _readAll() async {
    final unreadIds = _rows
        .where((r) => ((r['unread_count'] as int?) ?? 0) > 0)
        .map((r) => r['conversation_id'] as String)
        .toList();
    if (unreadIds.isEmpty) return;
    await SupaFlow.client
        .from('conversation_participants')
        .update({'last_read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('user_id', widget.currentUserId)
        .inFilter('conversation_id', unreadIds);
    await _refresh();
  }

  Future<void> _refresh() async {
    try {
      await _fetchAndApply();
    } catch (e) {
      debugPrint('chat list refresh failed: $e');
      ConnectivityMonitor.reportFailure();
      if (mounted && _loading) setState(() => _loading = false);
    }
  }

  Future<void> _fetchAndApply() async {
    final data = await SupaFlow.client
        .from('chat_list_view')
        .select()
        .order('last_message_at', ascending: false);

    // Pinned first by pin time (newest pin on top), then by last message.
    final rows = await sortChatRowsWhatsApp(
        List<Map<String, dynamic>>.from(data));

    final otherUserIds = rows
        .where((r) => r['type'] != 'group')
        .map((r) => r['other_user_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    final savedNameByUser = <String, String>{};
    final usernameByUser = <String, String>{};

    if (otherUserIds.isNotEmpty) {
      final contactRows = await SupaFlow.client
          .from('contacts')
          .select('contact_user_id, saved_name')
          .eq('owner_id', widget.currentUserId)
          .inFilter('contact_user_id', otherUserIds);
      for (final row in contactRows) {
        final id = row['contact_user_id'] as String?;
        final name = row['saved_name'] as String?;
        if (id != null && name != null && name.trim().isNotEmpty) {
          savedNameByUser[id] = name;
        }
      }

      final profileRows = await SupaFlow.client
          .from('profiles')
          .select('id, username')
          .inFilter('id', otherUserIds);
      for (final row in profileRows) {
        final id = row['id'] as String?;
        final uname = row['username'] as String?;
        if (id != null && uname != null && uname.trim().isNotEmpty) {
          usernameByUser[id] = uname;
        }
      }
    }

    // Seen / online info for chats where I sent the last message.
    final sentRows = rows.where((r) =>
        r['type'] != 'group' &&
        r['last_message_sender_id'] == widget.currentUserId &&
        ((r['last_message_type'] as String?) ?? '').isNotEmpty);
    final sentConvIds =
        sentRows.map((r) => r['conversation_id'] as String).toList();
    final sentOtherIds = sentRows
        .map((r) => r['other_user_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    final otherReadAt = <String, DateTime>{};
    final noReceipt = <String>{};
    if (sentConvIds.isNotEmpty) {
      try {
        final partRows = await SupaFlow.client
            .from('conversation_participants')
            .select('conversation_id, user_id, last_read_at')
            .inFilter('conversation_id', sentConvIds)
            .neq('user_id', widget.currentUserId);
        for (final row in partRows) {
          final convId = row['conversation_id'] as String?;
          final readAt = DateTime.tryParse('${row['last_read_at'] ?? ''}');
          if (convId != null && readAt != null) otherReadAt[convId] = readAt;
        }
      } catch (e) {
        debugPrint('chat list read state failed: $e');
      }
      try {
        final privacyRows = await SupaFlow.client
            .from('privacy_settings')
            .select('user_id, read_receipts_enabled')
            .inFilter('user_id', sentOtherIds);
        for (final row in privacyRows) {
          final id = row['user_id'] as String?;
          if (id != null && row['read_receipts_enabled'] == false) {
            noReceipt.add(id);
          }
        }
      } catch (e) {
        debugPrint('chat list receipts setting failed: $e');
      }
    }

    var blockedPeers = <String>{};
    try {
      final b = await SupaFlow.client.rpc('blocked_peers');
      blockedPeers = {for (final x in (b as List)) x.toString()};
    } catch (_) {}

    var requestPeers = <String>{};
    try {
      final q = await SupaFlow.client.rpc('pending_request_peers');
      requestPeers = {for (final x in (q as List)) x.toString()};
    } catch (_) {}

    if (!mounted) return;
    _gotRemote = true;
    setState(() {
      _requestPeers = requestPeers;
      _blockedPeers = blockedPeers;
      _rows = rows;
      _savedNameByUser = savedNameByUser;
      _usernameByUser = usernameByUser;
      _otherReadAt = otherReadAt;
      _noReceiptUsers = noReceipt;
      _loading = false;
    });
    _saveToCache();
  }

  List<Map<String, dynamic>> get _filteredRows {
    final unlocked = _rows.where((r) =>
        r['is_locked'] != true &&
        !(r['type'] == 'direct' &&
            _requestPeers.contains('${r['other_user_id']}')));
    switch (widget.filter) {
      case 'unread':
        return unlocked
            .where((r) =>
                r['is_archived'] != true &&
                ((r['unread_count'] as int?) ?? 0) > 0)
            .toList();
      case 'groups':
        return unlocked
            .where((r) => r['type'] == 'group' && r['is_archived'] != true)
            .toList();
      case 'archived':
        return unlocked.where((r) => r['is_archived'] == true).toList();
      default:
        return unlocked.where((r) => r['is_archived'] != true).toList();
    }
  }

  // Saved names can contain line breaks; show them as one line.
  String _cleanName(String name) {
    final cleaned = name.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned.isEmpty ? 'Unknown' : cleaned;
  }

  String _resolveDisplayName(Map<String, dynamic> row) {
    final isGroup = row['type'] == 'group';
    if (isGroup) {
      return _cleanName((row['display_name'] as String?) ?? 'Unknown');
    }
    final otherUserId = (row['other_user_id'] as String?) ?? '';
    return _cleanName(_savedNameByUser[otherUserId] ??
        _usernameByUser[otherUserId] ??
        (row['display_name'] as String?) ??
        'Unknown');
  }

  // Status of a message I sent (1:1 chats only):
  // faint = they are offline, grey = online but have not seen it,
  // purple = they have seen it.
  Widget? _sentStatusIcon(Map<String, dynamic> row) {
    if (row['type'] == 'group') return null;
    if (row['last_message_sender_id'] != widget.currentUserId) return null;
    if (((row['last_message_type'] as String?) ?? '').isEmpty) return null;
    final convId = row['conversation_id'] as String;
    final otherId = (row['other_user_id'] as String?) ?? '';
    final lastAt = DateTime.tryParse('${row['last_message_at'] ?? ''}');
    final readAt = _otherReadAt[convId];
    final seen = lastAt != null &&
        readAt != null &&
        !lastAt.isAfter(readAt) &&
        !_noReceiptUsers.contains(otherId);
    final Color color;
    if (seen) {
      color = const Color(0xFF935CCC);
    } else if (row['is_online'] == true) {
      color = const Color(0xFF9E9E9E);
    } else {
      color = const Color(0xFFE0E0E0);
    }
    return FaIcon(FontAwesomeIcons.dotCircle, size: 13, color: color);
  }

  void _toggleSelection(String conversationId) {
    setState(() {
      if (_selectedIds.contains(conversationId)) {
        _selectedIds.remove(conversationId);
      } else {
        _selectedIds.add(conversationId);
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  // True when every selected chat is already archived (show Unarchive).
  bool get _allSelectedArchived =>
      _selectedIds.isNotEmpty &&
      _selectedIds.every((id) => _rows
          .any((r) => r['conversation_id'] == id && r['is_archived'] == true));

  Future<void> _archiveSelected() async {
    final archive = !_allSelectedArchived;
    await SupaFlow.client
        .from('conversation_participants')
        .update({'is_archived': archive})
        .eq('user_id', widget.currentUserId)
        .inFilter('conversation_id', _selectedIds.toList());
    _cancelSelection();
    await _refresh();
  }

  Future<void> _deleteSelected() async {
    await deleteSelectedConversations(
        _selectedIds.toList(), widget.currentUserId);
    _cancelSelection();
    await _refresh();
  }

  Set<String> get _pinnedIds => _rows
      .where((r) => r['is_pinned'] == true)
      .map((r) => r['conversation_id'] as String)
      .toSet();

  // Unpin only when every selected chat is already pinned.
  bool get _canUnpin =>
      _selectedIds.isNotEmpty && _selectedIds.every(_pinnedIds.contains);

  // Pin when the selection has unpinned chats and the total stays within 4.
  bool get _canPin {
    if (_selectedIds.isEmpty) return false;
    final pinned = _pinnedIds;
    final toPin = _selectedIds.where((id) => !pinned.contains(id)).length;
    return toPin > 0 && pinned.length + toPin <= _maxPinnedChats;
  }

  Future<void> _setPinnedSelected(bool pin) async {
    final ids = _selectedIds.toList();
    await SupaFlow.client
        .from('conversation_participants')
        .update({'is_pinned': pin})
        .eq('user_id', widget.currentUserId)
        .inFilter('conversation_id', ids);
    _cancelSelection();
    await _refresh();
  }

  Future<void> _openPreview(Map<String, dynamic> row, String displayName,
      String displayAvatar) async {
    final conversationId = row['conversation_id'] as String;
    final otherUserId = (row['other_user_id'] as String?) ?? '';
    await showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => ChatPreviewCard(
        currentUserId: widget.currentUserId,
        conversationId: conversationId,
        otherUserId: otherUserId,
        displayName: displayName,
        displayAvatar: displayAvatar,
        isGroup: row['type'] == 'group',
        isPinned: row['is_pinned'] == true,
        isArchived: row['is_archived'] == true,
        pinnedCount: _pinnedIds.length,
        onOpenChat: () async {
          await widget.onOpenChat(
              conversationId, otherUserId, displayName, displayAvatar);
        },
        onChanged: () async {
          await _refresh();
        },
      ),
    );
  }

  String _timeLabel(dynamic raw) {
    if (raw == null) return '';
    final date = DateTime.tryParse(raw.toString());
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return DateFormat('h:mm a').format(date);
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(date);
    return DateFormat('MM/dd/yy').format(date);
  }

  String _formatLastMessage(String type, String content) {
    switch (type) {
      case 'image':
      case 'image_group':
        return 'Photo';
      case 'video':
        return 'Video';
      case 'gift_card':
        try {
          final data = jsonDecode(content) as Map<String, dynamic>;
          final amount = data['amount'];
          return '🎁 ${amount ?? ''} Schatz Gift';
        } catch (_) {
          return '🎁 Schatz Gift';
        }
      default:
        return content;
    }
  }

  Widget? _lastMessageIconWidget(String type) {
    switch (type) {
      case 'image':
      case 'image_group':
        return const FaIcon(FontAwesomeIcons.image,
            size: 12, color: Colors.black54);
      case 'video':
        return const FaIcon(FontAwesomeIcons.video,
            size: 12, color: Colors.black54);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final rows = _filteredRows;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        children: [
          Expanded(
            child: rows.isEmpty
                ? _emptyState(context)
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 70),
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 5),
                    itemBuilder: (context, i) {
                      final row = rows[i];
                      final conversationId = row['conversation_id'] as String;
                      final displayName = _resolveDisplayName(row);
                      final isBlockedPeer = row['type'] != 'group' &&
                          _blockedPeers.contains(
                              (row['other_user_id'] as String?) ?? '');
                      final displayAvatar = isBlockedPeer
                          ? ''
                          : ((row['display_avatar'] as String?) ?? '');
                      final lastMessageType =
                          (row['last_message_type'] as String?) ?? '';
                      final lastMessage = isBlockedPeer
                          ? 'Blocked'
                          : _formatLastMessage(
                              lastMessageType,
                              (row['last_message_content'] as String?) ?? '',
                            );
                      final lastMessageIconWidget = isBlockedPeer
                          ? null
                          : _lastMessageIconWidget(lastMessageType);
                      final unread = (row['unread_count'] as int?) ?? 0;
                      final isPinned = row['is_pinned'] == true;
                      final sentStatus =
                          isBlockedPeer ? null : _sentStatusIcon(row);
                      final isSelected = _selectedIds.contains(conversationId);
                      final timeLabel = _timeLabel(row['last_message_at']);

                      return InkWell(
                        onTap: () {
                          if (_selectionMode) {
                            _toggleSelection(conversationId);
                          } else {
                            widget.onOpenChat(
                              conversationId,
                              (row['other_user_id'] as String?) ?? '',
                              displayName,
                              displayAvatar,
                            );
                          }
                        },
                        onLongPress: () {
                          if (!_selectionMode) {
                            _openPreview(row, displayName, displayAvatar);
                          }
                        },
                        child: Container(
                          color: isSelected
                              ? const Color(0xFF935CCC).withOpacity(0.12)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              if (_selectionMode)
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: isSelected
                                        ? const Color(0xFF935CCC)
                                        : Colors.black26,
                                  ),
                                ),
                              if (row['type'] == 'group')
                                GroupAvatar(
                                  imageUrl: displayAvatar
                                          .toLowerCase()
                                          .contains('unsplash.com')
                                      ? ''
                                      : displayAvatar,
                                  size: 52,
                                )
                              else
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: isBlockedPeer
                                      ? const Color(0xFFE0E0E0)
                                      : const Color(0xFFEFEBF2),
                                  backgroundImage: (!isBlockedPeer &&
                                          displayAvatar
                                              .toLowerCase()
                                              .startsWith('http') &&
                                          !displayAvatar
                                              .toLowerCase()
                                              .contains('unsplash.com'))
                                      ? NetworkImage(displayAvatar)
                                      : null,
                                  child: isBlockedPeer
                                      ? const Icon(Icons.person,
                                          color: Color(0xFF9E9E9E), size: 30)
                                      : ((displayAvatar
                                                  .toLowerCase()
                                                  .startsWith('http') &&
                                              !displayAvatar
                                                  .toLowerCase()
                                                  .contains('unsplash.com'))
                                          ? null
                                          : const Icon(Icons.person_outline,
                                              color: Color(0xFF935CCC),
                                              size: 30)),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(displayName,
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        if (lastMessageIconWidget != null) ...[
                                          lastMessageIconWidget,
                                          const SizedBox(width: 5),
                                        ],
                                        Expanded(
                                          child: Text(
                                            lastMessage,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (timeLabel.isNotEmpty)
                                    Text(
                                      timeLabel,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: unread > 0
                                            ? const Color(0xFF935CCC)
                                            : Colors.black45,
                                        fontWeight: unread > 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  if (unread == 0 &&
                                      !_selectionMode &&
                                      (isPinned || sentStatus != null))
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (sentStatus != null) sentStatus,
                                          if (sentStatus != null && isPinned)
                                            const SizedBox(width: 6),
                                          if (isPinned)
                                            const Icon(Icons.push_pin,
                                                size: 15,
                                                color: Colors.black45),
                                        ],
                                      ),
                                    ),
                                  if (unread > 0 && !_selectionMode)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (isPinned) ...[
                                            const Icon(Icons.push_pin,
                                                size: 15,
                                                color: Colors.black45),
                                            const SizedBox(width: 6),
                                          ],
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF935CCC),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text('$unread',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12)),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_selectionMode)
            SafeArea(
              top: false,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_selectedIds.isEmpty)
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Text('Select chats',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54)),
                        ),
                      ),
                    if (_selectedIds.isNotEmpty) ...[
                      _bottomBarButton(
                          _allSelectedArchived
                              ? Icons.unarchive_outlined
                              : Icons.archive_outlined,
                          _allSelectedArchived ? 'Unarchive' : 'Archive',
                          _archiveSelected),
                      if (_canUnpin)
                        _bottomBarButton(Icons.push_pin, 'Unpin',
                            () => _setPinnedSelected(false))
                      else if (_canPin)
                        _bottomBarButton(Icons.push_pin_outlined, 'Pin',
                            () => _setPinnedSelected(true)),
                      _bottomBarButton(
                          Icons.delete_outline, 'Delete', _deleteSelected,
                          color: const Color(0xFFE91414)),
                    ],
                    _bottomBarButton(Icons.close, 'Cancel', _cancelSelection),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    if (widget.filter != 'all') {
      final message = widget.filter == 'unread'
          ? 'No unread chats'
          : widget.filter == 'groups'
              ? 'No groups yet'
              : 'No archived chats';
      return Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 15, color: theme.secondaryText),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: FaIcon(
                FontAwesomeIcons.comment,
                color: theme.primary,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No chats yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: theme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation by adding a friend on SchatzApp.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: theme.secondaryText,
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () => widget.onAddFriend(),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primary, theme.secondary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add_alt_1_rounded,
                        color: theme.secondaryBackground, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Add Friend',
                      style: TextStyle(
                        color: theme.secondaryBackground,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBarButton(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? const Color(0xFF935CCC)),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color ?? const Color(0xFF935CCC))),
        ],
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
