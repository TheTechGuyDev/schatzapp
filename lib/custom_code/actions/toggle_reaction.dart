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

Future<void> toggleReaction(
  String statusId,
  String viewerId,
  String reactionType,
) async {
  final liveUserId = SupaFlow.client.auth.currentUser?.id;

  if (liveUserId == null) {
    throw Exception(
      'No active Supabase session - the user is not actually signed in '
      '(or the session expired). Reaction was not saved.',
    );
  }

  final existing = await SupaFlow.client
      .from('status_reactions')
      .select('id')
      .eq('status_id', statusId)
      .eq('user_id', liveUserId)
      .eq('reaction_type', reactionType);

  if (existing.isNotEmpty) {
    await SupaFlow.client
        .from('status_reactions')
        .delete()
        .eq('status_id', statusId)
        .eq('user_id', liveUserId)
        .eq('reaction_type', reactionType);
  } else {
    await SupaFlow.client.from('status_reactions').insert({
      'status_id': statusId,
      'user_id': liveUserId,
      'reaction_type': reactionType,
    });
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
