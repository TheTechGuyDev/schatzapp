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

Future<void> ensureAgoraJoined(String channelName, bool isVideoCall) async {
  // If an engine already exists, this device already joined (this is the
  // caller, who joined on ActiveCallScreen) — nothing more to do here.
  if (AgoraCallManager.engine != null) return;

  try {
    final uid = DateTime.now().microsecondsSinceEpoch.remainder(1000000000);
    final token = await getAgoraToken(channelName, uid);

    if (token == null || token.isEmpty) {
      debugPrint(
          'ensureAgoraJoined: failed to get Agora token for channel $channelName');
      return;
    }

    await joinAgoraCall(
      'a7f7c3f7f8f6427a96f33e4808423324',
      channelName,
      token,
      uid,
      isVideoCall,
    );
  } catch (e) {
    debugPrint('ensureAgoraJoined failed: $e');
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
