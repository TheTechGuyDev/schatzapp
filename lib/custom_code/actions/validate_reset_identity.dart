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

import '/auth/supabase_auth/auth_util.dart';

Future<bool> validateResetIdentity(String phone, String email) async {
  try {
    final result =
        await SupaFlow.client.rpc('validate_reset_identity', params: {
      'p_phone': phone,
      'p_email': email,
    });
    if (result is Map && result['success'] == true) {
      FFAppState().resetErrorMessage = '';
      FFAppState().update(() {});
      return true;
    } else {
      FFAppState().resetErrorMessage = result is Map
          ? (result['error']?.toString() ?? 'Wrong details. Please try again.')
          : 'Wrong details. Please try again.';
      FFAppState().update(() {});
      return false;
    }
  } catch (e) {
    FFAppState().resetErrorMessage = 'Something went wrong. Please try again.';
    FFAppState().update(() {});
    return false;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
