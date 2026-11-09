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

Future<String> getGroupMemberSummary(String conversationId) async {
  final rows = await SupaFlow.client
      .from('conversation_participants_directory')
      .select('full_name')
      .eq('conversation_id', conversationId);

  final names =
      rows.map((r) => (r['full_name'] as String?) ?? 'Unknown').toList();

  if (names.isEmpty) return '';

  if (names.length <= 3) {
    return names.join(', ');
  }

  final shown = names.take(3).join(', ');
  final remaining = names.length - 3;
  return '$shown +$remaining more';
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
