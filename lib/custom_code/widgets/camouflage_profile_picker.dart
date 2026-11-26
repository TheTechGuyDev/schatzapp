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

class CamouflageProfilePicker extends StatefulWidget {
  const CamouflageProfilePicker({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
  });

  final double? width;
  final double? height;
  final String currentUserId;

  @override
  State<CamouflageProfilePicker> createState() =>
      _CamouflageProfilePickerState();
}

class _CamouflageProfilePickerState extends State<CamouflageProfilePicker> {
  static const Color _purple = Color(0xFF935CCC);
  static const int _max = 3;

  bool _loading = true;
  bool _busy = false;
  List<Map<String, dynamic>> _contacts = [];
  Set<String> _selected = {};
  final TextEditingController _search = TextEditingController();
  String _query = '';

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
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

  void _toast(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  String _clean(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

  Future<void> _load() async {
    final me = widget.currentUserId;
    try {
      final rows = await SupaFlow.client
          .from('contacts')
          .select('contact_user_id, saved_name')
          .eq('owner_id', me)
          .not('contact_user_id', 'is', null);
      final saved = <String, String>{};
      for (final r in rows as List) {
        final id = r['contact_user_id'] as String?;
        if (id == null || id == me) continue;
        saved[id] = (r['saved_name'] ?? '').toString();
      }

      final chosen = await SupaFlow.client
          .from('camouflage_profiles')
          .select('contact_user_id')
          .eq('owner_id', me);
      final sel = <String>{};
      for (final r in chosen as List) {
        final id = r['contact_user_id'] as String?;
        if (id != null) sel.add(id);
      }

      final ids = <String>{...saved.keys, ...sel};
      final profiles = <String, Map<String, dynamic>>{};
      if (ids.isNotEmpty) {
        final pr = await SupaFlow.client
            .from('profiles')
            .select('id, full_name, username, avatar_url, phone_number')
            .inFilter('id', ids.toList());
        for (final p in pr as List) {
          profiles[p['id'] as String] = Map<String, dynamic>.from(p);
        }
      }

      final list = <Map<String, dynamic>>[];
      for (final id in ids) {
        final p = profiles[id];
        final username = (p?['username'] ?? '').toString();
        final full = (p?['full_name'] ?? '').toString();
        final phone = (p?['phone_number'] ?? '').toString();
        String name = _clean(saved[id] ?? '');
        if (name.isEmpty) name = username;
        if (name.isEmpty) name = _clean(full);
        if (name.isEmpty) name = phone.isNotEmpty ? phone : 'Unknown';
        list.add({
          'id': id,
          'name': name,
          'username': username.replaceFirst(RegExp(r'^@+'), ''),
          'phone': phone,
          'avatar': (p?['avatar_url'] ?? '').toString(),
        });
      }
      list.sort((a, b) {
        final sa = sel.contains(a['id']) ? 0 : 1;
        final sb = sel.contains(b['id']) ? 0 : 1;
        if (sa != sb) return sa - sb;
        return (a['name'] as String)
            .toLowerCase()
            .compareTo((b['name'] as String).toLowerCase());
      });

      if (!mounted) return;
      setState(() {
        _contacts = list;
        _selected = sel;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _toast('Could not load contacts');
    }
  }

  Future<void> _toggle(String id) async {
    if (_busy) return;
    final isOn = _selected.contains(id);
    if (!isOn && _selected.length >= _max) {
      _toast('You can select a maximum of 3 profiles');
      return;
    }
    _busy = true;
    try {
      if (isOn) {
        await SupaFlow.client
            .from('camouflage_profiles')
            .delete()
            .eq('owner_id', widget.currentUserId)
            .eq('contact_user_id', id);
        if (mounted) setState(() => _selected.remove(id));
      } else {
        await SupaFlow.client.from('camouflage_profiles').insert({
          'owner_id': widget.currentUserId,
          'contact_user_id': id,
        });
        if (mounted) setState(() => _selected.add(id));
      }
    } catch (e) {
      _toast(e.toString().contains('maximum')
          ? 'You can select a maximum of 3 profiles'
          : 'Could not save, please try again');
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase().replaceFirst(RegExp(r'^@+'), '');
    final shown = q.isEmpty
        ? _contacts
        : _contacts.where((c) {
            return (c['name'] as String).toLowerCase().contains(q) ||
                (c['username'] as String).toLowerCase().contains(q) ||
                (c['phone'] as String).toLowerCase().contains(q);
          }).toList();

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        children: [
          TextField(
            controller: _search,
            onChanged: (v) => setState(() => _query = v),
            style: TextStyle(color: _ink),
            decoration: InputDecoration(
              hintText: 'Search by name, number or @username',
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
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('${_selected.length} of $_max selected',
                  style: TextStyle(
                      color: _soft,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _purple))
                : shown.isEmpty
                    ? Center(
                        child: Text(
                            q.isEmpty
                                ? 'No contacts on SchatzApp yet'
                                : 'No contacts found',
                            style: TextStyle(color: _soft)))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: shown.length,
                        itemBuilder: (context, i) {
                          final c = shown[i];
                          final id = c['id'] as String;
                          final name = c['name'] as String;
                          final avatar = c['avatar'] as String;
                          final username = c['username'] as String;
                          final sub = username.isNotEmpty
                              ? '@$username'
                              : (c['phone'] as String);
                          final on = _selected.contains(id);
                          return InkWell(
                            onTap: () => _toggle(id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: _purple.withOpacity(0.18),
                                    backgroundImage: avatar.isNotEmpty
                                        ? cachedNetworkImageProvider(avatar)
                                        : null,
                                    child: avatar.isEmpty
                                        ? Text(
                                            name.isNotEmpty
                                                ? name[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                                color: _purple,
                                                fontWeight: FontWeight.w700))
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: _ink,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15)),
                                        if (sub.isNotEmpty)
                                          Text(sub,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: _soft,
                                                  fontSize: 12.5)),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                      on
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: on ? _purple : _soft),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
