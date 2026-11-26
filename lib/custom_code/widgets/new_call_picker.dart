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
import 'package:go_router/go_router.dart';
import 'dart:async';

class NewCallPicker extends StatefulWidget {
  const NewCallPicker({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
  });

  final double? width;
  final double? height;
  final String currentUserId;

  @override
  State<NewCallPicker> createState() => _NewCallPickerState();
}

class _NewCallPickerState extends State<NewCallPicker> {
  static const Color _purple = Color(0xFF935CCC);

  bool _loading = true;
  bool _searching = false;
  bool _starting = false;
  List<Map<String, dynamic>> _contacts = [];
  List<Map<String, dynamic>> _remote = [];
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;
  String _query = '';
  Set<String> _locked = {};
  final Map<String, Map<String, dynamic>> _picked = {};

  bool get _group => FFAppState().newCallGroupMode;

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _ink => _dark ? Colors.white : const Color(0xFF1B1230);
  Color get _soft => _dark ? Colors.white70 : const Color(0xFF6B6480);

  @override
  void initState() {
    super.initState();
    FFAppState().newCallGroupMode = false;
    FFAppState().addListener(_onApp);
    _loadContacts();
  }

  void _onApp() {
    if (!mounted) return;
    if (!_group) _picked.clear();
    setState(() {});
  }

