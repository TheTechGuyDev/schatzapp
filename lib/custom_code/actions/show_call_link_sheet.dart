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

import 'dart:async';
import '/flutter_flow/nav/nav.dart';
import '/custom_code/actions/index.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

Future<void> showCallLinkSheet() async {
  final ctx = appNavigatorKey.currentContext;
  if (ctx == null) return;
  await showModalBottomSheet<void>(
    context: ctx,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _CallLinkSheet(),
  );
}

class _CallLinkSheet extends StatefulWidget {
  const _CallLinkSheet();

  @override
  State<_CallLinkSheet> createState() => _CallLinkSheetState();
}

class _CallLinkSheetState extends State<_CallLinkSheet> {
  static const Color _purple = Color(0xFF935CCC);

  bool _busy = false;
  bool _joining = false;
  bool _waiting = false;
  Timer? _poll;
  String _error = '';
  final TextEditingController _code = TextEditingController();

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _dark ? const Color(0xFF1E1630) : Colors.white;
  Color get _ink => _dark ? Colors.white : const Color(0xFF1B1230);
  Color get _soft => _dark ? Colors.white70 : const Color(0xFF6B6480);

  @override
  void dispose() {
    _poll?.cancel();
    _code.dispose();
    super.dispose();
  }

  String _friendly(Object e) {
    final s = e.toString();
    if (s.contains('LINK_EXPIRED')) return 'This invitation link has expired.';
    if (s.contains('LINK_INACTIVE')) {
      return 'This link has been turned off by the person who made it.';
    }
    if (s.contains('LINK_NOT_FOUND')) return 'That link or code was not found.';
    if (s.contains('CALL_ENDED')) {
      return 'This call has already ended. Ask for a new link.';
    }
    if (s.contains('CALL_FULL')) return 'This call is full.';
    if (s.contains('NOT_SIGNED_IN')) return 'Please sign in again.';
    if (s.contains('APPROVAL_REQUIRED')) {
      return 'The host needs to approve you before you can join.';
    }
    if (s.contains('REMOVED_FROM_CALL')) {
      return 'You were removed from this call and cannot rejoin it.';
    }
    return 'Something went wrong, please try again.';
  }

  String _extractCode(String raw) {
    final m = RegExp(r'code\s*[:\-]?\s*([A-Za-z0-9]{12})', caseSensitive: false)
        .firstMatch(raw);
    if (m != null) return m.group(1)!.toUpperCase();
    var t = raw.trim().split('?').first;
    while (t.endsWith('/')) {
      t = t.substring(0, t.length - 1);
    }
    return t.split('/').last.trim().toUpperCase();
  }

