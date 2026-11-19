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

import '/flutter_flow/nav/nav.dart';
import '/custom_code/widgets/index.dart' as cw;

OverlayEntry? _globalCallBannerEntry;

Future<void> showGlobalCallBanner() async {
  if (_globalCallBannerEntry != null && _globalCallBannerEntry!.mounted) {
    return;
  }
  final overlay = appNavigatorKey.currentState?.overlay;
  if (overlay == null) return;

  _globalCallBannerEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          bottom: false,
          child: StreamBuilder<AuthState>(
            stream: SupaFlow.client.auth.onAuthStateChange,
            builder: (context, _) {
              final uid = SupaFlow.client.auth.currentUser?.id;
              if (uid == null) return const SizedBox.shrink();
              return cw.IncomingCallBanner(
                key: ValueKey(uid),
                width: double.infinity,
                currentUserId: uid,
              );
            },
          ),
        ),
      ),
    ),
  );
  overlay.insert(_globalCallBannerEntry!);
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
