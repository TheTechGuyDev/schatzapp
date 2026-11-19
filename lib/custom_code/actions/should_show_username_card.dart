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

Future<bool> shouldShowUsernameCard() async {
  final uid = SupaFlow.client.auth.currentUser?.id;
  if (uid == null) return false;
  try {
    final profile = await SupaFlow.client
        .from('profiles')
        .select('username')
        .eq('id', uid)
        .maybeSingle();
    final username = (profile?['username'] ?? '').toString().trim();
    if (username.isNotEmpty) return false;

    final wallet = await SupaFlow.client
        .from('wallets')
        .select('id')
        .eq('user_id', uid)
        .limit(1);
    return (wallet as List).isNotEmpty;
  } catch (_) {
    return false;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
