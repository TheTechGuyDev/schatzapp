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

Future<bool> sendBimp(
  String conversationId,
  String callerId,
) async {
  try {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final convo = await SupaFlow.client
        .from('conversations')
        .select('type')
        .eq('id', conversationId)
        .maybeSingle();
    final isGroup = (convo?['type'] ?? '').toString() == 'group';

    final participantRows = await SupaFlow.client
        .from('conversation_participants')
        .select('user_id')
        .eq('conversation_id', conversationId)
        .neq('user_id', callerId)
        .isFilter('left_at', null);
    final calleeIds = (participantRows as List)
        .map((r) => r['user_id'] as String)
        .toSet()
        .toList();
    if (calleeIds.isEmpty) return false;

    final caller = await SupaFlow.client
        .from('profiles')
        .select('full_name, avatar_url')
        .eq('id', callerId)
        .single();

    final call = await SupaFlow.client
        .from('calls')
        .insert({
          'conversation_id': conversationId,
          'caller_id': callerId,
          'callee_id': isGroup ? null : calleeIds.first,
          'is_group': isGroup,
          'caller_name': caller['full_name'],
          'caller_avatar': caller['avatar_url'],
          'call_type': 'bimp',
          'status': 'ringing',
          'started_at': nowIso,
        })
        .select()
        .single();
    final callId = call['id'] as String;
    final channel = 'bimp_${DateTime.now().millisecondsSinceEpoch}';

    await SupaFlow.client.from('active_incoming_calls').upsert(calleeIds
        .map((id) => {
              'user_id': id,
              'call_id': callId,
              'conversation_id': conversationId,
              'caller_id': callerId,
              'caller_name': caller['full_name'],
              'caller_avatar': caller['avatar_url'],
              'call_type': 'bimp',
              'status': 'ringing',
              'agora_channel_name': channel,
              'updated_at': nowIso,
            })
        .toList());

    // If nobody answers within 40 seconds, mark it missed and stop ringing.
    Future.delayed(const Duration(seconds: 40), () async {
      try {
        final row = await SupaFlow.client
            .from('calls')
            .select('status')
            .eq('id', callId)
            .maybeSingle();
        if (row != null && row['status'] == 'ringing') {
          await SupaFlow.client
              .from('calls')
              .update({'status': 'missed'}).eq('id', callId);
          await SupaFlow.client
              .from('active_incoming_calls')
              .delete()
              .eq('call_id', callId);
        }
      } catch (_) {}
    });
    return true;
  } catch (_) {
    return false;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
