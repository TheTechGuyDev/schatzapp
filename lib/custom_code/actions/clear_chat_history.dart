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

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> clearChatHistory(
  BuildContext context,
  String conversationId,
  String currentUserId,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Clear this chat?'),
      content: const Text(
        'This deletes all messages in this chat for you only. The other person will still see them.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text(
            'Clear chat',
            style: TextStyle(color: Color(0xFFE05C6E)),
          ),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  try {
    final rows = await SupaFlow.client
        .from('messages')
        .select('id, deleted_for_user_ids')
        .eq('conversation_id', conversationId);

    for (final row in rows) {
      final ids = List<String>.from(row['deleted_for_user_ids'] ?? const []);
      if (ids.contains(currentUserId)) continue;
      ids.add(currentUserId);
      await SupaFlow.client
          .from('messages')
          .update({'deleted_for_user_ids': ids}).eq('id', row['id']);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat cleared')),
      );
    }
  } catch (e) {
    debugPrint('clearChatHistory failed: $e');
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
