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

Future<AcceptCallResultStruct?> acceptCall(
  String? callId,
  String? channelName,
  String userId,
) async {
  debugPrint(
      'acceptCall: called with callId=$callId, channelName=$channelName, userId=$userId');

  if (callId == null || channelName == null) {
    debugPrint('acceptCall: ABORTED — callId or channelName was null');
    return null;
  }

  try {
    final existing = await SupaFlow.client
        .from('call_participants')
        .select('id')
        .eq('call_id', callId)
        .eq('user_id', userId)
        .limit(1)
        .maybeSingle()
        .timeout(const Duration(seconds: 8));

    if (existing == null) {
      await SupaFlow.client.from('call_participants').insert({
        'call_id': callId,
        'user_id': userId,
        'joined_at': DateTime.now().toUtc().toIso8601String(),
      }).timeout(const Duration(seconds: 8));
    }

    await SupaFlow.client
        .from('calls')
        .update({
          'status': 'answered',
        })
        .eq('id', callId)
        .timeout(const Duration(seconds: 8));

    debugPrint('acceptCall: succeeded for callId=$callId');

    return AcceptCallResultStruct(
      agoraToken: '',
      agoraUid: 0,
    );
  } catch (e) {
    debugPrint('acceptCall failed: $e');
    return null;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
