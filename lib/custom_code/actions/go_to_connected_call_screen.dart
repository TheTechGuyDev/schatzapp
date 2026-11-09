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

import '/flutter_flow/nav/nav.dart';
import 'package:go_router/go_router.dart';

Future<void> goToConnectedCallScreen(
  String? callId,
  String? conversationId,
  String otherUserName,
  String? otherUserAvatar,
  String? callType,
  String? agoraChannelName,
) async {
  debugPrint(
      'goToConnectedCallScreen: called with callId=$callId, conversationId=$conversationId, '
      'otherUserAvatar=$otherUserAvatar, callType=$callType, agoraChannelName=$agoraChannelName');

  if (callId == null) {
    debugPrint('goToConnectedCallScreen: ABORTED — callId was null');
    return;
  }

  final params = {
    'callId': callId,
    'conversationId': conversationId ?? '',
    'otherUserName': otherUserName,
    'otherUserAvatar': otherUserAvatar ?? '',
    'callType': callType ?? '',
    'agoraChannelName': agoraChannelName ?? '',
  };

  for (var attempt = 0; attempt < 10; attempt++) {
    final ctx = appNavigatorKey.currentContext;
    if (ctx != null) {
      try {
        GoRouter.of(ctx)
            .pushNamed('ConnectedCallScreen', queryParameters: params);
        debugPrint(
            'goToConnectedCallScreen: navigation requested on attempt $attempt');
        return;
      } catch (e) {
        debugPrint(
            'goToConnectedCallScreen: pushNamed threw on attempt $attempt: $e');
      }
    }
    await Future.delayed(const Duration(milliseconds: 100));
  }

  debugPrint(
      'goToConnectedCallScreen: FAILED to navigate for callId=$callId after 10 retries');
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
