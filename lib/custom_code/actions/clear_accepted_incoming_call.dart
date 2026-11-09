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

Future<void> clearAcceptedIncomingCall(
  String? callId,
) async {
  if (callId == null) {
    debugPrint('clearAcceptedIncomingCall: ABORTED — callId was null');
    return;
  }
  try {
    await SupaFlow.client
        .from('active_incoming_calls')
        .delete()
        .eq('call_id', callId);
  } catch (e) {
    debugPrint('clearAcceptedIncomingCall failed: $e');
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
