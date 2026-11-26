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

class PrivateChatHub extends StatefulWidget {
  const PrivateChatHub({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
  });

  final double? width;
  final double? height;
  final String currentUserId;

  @override
  State<PrivateChatHub> createState() => _PrivateChatHubState();
}

class _PrivateChatHubState extends State<PrivateChatHub> {
  static const Color _purple = Color(0xFF935CCC);
  static const int _freshMinutes = 15;

  bool _unlocked = false;
  bool _checking = false;
  bool _loading = false;
  String _pwError = '';
  String _query = '';
  final TextEditingController _pw = TextEditingController();
  final TextEditingController _search = TextEditingController();

  List<Map<String, dynamic>> _rows = [];
  List<Map<String, dynamic>> _stories = [];
  final Map<String, String> _saved = {};

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _ink => _dark ? Colors.white : const Color(0xFF1B1230);
  Color get _soft => _dark ? Colors.white70 : const Color(0xFF6B6480);

  @override
  void initState() {
    super.initState();
    _unlocked = _stillUnlocked();
    if (_unlocked) _load();
  }

  @override
  void dispose() {
    _pw.dispose();
    _search.dispose();
    super.dispose();
  }

  bool _stillUnlocked() {
    final at = FFAppState().privateUnlockedAt;
    if (at == null) return false;
    return DateTime.now().difference(at).inMinutes < _freshMinutes;
  }

