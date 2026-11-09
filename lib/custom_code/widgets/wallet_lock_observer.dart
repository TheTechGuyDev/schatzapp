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

import 'package:flutter/material.dart';

class WalletLockObserver extends StatefulWidget {
  const WalletLockObserver({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  State<WalletLockObserver> createState() => _WalletLockObserverState();
}

class _WalletLockObserverState extends State<WalletLockObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      FFAppState().lastBackgroundedAt = DateTime.now();
      FFAppState().update(() {});
    } else if (state == AppLifecycleState.resumed) {
      final last = FFAppState().lastBackgroundedAt;
      if (last != null &&
          DateTime.now().difference(last).inSeconds >= 60 &&
          FFAppState().hasPinSetup == true) {
        FFAppState().walletLocked = true;
        FFAppState().update(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: widget.width, height: widget.height);
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
