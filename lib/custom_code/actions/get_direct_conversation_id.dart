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

Future<String> getDirectConversationId(
  String currentUserId,
  String otherUserId,
) async {
  try {
    final myRows = await SupaFlow.client
        .from('conversation_participants')
        .select('conversation_id')
        .eq('user_id', currentUserId);
    final myIds = myRows.map((r) => r['conversation_id'] as String).toList();
    if (myIds.isEmpty) return '';

    final theirRows = await SupaFlow.client
        .from('conversation_participants')
        .select('conversation_id')
        .eq('user_id', otherUserId)
        .inFilter('conversation_id', myIds);
    final sharedIds =
        theirRows.map((r) => r['conversation_id'] as String).toList();
    if (sharedIds.isEmpty) return '';

    final direct = await SupaFlow.client
        .from('conversations')
        .select('id')
        .eq('type', 'direct')
        .inFilter('id', sharedIds)
        .limit(1);
    if (direct.isEmpty) return '';
    return direct.first['id'] as String;
  } catch (_) {
    return '';
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
