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

Future<void> shareStoryToContact(
  String currentUserId,
  String contactId,
  String storyMediaUrl,
  String storyMediaType,
) async {
  final conversationId =
      await findOrCreateConversation(currentUserId, contactId);

  final messageType = storyMediaType == 'video' ? 'video' : 'image';

  await SupaFlow.client.from('messages').insert({
    'conversation_id': conversationId,
    'sender_id': currentUserId,
    'message_type': messageType,
    'media_url': storyMediaUrl,
    'content': 'Shared a status',
  });
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
