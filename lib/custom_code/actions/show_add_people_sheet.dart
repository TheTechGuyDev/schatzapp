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

import '/flutter_flow/nav/nav.dart';

Future<void> showAddPeopleSheet(String callId, String channelName) async {
  final ctx = appNavigatorKey.currentContext;
  if (ctx == null) return;
  await showModalBottomSheet<void>(
    context: ctx,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _AddPeopleSheet(callId: callId, channelName: channelName),
  );
}

class _AddPeopleSheet extends StatefulWidget {
  const _AddPeopleSheet({required this.callId, required this.channelName});

  final String callId;
  final String channelName;

  @override
  State<_AddPeopleSheet> createState() => _AddPeopleSheetState();
}

class _AddPeopleSheetState extends State<_AddPeopleSheet> {
  static const Color _purple = Color(0xFF935CCC);
  static const Color _red = Color(0xFFDF1609);

  final String _me = SupaFlow.client.auth.currentUser?.id ?? '';
  bool _loading = true;
  bool _busy = false;
  String _block = ''; // reason adding is not possible
  String _error = '';
  String _callType = 'voice';
  List<String> _alreadyInvited = [];
  int _slots = 0;
  List<Map<String, dynamic>> _contacts = [];
  final Set<String> _picked = {};
  final TextEditingController _search = TextEditingController();
  String _query = '';

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _dark ? const Color(0xFF1E1630) : Colors.white;
  Color get _ink => _dark ? Colors.white : const Color(0xFF1B1230);
  Color get _soft => _dark ? Colors.white70 : const Color(0xFF6B6480);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final call = await SupaFlow.client
          .from('calls')
          .select(
              'caller_id, call_type, is_group, via_link, status, invited_user_ids')
          .eq('id', widget.callId)
          .maybeSingle();
      if (call == null) {
        _blockWith('This call has ended.');
        return;
      }
      final status = (call['status'] ?? '').toString();
      if (status == 'ended' || status == 'missed' || status == 'declined') {
        _blockWith('This call has ended.');
        return;
      }
      if (call['caller_id'].toString() != _me) {
        _blockWith('Only the person who started the call can add people.');
        return;
      }
      if (call['is_group'] != true) {
        _blockWith(
            'You can add people to group calls and link calls. Start a group call from New call.');
        return;
      }
      _callType = (call['call_type'] ?? 'voice').toString();
      final cap = (call['via_link'] == true || _callType == 'video') ? 16 : 32;
      _alreadyInvited = [
        for (final x in (call['invited_user_ids'] as List? ?? [])) x.toString()
      ];

      final parts = await SupaFlow.client
          .from('call_participants')
          .select('user_id, status, joined_at, left_at')
          .eq('call_id', widget.callId);
      final inCall = <String>{};
      final removed = <String>{};
      for (final p in parts as List) {
        final id = p['user_id'].toString();
        if (p['status']?.toString() == 'removed') removed.add(id);
        if (p['joined_at'] != null && p['left_at'] == null) inCall.add(id);
      }
      _slots = cap - inCall.length;

      var locked = <String>{};
      try {
        final raw = await SupaFlow.client.rpc('pcl_locked_peers');
        locked = {for (final x in (raw as List)) x.toString()};
      } catch (_) {}

