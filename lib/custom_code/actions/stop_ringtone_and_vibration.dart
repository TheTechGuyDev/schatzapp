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

import 'package:vibration/vibration.dart';
import '/custom_code/actions/start_ringtone_and_vibration.dart';

Future<void> stopRingtoneAndVibration() async {
  RingtoneManager.isRinging = false;

  try {
    await RingtoneManager.player?.stop();
    await RingtoneManager.player?.dispose();
  } catch (_) {}
  RingtoneManager.player = null;

  try {
    Vibration.cancel();
  } catch (_) {}
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
