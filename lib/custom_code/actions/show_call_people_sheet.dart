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
import 'dart:async';

Future<void> showCallPeopleSheet(String callId) async {
  final ctx = appNavigatorKey.currentContext;
  if (ctx == null) return;
  await showModalBottomSheet<void>(
    context: ctx,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _PeopleSheet(callId: callId),
  );
}

class _PeopleSheet extends StatefulWidget {
  const _PeopleSheet({required this.callId});

  final String callId;

  @override
  State<_PeopleSheet> createState() => _PeopleSheetState();
}

class _PeopleSheetState extends State<_PeopleSheet> {
  static const Color _purple = Color(0xFF935CCC);
  static const Color _red = Color(0xFFDF1609);

  final String _me = SupaFlow.client.auth.currentUser?.id ?? '';
  String _hostId = '';
  List<Map<String, dynamic>> _people = [];
  bool _loading = true;
  bool _busy = false;
  String _note = '';
  bool _noteIsError = false;
  Timer? _refresh;

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _dark ? const Color(0xFF1E1630) : Colors.white;
  Color get _ink => _dark ? Colors.white : const Color(0xFF1B1230);
  Color get _soft => _dark ? Colors.white70 : const Color(0xFF6B6480);
  bool get _iAmHost => _hostId.isNotEmpty && _hostId == _me;

  @override
  void initState() {
    super.initState();
    _load();
    _refresh = Timer.periodic(const Duration(seconds: 5), (_) => _load());
  }

  @override
  void dispose() {
    _refresh?.cancel();
    super.dispose();
  }

  String _friendly(Object e) {
    final s = e.toString();
    if (s.contains('NOT_HOST')) {
      return 'Only the person who started the call can do this.';
    }
    if (s.contains('CALL_ENDED') || s.contains('CALL_NOT_FOUND')) {
      return 'This call has already ended.';
    }
    return 'Something went wrong, please try again.';
  }

  void _say(String t, {bool error = false}) {
    if (!mounted) return;
    setState(() {
      _note = t;
      _noteIsError = error;
    });
  }

  Future<void> _load() async {
    try {
      final call = await SupaFlow.client
          .from('calls')
          .select('caller_id')
          .eq('id', widget.callId)
          .maybeSingle();
      final parts = await SupaFlow.client
          .from('call_participants')
          .select('user_id, host_muted_at')
          .eq('call_id', widget.callId)
          .not('joined_at', 'is', null)
          .filter('left_at', 'is', null);
      final ids = <String>[
        for (final p in parts as List) p['user_id'].toString()
      ];
      final profiles = <String, Map<String, dynamic>>{};
      if (ids.isNotEmpty) {
        final pr = await SupaFlow.client
            .from('profiles')
            .select('id, full_name, username, avatar_url')
            .inFilter('id', ids);
        for (final p in pr as List) {
          profiles[p['id'] as String] = Map<String, dynamic>.from(p);
        }
      }
      final host = (call?['caller_id'] ?? '').toString();
      final list = <Map<String, dynamic>>[];
      for (final p in parts) {
        final id = p['user_id'].toString();
        final pf = profiles[id];
        var name = (pf?['full_name'] ?? '').toString().trim();
        if (name.isEmpty) name = (pf?['username'] ?? '').toString();
        if (name.isEmpty) name = 'Unknown';
        list.add({
          'id': id,
          'name': id == _me ? 'You' : name,
          'avatar': (pf?['avatar_url'] ?? '').toString(),
          'muted': p['host_muted_at'] != null,
        });
      }
      list.sort((a, b) {
        int rank(Map<String, dynamic> x) =>
            x['id'] == host ? 0 : (x['id'] == _me ? 1 : 2);
        final r = rank(a).compareTo(rank(b));
        if (r != 0) return r;
        return (a['name'] as String)
            .toLowerCase()
            .compareTo((b['name'] as String).toLowerCase());
      });
      if (!mounted) return;
      setState(() {
        _hostId = host;
        _people = list;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _confirm(String title, String body, String yes) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(yes, style: const TextStyle(color: _red))),
        ],
      ),
    );
    return r == true;
  }

  // Asks the server to also block the person on Agora's side. If it is not
  // possible (keys missing, person not yet registered), the normal mute and
  // remove still apply, so any failure here is ignored.
  Future<void> _enforce(String action, Object? userId) async {
    try {
      await SupaFlow.client.functions.invoke('agora-enforce', body: {
        'call_id': widget.callId,
        'target_user_id': userId,
        'action': action,
      });
    } catch (_) {}
  }

  Future<void> _mute(Map<String, dynamic> p) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await SupaFlow.client.rpc('mute_call_participant',
          params: {'p_call_id': widget.callId, 'p_user_id': p['id']});
      await _enforce('mute', p['id']);
      _say('Muted ${p['name']}');
      await _load();
    } catch (e) {
      _say(_friendly(e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(Map<String, dynamic> p) async {
    if (_busy) return;
    final ok = await _confirm('Remove ${p['name']}?',
        'They will be taken out of the call and cannot rejoin it.', 'Remove');
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await SupaFlow.client.rpc('remove_call_participant',
          params: {'p_call_id': widget.callId, 'p_user_id': p['id']});
      await _enforce('remove', p['id']);
      _say('Removed ${p['name']}');
      await _load();
    } catch (e) {
      _say(_friendly(e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _endAll() async {
    if (_busy) return;
    final ok = await _confirm('End the call for everyone?',
        'Everyone will be disconnected right away.', 'End call');
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await SupaFlow.client
          .rpc('end_call_for_all', params: {'p_call_id': widget.callId});
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _say(_friendly(e), error: true);
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _avatar(String url, String name) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: _purple.withOpacity(0.18),
      backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
      child: url.isEmpty
          ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
              style:
                  const TextStyle(color: _purple, fontWeight: FontWeight.w700))
          : null,
    );
  }

  Widget _row(Map<String, dynamic> p) {
    final id = p['id'] as String;
    final isHost = id == _hostId;
    final isMe = id == _me;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _avatar(p['avatar'] as String, p['name'] as String),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['name'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
                if (isHost || p['muted'] == true)
                  Text(
                      [
                        if (isHost) 'Host',
                        if (p['muted'] == true) 'Muted by host'
                      ].join('  ·  '),
                      style: TextStyle(color: _soft, fontSize: 12.5)),
              ],
            ),
          ),
          if (_iAmHost && !isMe) ...[
            IconButton(
              tooltip: 'Mute',
              icon: const Icon(Icons.mic_off_outlined, color: _purple),
              onPressed: _busy ? null : () => _mute(p),
            ),
            IconButton(
              tooltip: 'Remove',
              icon: const Icon(Icons.person_remove_outlined, color: _red),
              onPressed: _busy ? null : () => _remove(p),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.75;
    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
            Text(
                _loading
                    ? 'People in this call'
                    : 'People in this call (${_people.length})',
                style: TextStyle(
                    color: _ink, fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator(color: _purple)),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [for (final p in _people) _row(p)],
                ),
              ),
            if (_note.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_note,
                    style: TextStyle(
                        color: _noteIsError ? _red : const Color(0xFF2FBF71),
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            if (_iAmHost) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _endAll,
                  icon: const Icon(Icons.call_end_rounded, color: _red),
                  label: const Text('End call for everyone',
                      style:
                          TextStyle(color: _red, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
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
