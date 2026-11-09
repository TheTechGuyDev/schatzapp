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

Future<void> enableVideoMidCall() async {
  final engine = AgoraCallManager.engine;
  if (engine == null) {
    debugPrint('enableVideoMidCall: ABORTED — engine was null');
    return;
  }

  debugPrint('enableVideoMidCall: called');

  try {
    await engine.enableVideo();
    debugPrint('enableVideoMidCall: enableVideo() succeeded');
  } catch (e) {
    debugPrint('enableVideoMidCall: enableVideo() FAILED: $e');
  }

  try {
    await engine.startPreview();
    debugPrint('enableVideoMidCall: startPreview() succeeded');
  } catch (e) {
    debugPrint('enableVideoMidCall: startPreview() FAILED: $e');
    AgoraCallManager.isVideoCall = false;
    return;
  }

  try {
    // publishMicrophoneTrack must follow whatever the user's mute state
    // already is, not be hardcoded true — otherwise switching to video
    // while muted would silently un-mute the person without them tapping
    // anything.
    await engine.updateChannelMediaOptions(
      ChannelMediaOptions(
        publishCameraTrack: true,
        publishMicrophoneTrack: !AgoraCallManager.isMuted,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
    debugPrint(
        'enableVideoMidCall: updateChannelMediaOptions (publish camera) succeeded');
  } catch (e) {
    debugPrint('enableVideoMidCall: updateChannelMediaOptions FAILED: $e');
    AgoraCallManager.isVideoCall = false;
    return;
  }

  AgoraCallManager.isVideoCall = true;
  AgoraCallManager.isVideoOff = false;
  debugPrint('enableVideoMidCall: completed successfully');
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