  Future<void> _create(String type) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = '';
    });
    String? callId;
    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final channel = 'call_$ts';
      final uid = ts.remainder(100000);

      final res = await SupaFlow.client.rpc('create_call_link', params: {
        'p_call_type': type,
        'p_channel': channel,
        'p_uid': uid,
      });
      final m = Map<String, dynamic>.from(res as Map);
      final code = m['code'].toString();
      callId = m['call_id'].toString();

      var base = '';
      try {
        final cfg = await SupaFlow.client
            .from('app_config')
            .select('value')
            .eq('key', 'call_link_base')
            .maybeSingle();
        base = (cfg?['value'] ?? '').toString().trim();
      } catch (_) {}
      while (base.endsWith('/')) {
        base = base.substring(0, base.length - 1);
      }
      final text = base.isEmpty
          ? 'Join my SchatzApp $type call.\nCode: $code'
          : 'Join my SchatzApp $type call: $base/$code\nCode: $code';
      await Clipboard.setData(ClipboardData(text: text));

      final tokenRes = await SupaFlow.client.functions.invoke(
        'agora-token',
        body: {'channelName': channel, 'uid': uid},
      );
      final token = (tokenRes.data as Map<String, dynamic>)['token'] as String;

      final root = appNavigatorKey.currentContext;
      if (mounted) Navigator.of(context).pop();
      if (root == null) return;
      ScaffoldMessenger.of(root)
          .showSnackBar(const SnackBar(content: Text('Call link copied')));
      GoRouter.of(root).pushNamed('ActiveCallScreen', queryParameters: {
        'callId': callId,
        'conversationId': '',
        'calleeName': 'Call link',
        'calleeAvatar': '',
        'callType': type,
        'agoraChannelName': channel,
        'agoraToken': token,
        'agoraUid': uid.toString(),
      });
    } catch (e) {
      if (callId != null) {
        try {
          await SupaFlow.client
              .from('calls')
              .update({'status': 'missed'}).eq('id', callId);
        } catch (_) {}
      }
      if (mounted) setState(() => _error = _friendly(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _join() async {
    if (_busy) return;
    final code = _extractCode(_code.text);
    if (code.length < 6) {
      setState(() => _error = 'Paste the link or the code first.');
      return;
    }
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      final res = await SupaFlow.client
          .rpc('request_call_join', params: {'p_code': code});
      final status =
          (Map<String, dynamic>.from(res as Map)['status'] ?? '').toString();
      if (status == 'approved') {
        await _doJoin(code);
      } else if (status == 'pending') {
        _startWaiting(code);
      } else {
        if (mounted) {
          setState(() => _error = 'The host did not let you into this call.');
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = _friendly(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // The host asked to approve people: check again every 3 seconds.
  void _startWaiting(String code) {
    _poll?.cancel();
    final until = DateTime.now().add(const Duration(minutes: 5));
    setState(() => _waiting = true);
    _poll = Timer.periodic(const Duration(seconds: 3), (t) async {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (DateTime.now().isAfter(until)) {
        t.cancel();
        setState(() {
          _waiting = false;
          _error = 'The host has not answered yet. Try the link again later.';
        });
        return;
      }
      try {
        final res = await SupaFlow.client
            .rpc('request_call_join', params: {'p_code': code});
        final status =
            (Map<String, dynamic>.from(res as Map)['status'] ?? '').toString();
        if (status == 'approved') {
          t.cancel();
          await _doJoin(code);
        } else if (status == 'denied') {
          t.cancel();
          if (mounted) {
            setState(() {
              _waiting = false;
              _error = 'The host did not let you into this call.';
            });
          }
        }
      } catch (e) {
        t.cancel();
        if (mounted) {
          setState(() {
            _waiting = false;
            _error = _friendly(e);
          });
        }
      }
    });
  }

  Future<void> _doJoin(String code) async {
    try {
      final res = await SupaFlow.client
          .rpc('join_call_link', params: {'p_code': code, 'p_uid': 0});
      final m = Map<String, dynamic>.from(res as Map);
      final root = appNavigatorKey.currentContext;
      if (mounted) Navigator.of(context).pop();
      if (root == null) return;
      await goToConnectedCallScreen(
        m['call_id'].toString(),
        '',
        'Call link',
        '',
        m['call_type'].toString(),
        m['agora_channel_name'].toString(),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _waiting = false;
          _error = _friendly(e);
        });
      }
    }
  }

  Future<void> _paste() async {
    final d = await Clipboard.getData('text/plain');
    if (d?.text != null && mounted) {
      setState(() => _code.text = d!.text!);
    }
  }

  Widget _tile(IconData icon, String title, String sub, VoidCallback onTap) {
    return InkWell(
      onTap: _busy ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: _purple.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: _purple),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: _ink,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  Text(sub, style: TextStyle(color: _soft, fontSize: 12.5)),
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
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
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
            Text('Call link',
                style: TextStyle(
                    color: _ink, fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 6),
            if (_waiting) ...[
              const SizedBox(height: 18),
              const Center(
                  child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: _purple))),
              const SizedBox(height: 14),
              Center(
                child: Text('Waiting for the host to let you in...',
                    style: TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton(
                  onPressed: () {
                    _poll?.cancel();
                    setState(() {
                      _waiting = false;
                      _error = '';
                    });
                  },
                  child: Text('Cancel', style: TextStyle(color: _soft)),
                ),
              ),
            ] else if (!_joining) ...[
              _tile(
                  Icons.call_outlined,
                  'Create a voice call link',
                  'Copies the link and starts the call',
                  () => _create('voice')),
              _tile(
                  Icons.videocam_outlined,
                  'Create a video call link',
                  'Copies the link and starts the call',
                  () => _create('video')),
              _tile(
                  Icons.link,
                  'Join with a link',
                  'Paste a link or code someone sent you',
                  () => setState(() {
                        _joining = true;
                        _error = '';
                      })),
            ] else ...[
              const SizedBox(height: 8),
              TextField(
                controller: _code,
                autofocus: true,
                style: TextStyle(color: _ink),
                decoration: InputDecoration(
                  hintText: 'Paste link or code',
                  hintStyle: TextStyle(color: _soft),
                  filled: true,
                  fillColor:
                      _dark ? const Color(0xFF2A1F3F) : const Color(0xFFF2EEF8),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.content_paste, color: _purple),
                    onPressed: _paste,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                              _joining = false;
                              _error = '';
                            }),
                    child: Text('Back', style: TextStyle(color: _soft)),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _busy ? null : _join,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Join call'),
                  ),
                ],
              ),
            ],
            if (_busy && !_waiting)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Center(
                    child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: _purple))),
              ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error,
                    style: const TextStyle(
                        color: Color(0xFFDF1609),
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