  @override
  void dispose() {
    FFAppState().removeListener(_onApp);
    FFAppState().newCallGroupMode = false;
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _toast(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  String _clean(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

  Map<String, dynamic> _person(
      String id, String? saved, Map<String, dynamic>? p) {
    final username = (p?['username'] ?? '').toString();
    final full = (p?['full_name'] ?? '').toString();
    final phone = (p?['phone_number'] ?? '').toString();
    String name = _clean(saved ?? '');
    if (name.isEmpty) name = username;
    if (name.isEmpty) name = _clean(full);
    if (name.isEmpty) name = phone.isNotEmpty ? phone : 'Unknown';
    return {
      'id': id,
      'name': name,
      'username': username.replaceFirst(RegExp(r'^@+'), ''),
      'phone': phone,
      'avatar': (p?['avatar_url'] ?? '').toString(),
    };
  }

  Future<void> _loadContacts() async {
    final me = widget.currentUserId;
    try {
      final rows = await SupaFlow.client
          .from('contacts_directory')
          .select('contact_user_id, saved_name')
          .eq('owner_id', me)
          .not('contact_user_id', 'is', null);
      final saved = <String, String>{};
      for (final r in rows as List) {
        final id = r['contact_user_id'] as String?;
        if (id == null || id == me) continue;
        saved[id] = (r['saved_name'] ?? '').toString();
      }
      final profiles = <String, Map<String, dynamic>>{};
      if (saved.isNotEmpty) {
        final pr = await SupaFlow.client
            .from('profiles_public')
            .select('id, full_name, username, avatar_url, phone_number')
            .inFilter('id', saved.keys.toList());
        for (final p in pr as List) {
          profiles[p['id'] as String] = Map<String, dynamic>.from(p);
        }
      }
      try {
        final lockedRaw = await SupaFlow.client.rpc('pcl_locked_peers');
        _locked = {for (final x in (lockedRaw as List)) x.toString()};
      } catch (_) {}
      final list = [
        for (final e in saved.entries) _person(e.key, e.value, profiles[e.key])
      ];
      list.sort((a, b) => (a['name'] as String)
          .toLowerCase()
          .compareTo((b['name'] as String).toLowerCase()));
      if (!mounted) return;
      setState(() {
        _contacts = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _toast('Could not load contacts');
    }
  }

  void _onChanged(String v) {
    setState(() => _query = v);
    _debounce?.cancel();
    final q = v.trim().replaceFirst(RegExp(r'^@+'), '');
    if (q.length < 2) {
      setState(() {
        _remote = [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    _debounce =
        Timer(const Duration(milliseconds: 350), () => _remoteSearch(q));
  }

  Future<void> _remoteSearch(String q) async {
    try {
      final safe = q.replaceAll(RegExp(r'[,()%*]'), '');
      if (safe.isEmpty) return;
      final lockedRaw = await SupaFlow.client.rpc('pcl_locked_peers');
      final locked = <String>{
        for (final x in (lockedRaw as List)) x.toString()
      };
      final rows = await SupaFlow.client
          .from('profiles_public')
          .select('id, full_name, username, avatar_url, phone_number')
          .or('username.ilike.%$safe%,full_name.ilike.%$safe%')
          .neq('id', widget.currentUserId)
          .limit(30);
      if (!mounted || q != _query.trim().replaceFirst(RegExp(r'^@+'), '')) {
        return;
      }
      setState(() {
        _remote = [
          for (final p in rows as List)
            if (!locked.contains(p['id'] as String))
              _person(p['id'] as String, null, Map<String, dynamic>.from(p))
        ];
        _searching = false;
      });
    } catch (_) {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _call(Map<String, dynamic> c, String type) async {
    if (_starting) return;
    _starting = true;
    try {
      final id = c['id'] as String;
      final cid = await findOrCreateConversation(widget.currentUserId, id);
      if (await isPrivateLocked(cid)) {
        _toast('Calls are disabled in a Private Chat Lock chat');
        return;
      }
      final result = await startCall(cid, widget.currentUserId, type);
      if (result == null) {
        _toast('Could not start the call, please try again');
        return;
      }
      if (!mounted) return;
      context.pushNamed('ActiveCallScreen', queryParameters: {
        'callId': result.callId ?? '',
        'conversationId': cid,
        'calleeName': c['name'] as String,
        'calleeAvatar': c['avatar'] as String,
        'callType': type,
        'agoraChannelName': result.agoraChannelName ?? '',
        'agoraToken': result.agoraToken ?? '',
        'agoraUid': (result.agoraUid ?? 0).toString(),
      });
    } catch (_) {
      _toast('Could not start the call, please try again');
    } finally {
      _starting = false;
    }
  }

  // ------------------------------ group call ------------------------------
  void _togglePick(Map<String, dynamic> c) {
    final id = c['id'] as String;
    setState(() {
      if (_picked.containsKey(id)) {
        _picked.remove(id);
      } else {
        _picked[id] = c;
      }
    });
  }

  void _endGroupMode() {
    final app = FFAppState();
    app.update(() => app.newCallGroupMode = false);
    if (mounted) setState(() => _picked.clear());
  }

  Future<void> _startGroup(String type) async {
    if (_starting) return;
    final people =
        _picked.values.where((p) => !_locked.contains(p['id'])).toList();
    if (people.length < 2) {
      _toast('Select at least 2 people');
      return;
    }
    // Limits include the person starting the call.
    final maxOthers = type == 'video' ? 15 : 31;
    if (people.length > maxOthers) {
      _toast(type == 'video'
          ? 'Group video calls allow up to 16 people including you'
          : 'Group voice calls allow up to 32 people including you');
      return;
    }
    _starting = true;
    setState(() {});
    String? callId;
    try {
      final me = widget.currentUserId;
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final channelName = 'call_${DateTime.now().millisecondsSinceEpoch}';
      final agoraUid = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      final mine = await SupaFlow.client
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('id', me)
          .single();

      final callRow = await SupaFlow.client
          .from('calls')
          .insert({
            'conversation_id': null,
            'caller_id': me,
            'callee_id': null,
            'is_group': true,
            'invited_user_ids': [for (final p in people) p['id'] as String],
            'caller_name': mine['full_name'],
            'caller_avatar': mine['avatar_url'],
            'call_type': type,
            'status': 'ringing',
            'started_at': nowIso,
          })
          .select()
          .single();
      callId = callRow['id'] as String;

      await SupaFlow.client.from('call_participants').insert({
        'call_id': callId,
        'user_id': me,
        'joined_at': nowIso,
        'agora_uid': agoraUid,
        'status': 'joined',
      });

      await SupaFlow.client.from('active_incoming_calls').upsert([
        for (final p in people)
          {
            'user_id': p['id'],
            'call_id': callId,
            'conversation_id': null,
            'caller_id': me,
            'caller_name': mine['full_name'],
            'caller_avatar': mine['avatar_url'],
            'call_type': type,
            'status': 'ringing',
            'agora_channel_name': channelName,
            'updated_at': nowIso,
          }
      ]);

      final tokenResponse = await SupaFlow.client.functions.invoke(
        'agora-token',
        body: {'channelName': channelName, 'uid': agoraUid},
      );
      final agoraToken =
          (tokenResponse.data as Map<String, dynamic>)['token'] as String;

      final names = people.map((p) => p['name'] as String).toList();
      final label = names.length <= 2
          ? names.join(', ')
          : '${names.take(2).join(', ')} +${names.length - 2}';

      if (!mounted) return;
      _endGroupMode();
      context.pushNamed('ActiveCallScreen', queryParameters: {
        'callId': callId,
        'conversationId': '',
        'calleeName': label,
        'calleeAvatar': '',
        'callType': type,
        'agoraChannelName': channelName,
        'agoraToken': agoraToken,
        'agoraUid': agoraUid.toString(),
      });
    } catch (_) {
      if (callId != null) {
        try {
          await SupaFlow.client
              .from('active_incoming_calls')
              .delete()
              .eq('call_id', callId);
          await SupaFlow.client
              .from('calls')
              .update({'status': 'missed'}).eq('id', callId);
        } catch (_) {}
      }
      _toast('Could not start the group call, please try again');
    } finally {
      _starting = false;
      if (mounted) setState(() {});
    }
  }

  Widget _groupBar() {
    final n = _picked.length;
    final ready = n >= 2 && !_starting;
    Widget btn(IconData icon, String label, String type) => Expanded(
          child: ElevatedButton.icon(
            onPressed: ready ? () => _startGroup(type) : null,
            icon: Icon(icon, size: 20),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _purple.withOpacity(0.35),
              disabledForegroundColor: Colors.white70,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(n == 0 ? 'Select people for the call' : '$n selected',
                  style: TextStyle(
                      color: _ink, fontWeight: FontWeight.w600, fontSize: 14)),
              const Spacer(),
              TextButton(
                onPressed: _endGroupMode,
                child: Text('Cancel', style: TextStyle(color: _soft)),
              ),
            ],
          ),
          Row(
            children: [
              btn(Icons.call_outlined, 'Voice', 'voice'),
              const SizedBox(width: 10),
              btn(Icons.videocam_outlined, 'Video', 'video'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(Map<String, dynamic> c) {
    final name = c['name'] as String;
    final avatar = c['avatar'] as String;
    final username = c['username'] as String;
    final sub = username.isNotEmpty ? '@$username' : (c['phone'] as String);
    final picked = _picked.containsKey(c['id']);
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (_group)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(picked ? Icons.check_circle : Icons.circle_outlined,
                  color: picked ? _purple : _soft),
            ),
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFEFEBF2),
            backgroundImage: (avatar.toLowerCase().startsWith('http') &&
                    !avatar.toLowerCase().contains('unsplash.com'))
                ? cachedNetworkImageProvider(avatar)
                : null,
            child: (avatar.toLowerCase().startsWith('http') &&
                    !avatar.toLowerCase().contains('unsplash.com'))
                ? null
                : const Icon(Icons.person_outline, color: _purple, size: 28),
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
                if (sub.isNotEmpty)
                  Text(sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _soft, fontSize: 12.5)),
              ],
            ),
          ),
          if (!_group) ...[
            IconButton(
              icon: const Icon(Icons.call_outlined, color: _purple),
              onPressed: () => _call(c, 'voice'),
            ),
            IconButton(
              icon: const Icon(Icons.videocam_outlined, color: _purple),
              onPressed: () => _call(c, 'video'),
            ),
          ],
        ],
      ),
    );
    if (!_group) return row;
    return InkWell(onTap: () => _togglePick(c), child: row);
  }

  @override
  Widget build(BuildContext context) {
    final raw = _query.trim().toLowerCase().replaceFirst(RegExp(r'^@+'), '');
    final local = raw.isEmpty
        ? _contacts
        : _contacts.where((c) {
            return (c['name'] as String).toLowerCase().contains(raw) ||
                (c['username'] as String).toLowerCase().contains(raw) ||
                (c['phone'] as String).toLowerCase().contains(raw);
          }).toList();
    final seen = local.map((e) => e['id']).toSet();
    var extra = _remote.where((e) => !seen.contains(e['id'])).toList();
    var shownLocal = local;
    if (_group) {
      shownLocal = local.where((e) => !_locked.contains(e['id'])).toList();
      extra = extra.where((e) => !_locked.contains(e['id'])).toList();
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        children: [
          TextField(
            controller: _search,
            onChanged: _onChanged,
            style: TextStyle(color: _ink),
            decoration: InputDecoration(
              hintText: 'Search by name or @username',
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
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _purple))
                : ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      if (shownLocal.isEmpty && extra.isEmpty && !_searching)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                                raw.isEmpty
                                    ? 'No contacts on SchatzApp yet'
                                    : 'No users found',
                                style: TextStyle(color: _soft)),
                          ),
                        ),
                      for (final c in shownLocal) _row(c),
                      if (extra.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 4),
                          child: Text('Other people on SchatzApp',
                              style: TextStyle(
                                  color: _soft,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                        for (final c in extra) _row(c),
                      ],
                      if (_searching)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                              child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: _purple))),
                        ),
                    ],
                  ),
          ),
          if (_group) _groupBar(),
        ],
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
