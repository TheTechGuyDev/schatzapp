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
import 'package:flutter/material.dart';

Future<void> goToPrivateChat() async {
  final ctx = appNavigatorKey.currentContext;
  if (ctx == null) return;
  ctx.goNamed('HomePage');
  await Future.delayed(const Duration(milliseconds: 350));
  final next = appNavigatorKey.currentContext;
  if (next == null) return;

  // The Private Chat page can be registered under either name.
  for (final name in ['PrivateChat', 'private_chat']) {
    try {
      next.pushNamed(name);
      return;
    } catch (_) {}
  }
  ScaffoldMessenger.maybeOf(next)?.showSnackBar(
    const SnackBar(content: Text('Could not open Private Chats')),
  );
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
