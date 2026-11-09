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

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import '/custom_code/actions/join_agora_call.dart';

Future<bool> toggleMute() async {
  final engine = AgoraCallManager.engine;
  final newMutedState = !AgoraCallManager.isMuted;

  if (engine == null) {
    debugPrint('toggleMute: ABORTED — engine was null');
    AgoraCallManager.isMuted = newMutedState;
    return newMutedState;
  }

  while (AgoraCallManager.isTogglingMute) {
    await Future.delayed(const Duration(milliseconds: 50));
  }
  AgoraCallManager.isTogglingMute = true;

  debugPrint('toggleMute: setting muted=$newMutedState');

  try {
    await engine.updateChannelMediaOptions(
      ChannelMediaOptions(
        publishMicrophoneTrack: !newMutedState,
        publishCameraTrack:
            AgoraCallManager.isVideoCall && !AgoraCallManager.isVideoOff,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
    AgoraCallManager.isMuted = newMutedState;
    debugPrint('toggleMute: succeeded, isMuted=$newMutedState');
  } catch (e) {
    debugPrint('toggleMute: FAILED: $e');
  } finally {
    AgoraCallManager.isTogglingMute = false;
  }

  return AgoraCallManager.isMuted;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
