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

Future<void> deleteSelectedConversations(
  List<String> conversationIds,
  String currentUserId,
) async {
  if (conversationIds.isEmpty) return;

  // Remove this person's important (starred) messages of these chats first,
  // so a deleted chat leaves nothing behind on the Important page.
  try {
    final msgs = await SupaFlow.client
        .from('messages')
        .select('id')
        .inFilter('conversation_id', conversationIds);
    final ids = msgs.map((r) => r['id'].toString()).toList();
    for (var i = 0; i < ids.length; i += 200) {
      final chunk = ids.sublist(i, i + 200 > ids.length ? ids.length : i + 200);
      await SupaFlow.client
          .from('message_stars')
          .delete()
          .eq('user_id', currentUserId)
          .inFilter('message_id', chunk);
    }
  } catch (_) {}

  await SupaFlow.client.rpc(
    'delete_conversations_for_user',
    params: {
      'p_conversation_ids': conversationIds,
      'p_user_id': currentUserId,
    },
  );
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
