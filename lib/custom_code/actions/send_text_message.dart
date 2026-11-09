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

import '/custom_code/actions/init_offline_store.dart';

Future<bool> sendTextMessage(
  String conversationId,
  String senderId,
  String content,
  String? replyToMessageId,
  String? replyToContent,
  bool? replyToIsOwn,
) async {
  final text = content.trim();
  if (text.isEmpty) return false;

  final message = <String, dynamic>{
    'conversation_id': conversationId,
    'sender_id': senderId,
    'message_type': 'text',
    'content': content,
  };
  if (replyToMessageId != null && replyToMessageId.isNotEmpty) {
    message['reply_to_message_id'] = replyToMessageId;
    message['reply_to_content'] = replyToContent ?? '';
    message['reply_to_is_own'] = replyToIsOwn ?? false;
  }

  return OutboxSync.sendOrQueue(message);
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
