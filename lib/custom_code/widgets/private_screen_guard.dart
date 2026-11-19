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

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screen_protector/screen_protector.dart';

// How many guards currently ask for protection. Protection is only switched
// off when the last one lets go, so closing a chat on top of the Private Chat
// page does not unprotect the page underneath.
int _guardCount = 0;

class PrivateScreenGuard extends StatefulWidget {
  const PrivateScreenGuard({
    super.key,
    this.width,
    this.height,
    required this.enabled,
  });

  final double? width;
  final double? height;
  final bool enabled;

  @override
  State<PrivateScreenGuard> createState() => _PrivateScreenGuardState();
}

class _PrivateScreenGuardState extends State<PrivateScreenGuard> {
  bool _on = false;

  @override
  void initState() {
    super.initState();
    _apply(widget.enabled);
  }

  @override
  void didUpdateWidget(covariant PrivateScreenGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) _apply(widget.enabled);
  }

  @override
  void dispose() {
    _apply(false);
    super.dispose();
  }

  Future<void> _apply(bool enable) async {
    if (kIsWeb || enable == _on) return;
    _on = enable;
    try {
      if (enable) {
        _guardCount++;
        if (_guardCount == 1) {
          // Android: blocks screenshots, screen recording and the recents
          // preview. iOS: blanks screenshots and recordings and blurs the
          // app switcher.
          await ScreenProtector.preventScreenshotOn();
          await ScreenProtector.protectDataLeakageOn();
        }
      } else {
        if (_guardCount > 0) _guardCount--;
        if (_guardCount == 0) {
          await ScreenProtector.preventScreenshotOff();
          await ScreenProtector.protectDataLeakageOff();
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
