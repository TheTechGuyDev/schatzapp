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

import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';

// Kept only so older references still compile.
class RingtoneManager {
  static AudioPlayer? player;
  static bool isRinging = false;
}

Future<void> startRingtoneAndVibration() async {
  // Built-in ringtone: no internet file, safe to call repeatedly.
  try {
    await callTone('ringtone');
  } catch (_) {}

  try {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(
        pattern: [0, 800, 500, 800, 500],
        repeat: 1,
      );
    }
  } catch (_) {}
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
