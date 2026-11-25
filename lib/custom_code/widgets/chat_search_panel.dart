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

import '/custom_code/actions/index.dart';
import '/app_state.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class ChatSearchPanel extends StatefulWidget {
  const ChatSearchPanel({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
    required this.query,
  });

  final double? width;
  final double? height;
  final String currentUserId;
  final String query;

  @override
  State<ChatSearchPanel> createState() => _ChatSearchPanelState();
}

class _ChatSearchPanelState extends State<ChatSearchPanel> {
  bool _loading = true;
  List<Map<String, dynamic>> _chatRows = [];
  Map<String, String> _savedNameByUser = {};
  Map<String, String> _usernameByUser = {};
  List<_MessageMatch> _messageMatches = [];
  bool _passwordUnlocked = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void didUpdateWidget(covariant ChatSearchPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _loadAll();
    }
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _passwordUnlocked = false;
    });

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

    final query = widget.query.trim();
    List<_MessageMatch> messageMatches = [];
    bool passwordUnlocked = false;

    if (query.isNotEmpty) {
      passwordUnlocked = await verifyAppPassword(query);
      if (passwordUnlocked) {
        // Remember the password was just entered, so Private Chat opens
        // without asking again.
        FFAppState().update(() {
          FFAppState().privateUnlockedAt = DateTime.now();
        });
      }

      if (!passwordUnlocked) {
        final participantRows = await SupaFlow.client
            .from('conversation_participants')
            .select('conversation_id')
            .eq('user_id', widget.currentUserId);
        final conversationIds = List<Map<String, dynamic>>.from(participantRows)
            .map((r) => r['conversation_id'] as String)
            .toList();

        if (conversationIds.isNotEmpty) {
          final messageRows = await SupaFlow.client
              .from('messages')
              .select(
                  'id, conversation_id, content, sender_id, created_at, deleted_for_user_ids')
              .inFilter('conversation_id', conversationIds)
              .eq('is_deleted', false)
              .ilike('content', '%$query%')
              .order('created_at', ascending: false)
              .limit(50);

          final rowsById = {for (final r in rows) r['conversation_id']: r};

          for (final mRow in messageRows) {
            final conversationId = mRow['conversation_id'] as String;
            final chatRow = rowsById[conversationId];
            if (chatRow == null) continue;
            if (chatRow['is_locked'] == true) continue;
            // Skip messages this user deleted for themselves.
            final deletedFor = mRow['deleted_for_user_ids'];
            if (deletedFor is List &&
                deletedFor.map((e) => e.toString()).contains(widget.currentUserId)) {
              continue;
            }

            final isGroup = chatRow['type'] == 'group';
            final otherUserId = (chatRow['other_user_id'] as String?) ?? '';
            final displayName = isGroup
                ? ((chatRow['display_name'] as String?) ?? 'Unknown')
                : (savedNameByUser[otherUserId] ??
                    usernameByUser[otherUserId] ??
                    (chatRow['display_name'] as String?) ??
                    'Unknown');
            final avatarUrl = (chatRow['display_avatar'] as String?) ?? '';

            messageMatches.add(_MessageMatch(
              messageId: mRow['id'] as String,
              conversationId: conversationId,
              isGroup: isGroup,
              otherUserId: otherUserId,
              displayName: displayName,
              avatarUrl: avatarUrl,
              snippet: (mRow['content'] as String?) ?? '',
              timeLabel: _timeLabel(mRow['created_at']),
            ));
          }
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _chatRows = rows;
      _savedNameByUser = savedNameByUser;
      _usernameByUser = usernameByUser;
      _messageMatches = messageMatches;
      _passwordUnlocked = passwordUnlocked;
      _loading = false;
    });
    if (passwordUnlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openPrivate();
      });
    }
  }

  String _resolveName(Map<String, dynamic> row) {
    final isGroup = row['type'] == 'group';
    if (isGroup) {
      return (row['display_name'] as String?) ?? 'Unknown';
    }
    final otherUserId = (row['other_user_id'] as String?) ?? '';
    return _savedNameByUser[otherUserId] ??
        _usernameByUser[otherUserId] ??
        (row['display_name'] as String?) ??
        'Unknown';
  }

  List<Map<String, dynamic>> get _nameMatches {
    final query = widget.query.trim().toLowerCase();

    // Locked chats never show here. They live in Private Chat.
    if (_passwordUnlocked) return [];

    final unlocked = _chatRows.where((r) => r['is_locked'] != true);

    if (query.isEmpty) return unlocked.toList();
    return unlocked
        .where((r) => _resolveName(r).toLowerCase().contains(query))
        .toList();
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

  Future<void> _openPrivate() async {
    await goToPrivateChat();
  }

  // True when the search text points at Private Chats: either a keyword
  // ("private", "locked") or the name of a locked chat. The locked chat's own
  // name and photo are never shown, only a generic row.
  bool get _showPrivateRow {
    final query = widget.query.trim().toLowerCase();
    if (query.length < 2 || _passwordUnlocked) return false;
    const keywords = [
      'private chats',
      'private chat',
      'locked chats',
      'locked chat'
    ];
    if (keywords.any((k) => k.startsWith(query) || query.startsWith(k))) {
      return true;
    }
    return _chatRows
        .where((r) => r['is_locked'] == true)
        .any((r) => _resolveName(r).toLowerCase().contains(query));
  }

  void _openChat(String conversationId, bool isGroup, String otherUserId,
      String displayName, String avatarUrl) {
    if (isGroup) {
      context.pushNamed(
        'Group_chatpage',
        queryParameters: {
          'conversationId': serializeParam(conversationId, ParamType.String),
        }.withoutNulls,
      );
    } else {
      context.pushNamed(
        'chatpage',
        queryParameters: {
          'conversationId': serializeParam(conversationId, ParamType.String),
          'otherUserId': serializeParam(otherUserId, ParamType.String),
          'displayName': serializeParam(displayName, ParamType.String),
          'displayAvatar': serializeParam(avatarUrl, ParamType.String),
        }.withoutNulls,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (_loading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final nameMatches = _nameMatches;
    final hasQuery = widget.query.trim().isNotEmpty;
    final noResults = hasQuery &&
        !_passwordUnlocked &&
        !_showPrivateRow &&
        nameMatches.isEmpty &&
        _messageMatches.isEmpty;

    if (noResults) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'No results found for "${widget.query}"',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.secondaryText, fontSize: 14),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 70),
        children: [
          if (_passwordUnlocked || _showPrivateRow)
            InkWell(
              onTap: _openPrivate,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFFEFEBF2),
                      child: Icon(Icons.lock_outline,
                          color: Color(0xFF935CCC), size: 26),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Private Chats',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Password required',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF8A8A8A)),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: theme.secondaryText),
                  ],
                ),
              ),
            ),
          ...nameMatches.map((row) {
            final conversationId = row['conversation_id'] as String;
            final isGroup = row['type'] == 'group';
            final otherUserId = (row['other_user_id'] as String?) ?? '';
            final displayName = _resolveName(row);
            final avatarUrl = (row['display_avatar'] as String?) ?? '';

            return InkWell(
              onTap: () => _openChat(
                  conversationId, isGroup, otherUserId, displayName, avatarUrl),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Builder(builder: (context) {
                      final avatar = CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFEFEBF2),
                        backgroundImage:
                            (avatarUrl.toLowerCase().startsWith('http') &&
                                    !avatarUrl
                                        .toLowerCase()
                                        .contains('unsplash.com'))
                                ? NetworkImage(avatarUrl)
                                : null,
                        child: (avatarUrl.toLowerCase().startsWith('http') &&
                                !avatarUrl
                                    .toLowerCase()
                                    .contains('unsplash.com'))
                            ? null
                            : const Icon(Icons.person_outline,
                                color: Color(0xFF935CCC), size: 28),
                      );
                      return avatar;
                    }),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        displayName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (!_passwordUnlocked && _messageMatches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: Text(
                'Messages',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: theme.secondaryText,
                ),
              ),
            ),
            ..._messageMatches.map((match) {
              return InkWell(
                onTap: () => _openChat(match.conversationId, match.isGroup,
                    match.otherUserId, match.displayName, match.avatarUrl),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFEFEBF2),
                        backgroundImage:
                            (match.avatarUrl.toLowerCase().startsWith('http') &&
                                    !match.avatarUrl
                                        .toLowerCase()
                                        .contains('unsplash.com'))
                                ? NetworkImage(match.avatarUrl)
                                : null,
                        child:
                            (match.avatarUrl.toLowerCase().startsWith('http') &&
                                    !match.avatarUrl
                                        .toLowerCase()
                                        .contains('unsplash.com'))
                                ? null
                                : const Icon(Icons.person_outline,
                                    color: Color(0xFF935CCC), size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(match.displayName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(
                              match.snippet,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: theme.secondaryText, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        match.timeLabel,
                        style: TextStyle(
                            fontSize: 11.5, color: theme.secondaryText),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _MessageMatch {
  _MessageMatch({
    required this.messageId,
    required this.conversationId,
    required this.isGroup,
    required this.otherUserId,
    required this.displayName,
    required this.avatarUrl,
    required this.snippet,
    required this.timeLabel,
  });

  final String messageId;
  final String conversationId;
  final bool isGroup;
  final String otherUserId;
  final String displayName;
  final String avatarUrl;
  final String snippet;
  final String timeLabel;
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