  void _toast(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _unlock() async {
    final pw = _pw.text;
    if (pw.isEmpty || _checking) return;
    setState(() {
      _checking = true;
      _pwError = '';
    });
    final ok = await verifyAppPassword(pw);
    if (!mounted) return;
    if (ok) {
      FFAppState().update(() {
        FFAppState().privateUnlockedAt = DateTime.now();
      });
      _pw.clear();
      setState(() {
        _unlocked = true;
        _checking = false;
      });
      _load();
    } else {
      setState(() {
        _checking = false;
        _pwError = 'Incorrect password';
      });
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final data = await SupaFlow.client
          .from('chat_list_view')
          .select()
          .eq('is_locked', true)
          .order('last_message_at', ascending: false);
      // Pinned first by pin time (newest pin on top), then by last message.
      final rows = await sortChatRowsWhatsApp(
          List<Map<String, dynamic>>.from(data));

      final otherIds = rows
          .where((r) => r['type'] != 'group')
          .map((r) => r['other_user_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();
      final saved = <String, String>{};
      if (otherIds.isNotEmpty) {
        final cr = await SupaFlow.client
            .from('contacts')
            .select('contact_user_id, saved_name')
            .eq('owner_id', widget.currentUserId)
            .inFilter('contact_user_id', otherIds);
        for (final r in cr) {
          final id = r['contact_user_id'] as String?;
          final n = (r['saved_name'] as String?)?.trim() ?? '';
          if (id != null && n.isNotEmpty) saved[id] = n;
        }
      }

      var stories = <Map<String, dynamic>>[];
      try {
        final sr = await SupaFlow.client
            .from('private_story_ring_view')
            .select('user_id, full_name, avatar_url, has_unviewed');
        stories = List<Map<String, dynamic>>.from(sr);
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _rows = rows;
        _stories = stories;
        _saved
          ..clear()
          ..addAll(saved);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _nameOf(Map<String, dynamic> r) {
    if (r['type'] == 'group') return (r['display_name'] ?? 'Group').toString();
    final id = (r['other_user_id'] ?? '').toString();
    return _saved[id] ?? (r['display_name'] ?? 'Unknown').toString();
  }

  String _preview(Map<String, dynamic> r) {
    final c = (r['last_message_content'] ?? '').toString().trim();
    final t = (r['last_message_type'] ?? '').toString();
    if (t == 'image') return 'Photo';
    if (t == 'video') return 'Video';
    if (c.isNotEmpty) return c;
    return 'No messages yet';
  }

  String _time(dynamic raw) {
    final d = DateTime.tryParse('${raw ?? ''}')?.toLocal();
    if (d == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) {
      final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
      final m = d.minute.toString().padLeft(2, '0');
      return '$h:$m ${d.hour >= 12 ? 'PM' : 'AM'}';
    }
    if (diff == 1) return 'Yesterday';
    return '${d.day}/${d.month}/${d.year}';
  }

  Future<void> _openChat(Map<String, dynamic> r) async {
    final id = (r['conversation_id'] ?? '').toString();
    final name = _nameOf(r);
    final avatar = (r['display_avatar'] ?? '').toString();
    if (r['type'] == 'group') {
      await context.pushNamed('Group_chatpage',
          queryParameters: {
            'conversationId': serializeParam(id, ParamType.String),
            'groupConversationId': serializeParam(id, ParamType.String),
            'groupNameParam': serializeParam(name, ParamType.String),
            'groupAvatarParam': serializeParam(avatar, ParamType.String),
            'displayName': serializeParam(name, ParamType.String),
            'displayAvatar': serializeParam(avatar, ParamType.String),
          }.withoutNulls);
    } else {
      await context.pushNamed('chatpage',
          queryParameters: {
            'conversationId': serializeParam(id, ParamType.String),
            'otherUserId': serializeParam(
                (r['other_user_id'] ?? '').toString(), ParamType.String),
            'displayName': serializeParam(name, ParamType.String),
            'displayAvatar': serializeParam(avatar, ParamType.String),
          }.withoutNulls);
    }
    if (mounted) _load();
  }

  Future<void> _openStory(String userId) async {
    try {
      final groups = await getFriendsStories(widget.currentUserId, true);
      final idx = groups.indexWhere((g) => g.userId == userId);
      if (idx < 0) {
        _toast('No Stories to show right now');
        return;
      }
      FFAppState().update(() => FFAppState().friendsStoriesList = groups);
      if (!mounted) return;
      await context.pushNamed('users_story',
          queryParameters: {
            'groupIndex': serializeParam(idx, ParamType.int),
            'currentUserId':
                serializeParam(widget.currentUserId, ParamType.String),
          }.withoutNulls);
      if (mounted) _load();
    } catch (_) {
      _toast('Could not open the Story');
    }
  }

  Future<List<Map<String, dynamic>>> _contacts() async {
    final me = widget.currentUserId;
    final rows = await SupaFlow.client
        .from('contacts')
        .select('contact_user_id, saved_name')
        .eq('owner_id', me)
        .not('contact_user_id', 'is', null);
    final saved = <String, String>{};
    for (final r in rows) {
      final id = r['contact_user_id'] as String?;
      if (id == null || id == me) continue;
      saved[id] = ((r['saved_name'] ?? '') as String).trim();
    }
    if (saved.isEmpty) return [];
    final pr = await SupaFlow.client
        .from('profiles')
        .select('id, full_name, username, avatar_url')
        .inFilter('id', saved.keys.toList());
    final list = <Map<String, dynamic>>[];
    for (final p in pr) {
      final id = p['id'] as String;
      var name = saved[id] ?? '';
      if (name.isEmpty) name = ((p['full_name'] ?? '') as String).trim();
      if (name.isEmpty) name = ((p['username'] ?? '') as String).trim();
      if (name.isEmpty) name = 'Unknown';
      list.add({
        'id': id,
        'name': name,
        'avatar': ((p['avatar_url'] ?? '') as String),
      });
    }
    list.sort((a, b) => (a['name'] as String)
        .toLowerCase()
        .compareTo((b['name'] as String).toLowerCase()));
    return list;
  }

  void _showAdd() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.person_add_alt_1, color: _purple),
                title: const Text('New user'),
                subtitle: const Text('Start a private chat with a contact'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _newUser();
                },
              ),
              ListTile(
                leading: const Icon(Icons.group_add, color: _purple),
                title: const Text('Create group'),
                subtitle: const Text('A private group with the same rules'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _newGroup();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _newUser() async {
    List<Map<String, dynamic>> contacts;
    try {
      contacts = await _contacts();
    } catch (_) {
      _toast('Could not load your contacts');
      return;
    }
    if (!mounted) return;
    final res = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        title: 'New private chat',
        contacts: contacts,
        multi: false,
        actionLabel: '',
      ),
    );
    if (res == null) return;
    final ids = List<String>.from(res['ids'] as List);
    if (ids.isEmpty) return;
    final picked = contacts.firstWhere((c) => c['id'] == ids.first);
    try {
      final convId =
          await findOrCreateConversation(widget.currentUserId, ids.first);
      final ok = await setPrivateLock(convId, true);
      if (!ok) {
        _toast('Could not lock this chat');
        return;
      }
      await _load();
      if (!mounted) return;
      await context.pushNamed('chatpage',
          queryParameters: {
            'conversationId': serializeParam(convId, ParamType.String),
            'otherUserId': serializeParam(ids.first, ParamType.String),
            'displayName':
                serializeParam(picked['name'] as String, ParamType.String),
            'displayAvatar':
                serializeParam(picked['avatar'] as String, ParamType.String),
          }.withoutNulls);
      if (mounted) _load();
    } catch (_) {
      _toast('Could not start the chat');
    }
  }

  Future<void> _newGroup() async {
    List<Map<String, dynamic>> contacts;
    try {
      contacts = await _contacts();
    } catch (_) {
      _toast('Could not load your contacts');
      return;
    }
    if (!mounted) return;
    final res = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        title: 'New private group',
        contacts: contacts,
        multi: true,
        actionLabel: 'Create private group',
      ),
    );
    if (res == null) return;
    final name = (res['name'] ?? '').toString().trim();
    final ids = List<String>.from(res['ids'] as List);
    if (name.isEmpty || ids.isEmpty) return;
    try {
      final members =
          ids.map((id) => GroupMemberStructStruct(memberId: id)).toList();
      final cid = await createGroupConversation(
          name, null, widget.currentUserId, members, true);
      if (cid == null || cid.isEmpty) {
        _toast('Could not create the group');
        return;
      }
      await _load();
      if (!mounted) return;
      await context.pushNamed('Group_chatpage',
          queryParameters: {
            'conversationId': serializeParam(cid, ParamType.String),
            'groupConversationId': serializeParam(cid, ParamType.String),
            'groupNameParam': serializeParam(name, ParamType.String),
            'groupAvatarParam': serializeParam('', ParamType.String),
            'displayName': serializeParam(name, ParamType.String),
            'displayAvatar': serializeParam('', ParamType.String),
          }.withoutNulls);
      if (mounted) _load();
    } catch (_) {
      _toast('Could not create the group');
    }
  }

  Widget _circleAvatar(String url, double size) {
    final has = url.trim().isNotEmpty;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration:
          const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE9DDF5)),
      child: has
          ? cachedNetworkImage(url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.person, color: _purple))
          : const Icon(Icons.person, color: _purple),
    );
  }

  Widget _gate() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 46, color: _purple),
            const SizedBox(height: 14),
            Text('Private Chat',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700, color: _ink)),
            const SizedBox(height: 6),
            Text('Enter your app password to continue',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _soft)),
            const SizedBox(height: 20),
            TextField(
              controller: _pw,
              obscureText: true,
              onSubmitted: (_) => _unlock(),
              decoration: InputDecoration(
                hintText: 'App password',
                errorText: _pwError.isEmpty ? null : _pwError,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: _checking ? null : _unlock,
                child: _checking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Unlock'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _storiesRow() {
    if (_stories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final s = _stories[i];
          final uid = (s['user_id'] ?? '').toString();
          final unviewed = s['has_unviewed'] == true;
          final name = _saved[uid] ?? (s['full_name'] ?? '').toString();
          return InkWell(
            onTap: () => _openStory(uid),
            child: SizedBox(
              width: 62,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: unviewed ? _purple : Colors.black26, width: 2),
                    ),
                    child:
                        _circleAvatar((s['avatar_url'] ?? '').toString(), 46),
                  ),
                  const SizedBox(height: 4),
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: _soft)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tile(Map<String, dynamic> r) {
    final isGroup = r['type'] == 'group';
    final avatar = (r['display_avatar'] ?? '').toString();
    final unread = int.tryParse('${r['unread_count'] ?? 0}') ?? 0;
    return InkWell(
      onTap: () => _openChat(r),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            isGroup
                ? GroupAvatar(imageUrl: avatar, size: 52)
                : _circleAvatar(avatar, 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_nameOf(r),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _ink)),
                  const SizedBox(height: 2),
                  Text(_preview(r),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: _soft)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_time(r['last_message_at']),
                    style: TextStyle(fontSize: 11, color: _soft)),
                const SizedBox(height: 4),
                if (unread > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                        color: _purple,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('$unread',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    final q = _query.trim().toLowerCase();
    final shown = q.isEmpty
        ? _rows
        : _rows.where((r) => _nameOf(r).toLowerCase().contains(q)).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search private chats',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: _showAdd,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: _purple),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        _storiesRow(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: shown.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Text(
                            _loading
                                ? 'Loading...'
                                : 'No private chats yet. Tap + to start one.',
                            style: TextStyle(color: _soft)),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: shown.length,
                    itemBuilder: (context, i) => _tile(shown[i]),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          _unlocked ? _content() : _gate(),
          // Blocks screenshots and recordings while Private Chat is open.
          PrivateScreenGuard(enabled: true),
        ],
      ),
    );
  }
}

