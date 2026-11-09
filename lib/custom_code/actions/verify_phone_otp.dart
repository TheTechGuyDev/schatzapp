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

import 'package:supabase_flutter/supabase_flutter.dart';
import '/auth/supabase_auth/auth_util.dart';

Future<bool> verifyPhoneOtp(String phone, String token) async {
  try {
    final response = await SupaFlow.client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );

    if (response.session == null) return false;

    // Wait for FlutterFlow's own auth state to catch up with the new
    // session before returning, avoids navigating to a gated route
    // (Home) before currentUserUid is actually populated.
    for (var i = 0; i < 20; i++) {
      if (currentUserUid.isNotEmpty) {
        return true;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Fallback: session exists but our local auth state never caught
    // up within 2s, still treat it as success since the real session
    // is valid.
    return true;
  } catch (e) {
    return false;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
