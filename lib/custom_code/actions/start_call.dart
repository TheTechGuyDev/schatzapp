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

Future<CallStartResultStruct?> startCall(
  String conversationId,
  String callerId,
  String callType,
) async {
  final nowIso = DateTime.now().toUtc().toIso8601String();
  final channelName = 'call_${DateTime.now().millisecondsSinceEpoch}';
  final agoraUid = DateTime.now().millisecondsSinceEpoch.remainder(100000);

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
      .neq('user_id', callerId);
  final calleeIds = (participantRows as List)
      .map((r) => r['user_id'] as String)
      .toSet()
      .toList();
  if (calleeIds.isEmpty) return null;

  final callerProfile = await SupaFlow.client
      .from('profiles')
      .select('full_name, avatar_url')
      .eq('id', callerId)
      .single();

  final callResponse = await SupaFlow.client
      .from('calls')
      .insert({
        'conversation_id': conversationId,
        'caller_id': callerId,
        'callee_id': isGroup ? null : calleeIds.first,
        'is_group': isGroup,
        'caller_name': callerProfile['full_name'],
        'caller_avatar': callerProfile['avatar_url'],
        'call_type': callType,
        'status': 'ringing',
        'started_at': nowIso,
      })
      .select()
      .single();

  final callId = callResponse['id'] as String;

  await SupaFlow.client.from('call_participants').insert({
    'call_id': callId,
    'user_id': callerId,
    'joined_at': nowIso,
    'agora_uid': agoraUid,
    'status': 'joined',
  });

  // Ring everyone (one person for a direct chat, all members for a group).
  final rings = calleeIds
      .map((id) => {
            'user_id': id,
            'call_id': callId,
            'conversation_id': conversationId,
            'caller_id': callerId,
            'caller_name': callerProfile['full_name'],
            'caller_avatar': callerProfile['avatar_url'],
            'call_type': callType,
            'status': 'ringing',
            'agora_channel_name': channelName,
            'updated_at': nowIso,
          })
      .toList();
  await SupaFlow.client.from('active_incoming_calls').upsert(rings);

  final tokenResponse = await SupaFlow.client.functions.invoke(
    'agora-token',
    body: {'channelName': channelName, 'uid': agoraUid},
  );
  final tokenData = tokenResponse.data as Map<String, dynamic>;
  final agoraToken = tokenData['token'] as String;

  return CallStartResultStruct(
    callId: callId,
    agoraToken: agoraToken,
    agoraChannelName: channelName,
    agoraUid: agoraUid,
  );
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
