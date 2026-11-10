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
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class CallsTabView extends StatefulWidget {
  const CallsTabView({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
  });

  final double? width;
  final double? height;
  final String currentUserId;

  @override
  State<CallsTabView> createState() => _CallsTabViewState();
}

class _CallsTabViewState extends State<CallsTabView> {
  static const Color _purple = Color(0xFF935CCC);
  static const Color _red = Color(0xFFDF1609);

  bool _loading = true;
  bool _showContacts = false; // hidden by default
  List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> _contacts = [];
  final TextEditingController _search = TextEditingController();
  String _query = '';
  bool _starting = false;

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _ink => _dark ? Colors.white : const Color(0xFF1B1230);
  Color get _soft => _dark ? Colors.white70 : const Color(0xFF6B6480);

  @override
  void initState() {
    super.initState();
    FFAppState().addListener(_onApp);
    _load();
  }

  @override
  void dispose() {
    FFAppState().removeListener(_onApp);
    _search.dispose();
    super.dispose();
  }

  void _onApp() {
    if (mounted) setState(() {});
  }

  void _toast(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  String _clean(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

  // Same order the chat list uses: saved name, then username, then full name.
  String _nameFor(String id, Map<String, String> saved,
      Map<String, Map<String, dynamic>> profiles) {
    final s = saved[id];
    if (s != null && _clean(s).isNotEmpty) return _clean(s);
    final p = profiles[id];
    final u = (p?['username'] ?? '').toString();
    if (u.isNotEmpty) return u;
    final f = (p?['full_name'] ?? '').toString();
    if (f.isNotEmpty) return _clean(f);
    final ph = (p?['phone_number'] ?? '').toString();
    return ph.isNotEmpty ? ph : 'Unknown';
  }

  Future<void> _load() async {
    final me = widget.currentUserId;
    try {
      final callRows = await SupaFlow.client
          .from('calls')
          .select()
          .or('caller_id.eq.$me,callee_id.eq.$me')
          .order('started_at', ascending: false)
          .limit(50);

      final contactRows = await SupaFlow.client
          .from('contacts_directory')
          .select('contact_user_id, saved_name')
          .eq('owner_id', me)
          .not('contact_user_id', 'is', null);

      final saved = <String, String>{};
      final contactIds = <String>{};
      for (final r in contactRows as List) {
        final id = r['contact_user_id'] as String?;
        if (id == null || id == me) continue;
        contactIds.add(id);
        final n = (r['saved_name'] ?? '').toString();
        if (n.isNotEmpty) saved[id] = n;
      }

      final otherIds = <String>{...contactIds};
      for (final r in callRows as List) {
        final other = r['caller_id'] == me ? r['callee_id'] : r['caller_id'];
        if (other is String && other.isNotEmpty) otherIds.add(other);
      }

      final profiles = <String, Map<String, dynamic>>{};
      if (otherIds.isNotEmpty) {
        final pr = await SupaFlow.client
            .from('profiles')
            .select('id, full_name, username, avatar_url, phone_number')
            .inFilter('id', otherIds.toList());
        for (final p in pr as List) {
          profiles[p['id'] as String] = Map<String, dynamic>.from(p);
        }
      }

      final history = <Map<String, dynamic>>[];
      for (final r in callRows as List) {
        final outgoing = r['caller_id'] == me;
        final otherId =
            ((outgoing ? r['callee_id'] : r['caller_id']) ?? '').toString();
        final dur = r['duration_seconds'] as int?;
        final status = r['status'] as String?;
        String dir;
        if (outgoing) {
          dir = 'Outgoing';
        } else if (status == 'declined') {
          dir = 'Declined';
        } else if (dur != null && dur > 0) {
          dir = 'Incoming';
        } else {
          dir = 'Missed';
        }
        history.add({
          'id': r['id'].toString(),
          'conversation_id': (r['conversation_id'] ?? '').toString(),
          'other_id': otherId,
          'name': otherId.isEmpty
              ? _clean((r['caller_name'] ?? 'Unknown').toString())
              : _nameFor(otherId, saved, profiles),
          'avatar': (profiles[otherId]?['avatar_url'] ??
                  (outgoing ? '' : (r['caller_avatar'] ?? '')))
              .toString(),
          'direction': dir,
          'type': (r['call_type'] ?? 'voice').toString(),
          'started_at': r['started_at'],
          'duration': dur,
        });
      }

      final contacts = <Map<String, dynamic>>[];
      for (final id in contactIds) {
        final p = profiles[id];
        contacts.add({
          'id': id,
          'name': _nameFor(id, saved, profiles),
          'username': (p?['username'] ?? '').toString(),
          'phone': (p?['phone_number'] ?? '').toString(),
          'avatar': (p?['avatar_url'] ?? '').toString(),
        });
      }
      contacts.sort((a, b) => (a['name'] as String)
          .toLowerCase()
          .compareTo((b['name'] as String).toLowerCase()));

      if (!mounted) return;
      setState(() {
        _history = history;
        _contacts = contacts;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _toast('Could not load calls');
    }
  }

  // ------------------------------ calling ------------------------------
  Future<void> _call(String otherId, String convoId, String name, String avatar,
      String type) async {
    if (_starting) return;
    _starting = true;
    try {
      var cid = convoId;
      if (cid.isEmpty) {
        cid = await findOrCreateConversation(widget.currentUserId, otherId);
      }
      if (type == 'bimp') {
        final sent = await sendBimp(cid, widget.currentUserId);
        _toast(sent ? 'Bimp sent' : 'Could not send Bimp');
        return;
      }
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
        'calleeName': name,
        'calleeAvatar': avatar,
        'callType': type,
        'agoraChannelName': result.agoraChannelName ?? '',
        'agoraToken': result.agoraToken ?? '',
        'agoraUid': (result.agoraUid ?? 0).toString(),
      });
    } catch (e) {
      _toast('Could not start the call, please try again');
    } finally {
      _starting = false;
    }
  }

  // ------------------------- selection (delete) -------------------------
  void _toggle(String id) {
    final app = FFAppState();
    final list = List<String>.from(app.selectedCallIds);
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    app.update(() => app.selectedCallIds = list);
  }

  void _cancelSelect() {
    final app = FFAppState();
    app.update(() {
      app.callSelectionMode = false;
      app.selectedCallIds = [];
    });
  }

  void _selectAll() {
    final app = FFAppState();
    app.update(() =>
        app.selectedCallIds = _history.map((e) => e['id'] as String).toList());
  }

  Future<void> _deleteSelected() async {
    final ids = List<String>.from(FFAppState().selectedCallIds);
    if (ids.isEmpty) return;
    try {
      await deleteCalls(ids);
    } catch (_) {
      _toast('Could not delete');
    }
    _cancelSelect();
    await _load();
  }

  // ------------------------------ ui bits ------------------------------
  Widget _avatar(String url, String name, double size) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _purple.withOpacity(0.18),
      backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
      child: url.isEmpty
          ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
              style:
                  const TextStyle(color: _purple, fontWeight: FontWeight.w700))
          : null,
    );
  }

  String _when(dynamic raw) {
    if (raw == null) return '';
    final d = DateTime.tryParse(raw.toString())?.toLocal();
    if (d == null) return '';
    final now = DateTime.now();
    final sameDay =
        d.year == now.year && d.month == now.month && d.day == now.day;
    return sameDay
        ? DateFormat('h:mm a').format(d)
        : DateFormat('d MMM, h:mm a').format(d);
  }

  Widget _historyRow(Map<String, dynamic> c, bool selecting) {
    final id = c['id'] as String;
    final missed = c['direction'] == 'Missed';
    final name = c['name'] as String;
    final type = c['type'] as String;
    final selected = FFAppState().selectedCallIds.contains(id);
    IconData dirIcon;
    switch (c['direction']) {
      case 'Outgoing':
        dirIcon = Icons.call_made_rounded;
        break;
      case 'Incoming':
        dirIcon = Icons.call_received_rounded;
        break;
      default:
        dirIcon = Icons.call_missed_rounded;
    }
    final color = missed ? _red : _soft;
    return InkWell(
      onTap: selecting
          ? () => _toggle(id)
          : () => _call(c['other_id'] as String, c['conversation_id'] as String,
              name, c['avatar'] as String, type),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            if (selecting)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                    selected ? Icons.check_circle : Icons.circle_outlined,
                    color: selected ? _purple : _soft),
              ),
            _avatar(c['avatar'] as String, name, 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: missed ? _red : _ink,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(dirIcon, size: 15, color: color),
                      const SizedBox(width: 4),
                      Text('${c['direction']}  ${_when(c['started_at'])}',
                          style: TextStyle(
                              color: color,
                              fontSize: 12.5,
                              fontWeight:
                                  missed ? FontWeight.w600 : FontWeight.w400)),
                    ],
                  ),
                ],
              ),
            ),
            if (!selecting)
              Icon(
                  type == 'video'
                      ? Icons.videocam_outlined
                      : (type == 'bimp'
                          ? Icons.notifications_active_outlined
                          : Icons.call_outlined),
                  color: _purple),
          ],
        ),
      ),
    );
  }

  Widget _contactRow(Map<String, dynamic> c) {
    final name = c['name'] as String;
    final sub = (c['username'] as String).isNotEmpty
        ? '@${(c['username'] as String).replaceFirst(RegExp(r'^@+'), '')}'
        : (c['phone'] as String);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _avatar(c['avatar'] as String, name, 46),
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
          IconButton(
            icon: const Icon(Icons.call_outlined, color: _purple),
            onPressed: () => _call(
                c['id'] as String, '', name, c['avatar'] as String, 'voice'),
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: _purple),
            onPressed: () => _call(
                c['id'] as String, '', name, c['avatar'] as String, 'video'),
          ),
        ],
      ),
    );
  }

  Widget _selectBar() {
    final n = FFAppState().selectedCallIds.length;
    Widget b(IconData i, String l, VoidCallback? t, Color col) => InkWell(
          onTap: t,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(i, color: col, size: 24),
                Text(l,
                    style: TextStyle(
                        color: col, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        b(Icons.check_circle_outline_rounded, 'Select all', _selectAll,
            _purple),
        if (n >= 1) b(Icons.delete_outlined, 'Delete', _deleteSelected, _red),
        b(Icons.close, 'Cancel', _cancelSelect, _soft),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _purple));
    }
    final selecting = FFAppState().callSelectionMode && _history.isNotEmpty;
    final q = _query.trim().toLowerCase();
    final searching = q.isNotEmpty;
    final filtered = !searching
        ? _contacts
        : _contacts.where((c) {
            return (c['name'] as String).toLowerCase().contains(q) ||
                (c['username'] as String).toLowerCase().contains(q) ||
                (c['phone'] as String).toLowerCase().contains(q);
          }).toList();
    final contactsVisible = _showContacts || searching;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: RefreshIndicator(
        color: _purple,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
          children: [
            if (selecting) _selectBar(),
            if (_history.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 6, top: 4),
                child: Text('Recent',
                    style: TextStyle(
                        color: _soft,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
              for (final c in _history) _historyRow(c, selecting),
              const SizedBox(height: 14),
            ],
            Row(
              children: [
                Text('Contacts on ',
                    style: TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const Text('SchatzApp',
                    style: TextStyle(
                        color: _purple,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() {
                    _showContacts = !_showContacts;
                    if (!_showContacts) {
                      _search.clear();
                      _query = '';
                    }
                  }),
                  child: Text(_showContacts ? 'Hide' : 'Unhide',
                      style: const TextStyle(
                          color: _purple, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            if (contactsVisible) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: _search,
                  onChanged: (v) => setState(() => _query = v),
                  style: TextStyle(color: _ink),
                  decoration: InputDecoration(
                    hintText: 'Search contacts on SchatzApp',
                    hintStyle: TextStyle(color: _soft),
                    prefixIcon: Icon(Icons.search, color: _soft),
                    filled: true,
                    fillColor: _dark
                        ? const Color(0xFF2A1F3F)
                        : const Color(0xFFF2EEF8),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                        searching
                            ? 'No contacts found'
                            : 'No contacts on SchatzApp yet',
                        style: TextStyle(color: _soft)),
                  ),
                )
              else
                for (final c in filtered) _contactRow(c),
            ],
          ],
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
