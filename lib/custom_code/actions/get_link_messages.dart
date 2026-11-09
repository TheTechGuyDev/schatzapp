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

Future<List<MessagesRow>> getLinkMessages(String conversationId) async {
  final rows = await MessagesTable().queryRows(
    queryFn: (q) => q
        .eq('conversation_id', conversationId)
        .eq('message_type', 'text')
        .not('is_deleted', 'eq', true)
        .order('created_at', ascending: false),
  );

  final urlPattern = RegExp(
    r'((https?:\/\/)|(www\.))[^\s]+',
    caseSensitive: false,
  );

  return rows.where((row) {
    final content = row.content;
    return content != null && urlPattern.hasMatch(content);
  }).toList();
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