      final rows = await SupaFlow.client
          .from('contacts_directory')
          .select('contact_user_id, saved_name')
          .eq('owner_id', _me)
          .not('contact_user_id', 'is', null);
      final saved = <String, String>{};
      for (final r in rows as List) {
        final id = r['contact_user_id'] as String?;
        if (id == null || id == _me) continue;
        if (inCall.contains(id) ||
            removed.contains(id) ||
            locked.contains(id)) {
          continue;
        }
        saved[id] = (r['saved_name'] ?? '').toString();
      }
      final profiles = <String, Map<String, dynamic>>{};
      if (saved.isNotEmpty) {
        final pr = await SupaFlow.client
            .from('profiles')
            .select('id, full_name, username, avatar_url')
            .inFilter('id', saved.keys.toList());
        for (final p in pr as List) {
          profiles[p['id'] as String] = Map<String, dynamic>.from(p);
        }
      }
      final list = <Map<String, dynamic>>[];
      for (final e in saved.entries) {
        final pf = profiles[e.key];
        var name = e.value.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (name.isEmpty) name = (pf?['username'] ?? '').toString();
        if (name.isEmpty) name = (pf?['full_name'] ?? '').toString().trim();
        if (name.isEmpty) name = 'Unknown';
        list.add({
          'id': e.key,
          'name': name,
          'username': (pf?['username'] ?? '').toString(),
          'avatar': (pf?['avatar_url'] ?? '').toString(),
        });
      }
      list.sort((a, b) => (a['name'] as String)
          .toLowerCase()
          .compareTo((b['name'] as String).toLowerCase()));
      if (!mounted) return;
      setState(() {
        _contacts = list;
        _loading = false;
      });
    } catch (_) {
      _blockWith('Could not load your contacts, please try again.');
    }
  }

  void _blockWith(String t) {
    if (!mounted) return;
    setState(() {
      _block = t;
      _loading = false;
    });
  }

  Future<void> _add() async {
    if (_busy || _picked.isEmpty) return;
    if (_picked.length > _slots) {
      setState(() => _error =
          'This call has room for ${_slots < 0 ? 0 : _slots} more ${_slots == 1 ? 'person' : 'people'}.');
      return;
    }
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      final mine = await SupaFlow.client
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('id', _me)
          .single();
      final nowIso = DateTime.now().toUtc().toIso8601String();
      await SupaFlow.client.from('active_incoming_calls').upsert([
        for (final id in _picked)
          {
            'user_id': id,
            'call_id': widget.callId,
            'conversation_id': null,
            'caller_id': _me,
            'caller_name': mine['full_name'],
            'caller_avatar': mine['avatar_url'],
            'call_type': _callType,
            'status': 'ringing',
            'agora_channel_name': widget.channelName,
            'updated_at': nowIso,
          }
      ]);
      final all = <String>{..._alreadyInvited, ..._picked}.toList();
      await SupaFlow.client
          .from('calls')
          .update({'invited_user_ids': all}).eq('id', widget.callId);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not add people, please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _row(Map<String, dynamic> c) {
    final id = c['id'] as String;
    final name = c['name'] as String;
    final avatar = c['avatar'] as String;
    final user = c['username'] as String;
    final on = _picked.contains(id);
    return InkWell(
      onTap: () => setState(() {
        if (on) {
          _picked.remove(id);
        } else {
          _picked.add(id);
        }
        _error = '';
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(on ? Icons.check_circle : Icons.circle_outlined,
                color: on ? _purple : _soft),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 22,
              backgroundColor: _purple.withOpacity(0.18),
              backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
              child: avatar.isEmpty
                  ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          color: _purple, fontWeight: FontWeight.w700))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  if (user.isNotEmpty)
                    Text('@${user.replaceFirst(RegExp(r'^@+'), '')}',
                        style: TextStyle(color: _soft, fontSize: 12.5)),
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
    final maxH = MediaQuery.of(context).size.height * 0.8;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final q = _query.trim().toLowerCase();
    final shown = q.isEmpty
        ? _contacts
        : _contacts.where((c) {
            return (c['name'] as String).toLowerCase().contains(q) ||
                (c['username'] as String).toLowerCase().contains(q);
          }).toList();
    return Container(
      constraints: BoxConstraints(maxHeight: maxH + bottom),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: _soft.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Text('Add people to the call',
                style: TextStyle(
                    color: _ink, fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator(color: _purple)),
              )
            else if (_block.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(_block,
                    style: TextStyle(color: _soft, fontSize: 14.5)),
              )
            else ...[
              TextField(
                controller: _search,
                onChanged: (v) => setState(() => _query = v),
                style: TextStyle(color: _ink),
                decoration: InputDecoration(
                  hintText: 'Search your contacts',
                  hintStyle: TextStyle(color: _soft),
                  prefixIcon: Icon(Icons.search, color: _soft),
                  filled: true,
                  fillColor:
                      _dark ? const Color(0xFF2A1F3F) : const Color(0xFFF2EEF8),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: shown.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                              q.isEmpty
                                  ? 'No one else to add'
                                  : 'No contacts found',
                              style: TextStyle(color: _soft)),
                        ),
                      )
                    : ListView(
                        shrinkWrap: true,
                        children: [for (final c in shown) _row(c)],
                      ),
              ),
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error,
                      style: const TextStyle(
                          color: _red,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                      _picked.isEmpty
                          ? 'Room for ${_slots < 0 ? 0 : _slots} more'
                          : '${_picked.length} selected',
                      style: TextStyle(color: _soft, fontSize: 13)),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: (_busy || _picked.isEmpty) ? null : _add,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _purple.withOpacity(0.35),
                      disabledForegroundColor: Colors.white70,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(_busy ? 'Adding...' : 'Add to call'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
