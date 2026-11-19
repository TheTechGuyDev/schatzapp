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

Future<bool> isGroupAdmin(String conversationId) async {
  final uid = SupaFlow.client.auth.currentUser?.id;
  if (uid == null || conversationId.isEmpty) return false;
  try {
    final rows = await SupaFlow.client
        .from('conversation_participants')
        .select('role')
        .eq('conversation_id', conversationId)
        .eq('user_id', uid)
        .limit(1);
    if ((rows as List).isEmpty) return false;
    return rows.first['role'] == 'admin';
  } catch (_) {
    return false;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
