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

Future<bool> isMyPrivateLock(String conversationId) async {
  try {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null || conversationId.isEmpty) return false;
    final rows = await SupaFlow.client
        .from('conversation_participants')
        .select('private_lock')
        .eq('conversation_id', conversationId)
        .eq('user_id', uid)
        .isFilter('left_at', null)
        .limit(1);
    final list = rows as List;
    return list.isNotEmpty && list.first['private_lock'] == true;
  } catch (_) {
    return false;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
