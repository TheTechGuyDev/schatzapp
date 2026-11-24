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
import 'package:flutter/services.dart';

class LinkWithCodeView extends StatefulWidget {
  const LinkWithCodeView({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  State<LinkWithCodeView> createState() => _LinkWithCodeViewState();
}

class _LinkWithCodeViewState extends State<LinkWithCodeView> {
  static const _purple = Color(0xFF935CCC);
  static const _ink = Color(0xFF15122B);
  static const _soft = Color(0xFF6B6480);

  String? _code;
  DateTime? _expiresAt;
  String? _error;
  bool _busy = false;
  Timer? _tick;

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  int get _secondsLeft {
    final e = _expiresAt;
    if (e == null) return 0;
    final s = e.difference(DateTime.now()).inSeconds;
    return s < 0 ? 0 : s;
  }

  Future<void> _getCode() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final res = await SupaFlow.client.functions.invoke(
        'web-login',
        body: {'action': 'issue_code'},
      );
      final data = res.data;
      if (data is Map && data['ok'] == true) {
        _code = '${data['code']}';
        _expiresAt = DateTime.now()
            .add(Duration(seconds: (data['ttl_seconds'] as num).toInt()));
        _tick?.cancel();
        _tick = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          setState(() {});
          if (_secondsLeft == 0) _tick?.cancel();
        });
      } else {
        _error = (data is Map ? data['message'] : null)?.toString() ??
            'Could not get a code. Try again.';
      }
    } on FunctionException catch (e) {
      final d = e.details;
      _error = (d is Map ? d['message'] : null)?.toString() ??
          'Could not get a code. Try again.';
    } catch (_) {
      _error = 'Could not get a code. Check your connection.';
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final code = _code;
    final left = _secondsLeft;
    final expired = code != null && left == 0;
    final shown = code == null
        ? '------'
        : '${code.substring(0, 3)} ${code.substring(3)}';

    return Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECE8F4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.dialpad_rounded, color: _purple, size: 34),
          const SizedBox(height: 10),
          const Text(
            'Link with code',
            style: TextStyle(
                fontSize: 19, fontWeight: FontWeight.w700, color: _ink),
          ),
          const SizedBox(height: 6),
          const Text(
            'On the computer, choose "Log in with Phone Number", '
            'enter your number, then type this code.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, height: 1.4, color: _soft),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: code == null || expired
                ? null
                : () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied')),
                    );
                  },
            child: Text(
              shown,
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                letterSpacing: 6,
                color:
                    expired || code == null ? const Color(0xFFC9C3D6) : _purple,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ??
                (code == null
                    ? 'Tap the button to get a code'
                    : expired
                        ? 'This code has expired'
                        : 'Expires in ${left ~/ 60}:${(left % 60).toString().padLeft(2, '0')}'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: _error != null ? const Color(0xFFE53935) : _soft,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _busy ? null : _getCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(code == null ? 'Get code' : 'Get a new code',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
