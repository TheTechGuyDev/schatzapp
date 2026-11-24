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
import '/index.dart' show HomePageWidget, PrivateChatWidget;

/// Resets the stack to Home, then pushes the Private Chat page on top,
/// so Back from Private Chat always lands on Home.
Future<void> goToPrivateChat() async {
  final ctx = appNavigatorKey.currentContext;
  if (ctx == null) return;
  ctx.goNamed(HomePageWidget.routeName);

  // Let Home finish mounting before pushing on top of it.
  await Future.delayed(const Duration(milliseconds: 350));
  final next = appNavigatorKey.currentContext;
  if (next == null) return;

  try {
    next.pushNamed(PrivateChatWidget.routeName);
  } catch (_) {
    ScaffoldMessenger.maybeOf(next)?.showSnackBar(
      const SnackBar(content: Text('Could not open Private Chats')),
    );
  }
}
