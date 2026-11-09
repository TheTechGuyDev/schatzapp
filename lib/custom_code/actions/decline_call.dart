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

Future<String> declineCall(String callId) async {
  final me = SupaFlow.client.auth.currentUser?.id;

  // Group call: declining only removes this person's ring. The call keeps
  // going for everyone else.
  try {
    final info = await SupaFlow.client
        .from('calls')
        .select('is_group')
        .eq('id', callId)
        .maybeSingle();
    if (info != null && info['is_group'] == true && me != null) {
      await SupaFlow.client
          .from('active_incoming_calls')
          .delete()
          .eq('call_id', callId)
          .eq('user_id', me);
      return 'SUCCESS';
    }
  } catch (e) {
    return 'ERROR (group decline): $e';
  }

  try {
    final result = await SupaFlow.client
        .from('calls')
        .update({'status': 'declined'})
        .eq('id', callId)
        .select();

    if (result.isEmpty) {
      return 'ERROR: update matched 0 rows (likely blocked by RLS)';
    }

    final callRow = result.first;
    final conversationId = callRow['conversation_id'] as String?;
    final callerId = callRow['caller_id'] as String?;
    final callType = (callRow['call_type'] as String?) ?? 'voice';
    if (conversationId != null && callerId != null) {
      try {
        await SupaFlow.client.from('messages').insert({
          'conversation_id': conversationId,
          'sender_id': callerId,
          'message_type': 'call',
          'content': '$callType:declined',
        });
      } catch (e) {
        debugPrint('declineCall message insert failed: $e');
      }
    }
  } catch (e) {
    return 'ERROR: $e';
  }

  try {
    await SupaFlow.client
        .from('active_incoming_calls')
        .delete()
        .eq('call_id', callId);
  } catch (e) {
    return 'ERROR (cleanup): $e';
  }

  return 'SUCCESS';
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
