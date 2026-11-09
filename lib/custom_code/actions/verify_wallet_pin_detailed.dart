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

import 'dart:convert';
import '/auth/supabase_auth/auth_util.dart';

Future<String> verifyWalletPinDetailed(String pin) async {
  try {
    final result = await SupaFlow.client.rpc('verify_wallet_pin', params: {
      'p_pin': pin,
    });
    if (result is Map) {
      return jsonEncode(result);
    }
    return jsonEncode({'success': false, 'blocked': false});
  } catch (e) {
    return jsonEncode({'success': false, 'blocked': false});
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
