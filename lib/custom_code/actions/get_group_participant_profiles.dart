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

Future<List<ProfilesRow>> getGroupParticipantProfiles(
    String conversationId) async {
  final participantRows = await SupaFlow.client
      .from('conversation_participants')
      .select('user_id')
      .eq('conversation_id', conversationId);

  final userIds = participantRows
      .map((row) => row['user_id'] as String?)
      .whereType<String>()
      .toSet()
      .toList();

  if (userIds.isEmpty) return [];

  return await ProfilesTable().queryRows(
    queryFn: (q) => q.inFilter('id', userIds),
  );
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
