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

class GroupMembersList extends StatefulWidget {
  const GroupMembersList({
    super.key,
    this.width,
    this.height,
    required this.conversationId,
  });

  final double? width;
  final double? height;
  final String conversationId;

  @override
  State<GroupMembersList> createState() => _GroupMembersListState();
}

class _GroupMembersListState extends State<GroupMembersList> {
  static const Color _purple = Color(0xFF935CCC);

  bool _loading = true;
  bool _busy = false;
  List<Map<String, dynamic>> _members = [];
  final Map<String, String> _contactNames = {};
  String _me = '';
  String _creatorId = '';
  bool _iAmAdmin = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool _isCreator(String uid, String role) =>
      (uid.isNotEmpty && uid == _creatorId) ||
      role == 'creator' ||
      role == 'owner';

  Future<void> _load() async {
    _me = SupaFlow.client.auth.currentUser?.id ?? '';
    try {
      final conv = await SupaFlow.client
          .from('conversations')
          .select('created_by')
          .eq('id', widget.conversationId)
          .maybeSingle();
      _creatorId = (conv?['created_by'] ?? '').toString();

      final rows = await SupaFlow.client
          .from('conversation_participants_directory')
          .select('user_id, full_name, avatar_url, role')
          .eq('conversation_id', widget.conversationId);

      final mine = await SupaFlow.client
          .from('contacts')
          .select('contact_user_id, saved_name')
          .eq('owner_id', _me)
          .not('contact_user_id', 'is', null);
      final theirs = await SupaFlow.client
          .from('contacts')
          .select('owner_id')
          .eq('contact_user_id', _me)
          .not('owner_id', 'is', null);

      final names = <String, String>{};
      for (final r in (theirs as List)) {
        names[r['owner_id'].toString()] = '';
      }
      for (final r in (mine as List)) {
        names[r['contact_user_id'].toString()] =
            (r['saved_name'] ?? '').toString().trim();
      }

      final list = (rows as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      var admin = false;
      for (final m in list) {
        final uid = (m['user_id'] ?? '').toString();
        final role = (m['role'] ?? 'member').toString();
        if (uid == _me && (role == 'admin' || _isCreator(uid, role))) {
          admin = true;
        }
      }

      list.sort((a, b) {
        int rank(Map<String, dynamic> m) {
          final uid = (m['user_id'] ?? '').toString();
          final r = (m['role'] ?? 'member').toString();
          if (_isCreator(uid, r)) return 0;
          if (r == 'admin') return 1;
          return 2;
        }

        return rank(a).compareTo(rank(b));
      });

      if (!mounted) return;
      setState(() {
        _members = list;
        _iAmAdmin = admin;
        _contactNames
          ..clear()
          ..addAll(names);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _message(String userId, String name, String avatar) async {
    try {
      final convId = await findOrCreateConversation(_me, userId);
      if (!mounted) return;
      context.pushNamed('chatpage',
          queryParameters: {
            'conversationId': serializeParam(convId, ParamType.String),
            'otherUserId': serializeParam(userId, ParamType.String),
            'displayName': serializeParam(name, ParamType.String),
            'displayAvatar': serializeParam(avatar, ParamType.String),
          }.withoutNulls);
    } catch (_) {
      _toast('Could not open the chat');
    }
  }

  void _onChat(String userId, String name, String avatar, bool isContact) {
    if (userId == _me) return;
    if (!isContact) {
      _toast('You can only message people saved in your contacts');
      return;
    }
    _message(userId, name, avatar);
  }

  Future<void> _setAdmin(String userId, bool makeAdmin) async {
    if (_busy) return;
    _busy = true;
    try {
      await SupaFlow.client.rpc('set_group_admin', params: {
        'p_conversation_id': widget.conversationId,
        'p_user_id': userId,
        'p_make_admin': makeAdmin,
      });
      _toast(makeAdmin ? 'Now a group admin' : 'No longer an admin');
      await _load();
    } catch (_) {
      _toast('Could not update admin');
    }
    _busy = false;
  }

  void _adminMenu(String userId, String name, bool isAdmin) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                  isAdmin
                      ? Icons.remove_moderator_outlined
                      : Icons.admin_panel_settings_outlined,
                  color: _purple),
              title: Text(isAdmin
                  ? 'Remove $name as admin'
                  : 'Make $name a group admin'),
              onTap: () {
                Navigator.of(ctx).pop();
                _setAdmin(userId, !isAdmin);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String url) {
    final has = url.trim().isNotEmpty;
    return Container(
      width: 46,
      height: 46,
      clipBehavior: Clip.antiAlias,
      decoration:
          const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE9DDF5)),
      child: has
          ? Image.network(url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.person, color: _purple))
          : const Icon(Icons.person, color: _purple),
    );
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
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _members.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (context, i) {
          final m = _members[i];
          final uid = (m['user_id'] ?? '').toString();
          final isMe = uid == _me;
          final isContact = _contactNames.containsKey(uid);
          final saved = (_contactNames[uid] ?? '').trim();
          final full = (m['full_name'] ?? '').toString().trim();
          final name = isMe
              ? 'You'
              : (saved.isNotEmpty
                  ? saved
                  : (full.isNotEmpty ? full : 'Member'));
          final avatar = (m['avatar_url'] ?? '').toString();
          final role = (m['role'] ?? 'member').toString();
          final creator = _isCreator(uid, role);
          final isAdmin = role == 'admin';
          final tag = creator ? 'Creator' : (isAdmin ? 'Admin' : '');
          final canManage = _iAmAdmin && !isMe && !creator;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _avatar(avatar),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                if (tag.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9DDF5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(tag,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _purple)),
                  ),
                if (!isMe)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _onChat(uid, name, avatar, isContact),
                    icon: Icon(Icons.chat_bubble_outline,
                        size: 22, color: isContact ? _purple : Colors.black26),
                  ),
                if (canManage)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _adminMenu(uid, name, isAdmin),
                    icon: const Icon(Icons.more_vert,
                        size: 22, color: Colors.black54),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
