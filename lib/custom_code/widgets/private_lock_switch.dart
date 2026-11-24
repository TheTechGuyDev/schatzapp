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
import '/custom_code/actions/index.dart';
import '/app_state.dart';

class PrivateLockSwitch extends StatefulWidget {
  const PrivateLockSwitch({
    Key? key,
    this.width,
    this.height,
    required this.conversationId,
    this.isGroup = false,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String conversationId;
  final bool isGroup;

  @override
  State<PrivateLockSwitch> createState() => _PrivateLockSwitchState();
}

class _PrivateLockSwitchState extends State<PrivateLockSwitch> {
  static const Color _purple = Color(0xFF935CCC);

  bool _on = false;
  bool _loaded = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant PrivateLockSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversationId != widget.conversationId ||
        oldWidget.isGroup != widget.isGroup) {
      _load();
    }
  }

  // Always read the real value from the database, never a guess.
  Future<void> _load() async {
    final id = widget.conversationId;
    if (id.isEmpty) {
      if (mounted) setState(() => _loaded = false);
      return;
    }
    final value =
        widget.isGroup ? await isGroupPrivate(id) : await isMyPrivateLock(id);
    if (!mounted || id != widget.conversationId) return;
    setState(() {
      _on = value;
      _loaded = true;
    });
  }

  void _toast(String text) {
    final ctx = appNavigatorKey.currentContext;
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _apply(bool turnOn) async {
    final id = widget.conversationId;
    try {
      if (widget.isGroup) {
        if (turnOn) {
          final ok = await convertGroupToPrivate(id);
          if (!ok) {
            _toast('Could not convert the group');
            return;
          }
          FFAppState().privateUnlockedAt = DateTime.now();
          await goToPrivateChat();
        } else {
          // Asks for confirmation, removes the group, then goes Home. On
          // cancel it reloads the page so the switch matches the database.
          await confirmRemovePrivateGroup(id);
        }
        return;
      }

      final ok = await setPrivateLock(id, turnOn);
      if (!ok) {
        _toast(
            turnOn ? 'Could not lock this chat' : 'Could not unlock this chat');
        return;
      }
      FFAppState().privateUnlockedAt = DateTime.now();
      if (turnOn) {
        await goToPrivateChat();
      } else {
        appNavigatorKey.currentContext?.goNamed('HomePage');
      }
    } finally {
      if (mounted) {
        _busy = false;
        await _load();
      }
    }
  }

  Future<void> _onChanged(bool value) async {
    if (_busy || !_loaded) return;
    _busy = true;
    setState(() => _on = value);

    final passed = await showModalBottomSheet<bool>(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (sheetContext) => const _PasswordSheet(),
    );

    if (passed == true) {
      await _apply(value);
    } else if (mounted) {
      // Closed without a correct password: put the switch back.
      _busy = false;
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Align(
        alignment: Alignment.center,
        child: Switch(
          value: _on,
          onChanged: _loaded ? _onChanged : null,
          activeColor: Colors.white,
          activeTrackColor: _purple,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFD5D9DE),
        ),
      ),
    );
  }
}

class _PasswordSheet extends StatefulWidget {
  const _PasswordSheet();

  @override
  State<_PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends State<_PasswordSheet> {
  static const Color _purple = Color(0xFF935CCC);

  final TextEditingController _pw = TextEditingController();
  bool _checking = false;
  bool _hide = true;
  String _error = '';

  @override
  void dispose() {
    _pw.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _pw.text;
    if (text.isEmpty || _checking) return;
    setState(() {
      _checking = true;
      _error = '';
    });
    final ok = await verifyAppPassword(text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _checking = false;
        _error = 'Incorrect password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Padding(
      padding: MediaQuery.viewInsetsOf(context),
      child: Container(
        width: double.infinity,
        height: height * 0.8,
        padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter App Password',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111B21)),
              ),
              const SizedBox(height: 36),
              TextField(
                controller: _pw,
                autofocus: false,
                obscureText: _hide,
                onSubmitted: (_) => _submit(),
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Enter app password',
                  hintStyle: const TextStyle(color: Color(0xFF667781)),
                  errorText: _error.isEmpty ? null : _error,
                  prefixIcon: const Icon(Icons.lock, color: _purple),
                  suffixIcon: IconButton(
                    icon: Icon(_hide ? Icons.visibility_off : Icons.visibility,
                        color: _purple),
                    onPressed: () => setState(() => _hide = !_hide),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xFFE9EDEF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: _purple),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _checking ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _checking
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Continue',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
