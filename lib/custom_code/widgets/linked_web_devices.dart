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

import '/flutter_flow/nav/nav.dart';

class LinkedWebDevices extends StatefulWidget {
  const LinkedWebDevices({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  State<LinkedWebDevices> createState() => _LinkedWebDevicesState();
}

class _LinkedWebDevicesState extends State<LinkedWebDevices> {
  static const Color _purple = Color(0xFF935CCC);

  List<Map<String, dynamic>> _devices = [];
  bool _loading = true;
  bool _busy = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await SupaFlow.client
          .from('web_devices')
          .select()
          .isFilter('revoked_at', null)
          .order('last_active_at', ascending: false);
      if (!mounted) return;
      setState(() {
        _devices = List<Map<String, dynamic>>.from(rows as List);
        _loading = false;
        _error = '';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load linked devices.';
      });
    }
  }

  void _toast(String text) {
    final ctx = appNavigatorKey.currentContext;
    if (ctx == null) return;
    ScaffoldMessenger.maybeOf(ctx)?.showSnackBar(SnackBar(content: Text(text)));
  }

  Future<bool> _confirm(String title, String body, String action) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF667781))),
          ),
          TextButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: Text(action,
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _logoutOne(Map<String, dynamic> d) async {
    if (_busy) return;
    final name = '${d['device_name'] ?? 'this device'}';
    if (!await _confirm('Log out $name?',
        'This browser will be signed out right away.', 'Log out')) {
      return;
    }
    setState(() => _busy = true);
    try {
      await SupaFlow.client
          .rpc('revoke_web_device', params: {'p_device_id': d['id']});
      _toast('Device logged out.');
    } catch (_) {
      _toast('Could not log out this device.');
    }
    if (mounted) setState(() => _busy = false);
    await _load();
  }

  Future<void> _logoutAll() async {
    if (_busy || _devices.isEmpty) return;
    if (!await _confirm('Log out of all devices?',
        'Every linked browser will be signed out right away.', 'Log out all')) {
      return;
    }
    setState(() => _busy = true);
    try {
      await SupaFlow.client.rpc('revoke_all_web_devices');
      _toast('All devices logged out.');
    } catch (_) {
      _toast('Could not log out your devices.');
    }
    if (mounted) setState(() => _busy = false);
    await _load();
  }

  String _ago(dynamic iso) {
    final t = DateTime.tryParse('${iso ?? ''}')?.toLocal();
    if (t == null) return '';
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Active now';
    if (diff.inMinutes < 60) return 'Active ${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'Active ${diff.inHours} h ago';
    return 'Active ${diff.inDays} d ago';
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: _purple));
    } else if (_error.isNotEmpty) {
      body = Center(
        child: TextButton(
          onPressed: () {
            setState(() => _loading = true);
            _load();
          },
          child: Text('$_error Tap to retry.'),
        ),
      );
    } else if (_devices.isEmpty) {
      body = const Center(
        child: Text('No linked devices yet.',
            style: TextStyle(color: Color(0xFF667781))),
      );
    } else {
      body = ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: _devices.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final d = _devices[i];
          final location = '${d['location'] ?? ''}';
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9EDEF)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEBF2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.computer, color: _purple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${d['device_name'] ?? 'Web browser'}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(
                        [_ago(d['last_active_at']), location]
                            .where((s) => s.isNotEmpty)
                            .join(' . '),
                        style: const TextStyle(
                            fontSize: 12.5, color: Color(0xFF667781)),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _busy ? null : () => _logoutOne(d),
                  child: const Text('Log out',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        },
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Linked devices',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              ),
              if (_devices.length > 1)
                TextButton(
                  onPressed: _busy ? null : _logoutAll,
                  child: const Text('Log out all',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: RefreshIndicator(
              color: _purple,
              onRefresh: _load,
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
