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

import 'dart:async';
import '/custom_code/actions/join_agora_call.dart';

Future<void> endCall(String callId) async {
  final now = DateTime.now().toUtc();
  final me = SupaFlow.client.auth.currentUser?.id;

  try {
    final callRow = await SupaFlow.client
        .from('calls')
        .select(
            'started_at, status, conversation_id, caller_id, call_type, is_group')
        .eq('id', callId)
        .maybeSingle()
        .timeout(const Duration(seconds: 5));

    // Group call: leaving only ends the call for everyone when nobody else
    // is still in it.
    if (callRow != null && callRow['is_group'] == true && me != null) {
      try {
        await SupaFlow.client
            .from('call_participants')
            .update({'left_at': now.toIso8601String(), 'status': 'left'})
            .eq('call_id', callId)
            .eq('user_id', me)
            .timeout(const Duration(seconds: 5));

        final others = await SupaFlow.client
            .from('call_participants')
            .select('user_id')
            .eq('call_id', callId)
            .neq('user_id', me)
            .not('joined_at', 'is', null)
            .filter('left_at', 'is', null)
            .timeout(const Duration(seconds: 5));

        if ((others as List).isNotEmpty) {
          unawaited(_leaveAgoraOnly());
          return;
        }
      } catch (e) {
        debugPrint('endCall group leave failed: $e');
      }
    }

    if (callRow != null) {
      final priorStatus = callRow['status'] as String?;

      // decline_call.dart already finalized the row and logged its own
      // message for a declined call - don't double-log it here.
      if (priorStatus != 'declined') {
        final wasAnswered = priorStatus == 'answered';
        int? durationSeconds;
        if (wasAnswered && callRow['started_at'] != null) {
          final startedAt = DateTime.parse(callRow['started_at'] as String);
          durationSeconds = now.difference(startedAt).inSeconds;
          if (durationSeconds < 0) durationSeconds = 0;
        }

        await SupaFlow.client
            .from('calls')
            .update({
              'status': wasAnswered ? 'ended' : 'missed',
              'ended_at': now.toIso8601String(),
              if (durationSeconds != null) 'duration_seconds': durationSeconds,
            })
            .eq('id', callId)
            .timeout(const Duration(seconds: 5));

        final conversationId = callRow['conversation_id'] as String?;
        final callerId = callRow['caller_id'] as String?;
        final callType = (callRow['call_type'] as String?) ?? 'voice';
        if (conversationId != null && callerId != null) {
          try {
            await SupaFlow.client.from('messages').insert({
              'conversation_id': conversationId,
              'sender_id': callerId,
              'message_type': 'call',
              'content': '$callType:${wasAnswered ? 'answered' : 'missed'}',
              if (durationSeconds != null) 'duration_seconds': durationSeconds,
            }).timeout(const Duration(seconds: 5));
          } catch (e) {
            debugPrint('endCall message insert failed: $e');
          }
        }
      }
    }
  } catch (e) {
    debugPrint('endCall status update failed: $e');
  }

  // Everything below is cleanup, not something the UI needs to wait on.
  unawaited(_cleanupCall(callId));
}

Future<void> _leaveAgoraOnly() async {
  try {
    await AgoraCallManager.engine
        ?.stopPreview()
        .timeout(const Duration(seconds: 2));
  } catch (_) {}

  try {
    await AgoraCallManager.engine
        ?.leaveChannel()
        .timeout(const Duration(seconds: 2));
  } catch (_) {}

  try {
    await AgoraCallManager.engine?.release();
  } catch (_) {}

  AgoraCallManager.engine = null;
  AgoraCallManager.remoteUid = null;
}

Future<void> _cleanupCall(String callId) async {
  try {
    await SupaFlow.client
        .from('active_incoming_calls')
        .delete()
        .eq('call_id', callId)
        .timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('endCall cleanup (active_incoming_calls) failed: $e');
  }

  await _leaveAgoraOnly();
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
