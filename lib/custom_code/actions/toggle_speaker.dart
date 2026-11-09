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

import '/custom_code/actions/join_agora_call.dart';

Future<bool> toggleSpeaker() async {
  AgoraCallManager.isSpeakerOn = !AgoraCallManager.isSpeakerOn;
  try {
    await AgoraCallManager.engine
        ?.setEnableSpeakerphone(AgoraCallManager.isSpeakerOn);
  } catch (_) {
    // not supported on some platforms (e.g. desktop web) — safe to ignore
  }
  return AgoraCallManager.isSpeakerOn;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
