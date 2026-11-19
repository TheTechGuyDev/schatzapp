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

class PrivacyVisibilitySettings extends StatefulWidget {
  const PrivacyVisibilitySettings({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<PrivacyVisibilitySettings> createState() =>
      _PrivacyVisibilitySettingsState();
}

class _PrivacyVisibilitySettingsState extends State<PrivacyVisibilitySettings> {
  static const Color _purple = Color(0xFF935CCC);

  String _numberVis = 'default';
  String _policy = 'everyone';
  bool _loading = true;
  bool _saving = false;
  List<Map<String, dynamic>> _requests = [];
  final Set<String> _busy = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final p = await SupaFlow.client
          .from('profiles')
          .select('number_visibility, message_policy')
          .eq('id', uid)
          .limit(1);
      final n = await SupaFlow.client
          .from('notifications')
          .select()
          .eq('user_id', uid)
          .eq('status', 'pending')
          .inFilter('type', ['friend_request', 'message_request']).order(
              'created_at',
              ascending: false);
      if (!mounted) return;
      setState(() {
        if ((p as List).isNotEmpty) {
          _numberVis = (p.first['number_visibility'] ?? 'default').toString();
          _policy = (p.first['message_policy'] ?? 'everyone').toString();
        }
        _requests = (n as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
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

  Future<void> _setNumber(String v) async {
    if (_saving || v == _numberVis) return;
    final old = _numberVis;
    setState(() {
      _saving = true;
      _numberVis = v;
    });
    try {
      await SupaFlow.client
          .rpc('set_number_visibility', params: {'p_value': v});
    } catch (_) {
      _numberVis = old;
      _toast('Could not save. Try again.');
    }
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _setPolicy(String v) async {
    if (_saving || v == _policy) return;
    final old = _policy;
    setState(() {
      _saving = true;
      _policy = v;
    });
    try {
      await SupaFlow.client.rpc('set_message_policy', params: {'p_policy': v});
      if (v == 'everyone') _toast('All pending requests were accepted');
    } catch (_) {
      _policy = old;
      _toast('Could not save. Try again.');
    }
    if (mounted) setState(() => _saving = false);
    await _load();
  }

  Future<void> _respond(Map<String, dynamic> n, bool accept) async {
    final id = n['id'].toString();
    if (_busy.contains(id)) return;
    setState(() => _busy.add(id));
    try {
      await SupaFlow.client.rpc('respond_notification',
          params: {'p_id': id, 'p_accept': accept});
    } catch (_) {
      _toast('Could not complete that. Try again.');
    }
    if (mounted) setState(() => _busy.remove(id));
    await _load();
  }

  Widget _option(
      {required bool selected,
      required String title,
      required String text,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(selected ? Icons.check_box : Icons.check_box_outline_blank,
                color: selected ? _purple : Colors.black38, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(text,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black54, height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heading(String t) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 4),
        child: Text(t,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
      );

  Widget _requestRow(Map<String, dynamic> n) {
    final busy = _busy.contains(n['id'].toString());
    final from = n['from_user_id']?.toString();
    final name = (n['title'] ?? '').toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (from != null)
            ContactAvatar(
                width: 42, height: 42, size: 42, userId: from, name: name)
          else
            const SizedBox(width: 42, height: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14.5)),
          ),
          SizedBox(
            height: 34,
            child: ElevatedButton(
              onPressed: busy ? null : () => _respond(n, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Accept',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 34,
            child: OutlinedButton(
              onPressed: busy ? null : () => _respond(n, false),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Color(0xFFD9D4DE)),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Decline',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
            child: CircularProgressIndicator(color: _purple, strokeWidth: 2.5)),
      );
    }
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heading('Who can see my number?'),
            _option(
              selected: _numberVis == 'everyone',
              title: 'Everyone',
              text:
                  'People who find and add you through your username can also see your phone number.',
              onTap: () => _setNumber('everyone'),
            ),
            _option(
              selected: _numberVis == 'default',
              title: 'Default',
              text:
                  'Only people who have your phone number can see it. Everyone else sees only your username. Anyone who finds you through your username can message you and view your Stories.',
              onTap: () => _setNumber('default'),
            ),
            const Divider(height: 28),
            _heading('Who can message me?'),
            _option(
              selected: _policy == 'contacts',
              title: 'Only Contacts',
              text:
                  'Only people who have your phone number, or whose requests you have accepted, can message you. People who find you through your username can view and react to your Stories but cannot message you until you accept their request.',
              onTap: () => _setPolicy('contacts'),
            ),
            _option(
              selected: _policy == 'everyone',
              title: 'Everyone (Default)',
              text: 'Anyone can message you.',
              onTap: () => _setPolicy('everyone'),
            ),
            const Divider(height: 28),
            _heading('Requests'),
            if (_requests.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('No pending requests',
                    style: TextStyle(color: Colors.black45)),
              )
            else
              ..._requests.map(_requestRow),
          ],
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
