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

Future<void> openSavedContactAction(
  String actionType, // 'message', 'voice', 'video', or 'view'
  String currentUserId,
  String contactUserId,
  String contactFullName,
  String contactAvatarUrl,
  String savedName,
  String phoneOrUsername,
) async {
  final ctx = appNavigatorKey.currentContext;

  // Number is not registered on SchatzApp: every card is disabled.
  if (contactUserId.isEmpty) return;

  final displayName = contactFullName.isNotEmpty ? contactFullName : savedName;

  if (actionType == 'view') {
    if (ctx != null) {
      GoRouter.of(ctx).pushNamed(
        'User_profile',
        queryParameters: {'otherUserId': contactUserId},
      );
    }
    return;
  }

  try {
    final conversationId =
        await findOrCreateConversation(currentUserId, contactUserId);

    if (actionType == 'message') {
      if (ctx != null) {
        GoRouter.of(ctx).pushNamed(
          'chatpage',
          queryParameters: {
            'conversationId': conversationId,
            'otherUserId': contactUserId,
            'displayName': displayName,
            'displayAvatar': contactAvatarUrl,
          },
        );
      }
      return;
    }

    final callType = actionType == 'video' ? 'video' : 'audio';
    final callResult = await startCall(conversationId, currentUserId, callType);

    if (callResult == null) {
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
              content: Text("Couldn't start the call, please try again")),
        );
      }
      return;
    }

    if (ctx != null) {
      GoRouter.of(ctx).pushNamed(
        'ActiveCallScreen',
        queryParameters: {
          'callId': callResult.callId ?? '',
          'conversationId': conversationId,
          'calleeName': displayName,
          'calleeAvatar': contactAvatarUrl,
          'callType': callType,
          'agoraChannelName': callResult.agoraChannelName ?? '',
          'agoraToken': callResult.agoraToken ?? '',
          'agoraUid': (callResult.agoraUid ?? 0).toString(),
        },
      );
    }
  } catch (e) {
    debugPrint('openSavedContactAction failed: $e');
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Something went wrong, please try again')),
      );
    }
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
