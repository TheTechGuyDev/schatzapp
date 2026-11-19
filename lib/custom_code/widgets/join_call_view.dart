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

import 'dart:async';
import '/custom_code/actions/index.dart';
import 'package:go_router/go_router.dart';

class JoinCallView extends StatefulWidget {
  const JoinCallView({
    super.key,
    this.width,
    this.height,
    required this.code,
  });

  final double? width;
  final double? height;
  final String code;

  @override
  State<JoinCallView> createState() => _JoinCallViewState();
}

class _JoinCallViewState extends State<JoinCallView> {
  static const Color _purple = Color(0xFF935CCC);

  bool _waiting = false;
  bool _joining = true;
  bool _started = false;
  String _error = '';
  Timer? _poll;

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _ink => _dark ? Colors.white : const Color(0xFF1B1230);
  Color get _soft => _dark ? Colors.white70 : const Color(0xFF6B6480);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  String _friendly(Object e) {
    final s = e.toString();
    if (s.contains('LINK_EXPIRED')) return 'This invitation link has expired.';
    if (s.contains('LINK_INACTIVE')) {
      return 'This link has been turned off by the person who made it.';
    }
    if (s.contains('LINK_NOT_FOUND')) return 'That link was not found.';
    if (s.contains('CALL_ENDED')) {
      return 'This call has already ended. Ask for a new link.';
    }
    if (s.contains('CALL_FULL')) return 'This call is full.';
    if (s.contains('NOT_SIGNED_IN'))
      return 'Please sign in, then open the link again.';
    if (s.contains('APPROVAL_REQUIRED')) {
      return 'The host needs to approve you before you can join.';
    }
    if (s.contains('REMOVED_FROM_CALL')) {
      return 'You were removed from this call and cannot rejoin it.';
    }
    return 'Something went wrong, please try again.';
  }

  void _fail(String msg) {
    if (!mounted) return;
    setState(() {
      _joining = false;
      _waiting = false;
      _error = msg;
    });
  }

  void _leave() {
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed('HomePage');
    }
  }

  Future<void> _start() async {
    if (_started && _joining) return;
    _started = true;
    setState(() {
      _joining = true;
      _waiting = false;
      _error = '';
    });
    final code = widget.code.trim().toUpperCase();
    if (code.length < 6) {
      _fail('That link or code was not found.');
      return;
    }
    if (SupaFlow.client.auth.currentUser == null) {
      _fail('Please sign in, then open the link again.');
      return;
    }
    try {
      final res = await SupaFlow.client
          .rpc('request_call_join', params: {'p_code': code});
      final status =
          (Map<String, dynamic>.from(res as Map)['status'] ?? '').toString();
      if (status == 'approved') {
        await _doJoin(code);
      } else if (status == 'pending') {
        _wait(code);
      } else {
        _fail('The host did not let you into this call.');
      }
    } catch (e) {
      _fail(_friendly(e));
    }
  }

  void _wait(String code) {
    _poll?.cancel();
    final until = DateTime.now().add(const Duration(minutes: 5));
    if (mounted) {
      setState(() {
        _joining = false;
        _waiting = true;
      });
    }
    _poll = Timer.periodic(const Duration(seconds: 3), (t) async {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (DateTime.now().isAfter(until)) {
        t.cancel();
        _fail('The host has not answered yet. Try the link again later.');
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
          _fail('The host did not let you into this call.');
        }
      } catch (e) {
        t.cancel();
        _fail(_friendly(e));
      }
    });
  }

  Future<void> _doJoin(String code) async {
    try {
      final res = await SupaFlow.client
          .rpc('join_call_link', params: {'p_code': code, 'p_uid': 0});
      final m = Map<String, dynamic>.from(res as Map);
      if (!mounted) return;
      await goToConnectedCallScreen(
        m['call_id'].toString(),
        '',
        'Call link',
        '',
        m['call_type'].toString(),
        m['agora_channel_name'].toString(),
      );
    } catch (e) {
      _fail(_friendly(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _error.isNotEmpty;
    return Container(
      width: widget.width,
      height: widget.height,
      color: _dark ? const Color(0xFF14101F) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasError ? Icons.link_off : Icons.videocam_outlined,
              size: 56,
              color: _purple,
            ),
            const SizedBox(height: 20),
            Text(
              hasError
                  ? 'Cannot join this call'
                  : (_waiting ? 'Waiting for the host' : 'Joining the call'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _ink, fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              hasError
                  ? _error
                  : (_waiting
                      ? 'The host will let you in shortly. Keep this screen open.'
                      : 'Please wait a moment.'),
              textAlign: TextAlign.center,
              style: TextStyle(color: _soft, fontSize: 14.5),
            ),
            const SizedBox(height: 24),
            if (!hasError)
              const SizedBox(
                width: 28,
                height: 28,
                child:
                    CircularProgressIndicator(strokeWidth: 3, color: _purple),
              ),
            if (hasError)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                onPressed: () {
                  _started = false;
                  _start();
                },
                child: const Text('Try again'),
              ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _leave,
              child: Text(_waiting ? 'Cancel' : 'Back',
                  style: TextStyle(color: _soft)),
            ),
          ],
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
