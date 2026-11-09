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

class RingtoneManager {
  static AudioPlayer? player;
  static bool isRinging = false;
}

Future<void> startRingtoneAndVibration() async {
  if (RingtoneManager.isRinging) return;
  RingtoneManager.isRinging = true;

  try {
    RingtoneManager.player = AudioPlayer();
    await RingtoneManager.player!.setUrl(
      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/nexu-xidy5i/assets/s37o3pkeyqma/shyama-preet-mai-tose-laga-baitha-hu-hanshraaj-raghuvansi-bhakti-68029.mp3',
    );
    await RingtoneManager.player!.setLoopMode(LoopMode.one);
    unawaited(RingtoneManager.player!.play());
  } catch (_) {
    // Ringtone is a nice-to-have; a failure here shouldn't block the
    // incoming-call screen itself from showing.
  }

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

void unawaited(Future<void> future) {
  // Deliberately not awaited — playback runs in the background while the
  // incoming-call screen stays interactive.
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