class _PickerSheet extends StatefulWidget {
  const _PickerSheet({
    required this.title,
    required this.contacts,
    required this.multi,
    required this.actionLabel,
  });

  final String title;
  final List<Map<String, dynamic>> contacts;
  final bool multi;
  final String actionLabel;

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  static const Color _purple = Color(0xFF935CCC);
  final TextEditingController _name = TextEditingController();
  final TextEditingController _search = TextEditingController();
  final Set<String> _sel = {};
  String _q = '';
  String _error = '';

  @override
  void dispose() {
    _name.dispose();
    _search.dispose();
    super.dispose();
  }

  Widget _avatar(String url) {
    final has = url.trim().isNotEmpty;
    return Container(
      width: 42,
      height: 42,
      clipBehavior: Clip.antiAlias,
      decoration:
          const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE9DDF5)),
      child: has
          ? cachedNetworkImage(url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.person, color: _purple))
          : const Icon(Icons.person, color: _purple),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _q.trim().toLowerCase();
    final list = q.isEmpty
        ? widget.contacts
        : widget.contacts
            .where((c) => (c['name'] as String).toLowerCase().contains(q))
            .toList();
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.82,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 14),
            Text(widget.title,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            if (widget.multi)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _name,
                  decoration: InputDecoration(
                    hintText: 'Group name',
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _search,
                onChanged: (v) => setState(() => _q = v),
                decoration: InputDecoration(
                  hintText: 'Search contacts',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const Center(child: Text('No contacts found'))
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final c = list[i];
                        final id = c['id'] as String;
                        final on = _sel.contains(id);
                        return ListTile(
                          leading: _avatar(c['avatar'] as String),
                          title: Text(c['name'] as String),
                          trailing: widget.multi
                              ? Icon(
                                  on
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: on ? _purple : Colors.black26)
                              : null,
                          onTap: () {
                            if (!widget.multi) {
                              Navigator.of(context).pop({
                                'ids': [id],
                                'name': ''
                              });
                              return;
                            }
                            setState(() {
                              if (on) {
                                _sel.remove(id);
                              } else {
                                _sel.add(id);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
            if (widget.multi)
              Padding(
                padding: EdgeInsets.fromLTRB(
                    16, 6, 16, 14 + MediaQuery.of(context).padding.bottom),
                child: Column(
                  children: [
                    if (_error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(_error,
                            style: const TextStyle(color: Colors.red)),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: () {
                          if (_name.text.trim().isEmpty) {
                            setState(() => _error = 'Enter a group name');
                            return;
                          }
                          if (_sel.isEmpty) {
                            setState(
                                () => _error = 'Select at least one member');
                            return;
                          }
                          Navigator.of(context).pop({
                            'ids': _sel.toList(),
                            'name': _name.text.trim()
                          });
                        },
                        child: Text(widget.actionLabel),
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
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
