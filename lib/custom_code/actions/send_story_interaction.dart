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

/// Sends a story reply/reaction to the story owner as a chat message.
///
/// If the content is exactly one of the For You reaction emoji
/// (❤️ 😂 ✌️ 😢 😠), the same reaction is also saved on the post, so it
/// shows as picked in For You. This only ever ADDS a reaction (never
/// removes one), and is skipped if the user already has 2 reactions.
Future<void> sendStoryInteraction(
  String currentUserId,
  String otherUserId,
  String statusId,
  String? statusMediaUrl,
  String? statusMediaType,
  String content,
) async {
  final conversationId =
      await findOrCreateConversation(currentUserId, otherUserId);

  await SupaFlow.client.from('messages').insert({
    'conversation_id': conversationId,
    'sender_id': currentUserId,
    'message_type': 'text',
    'content': content,
    'reply_to_status_id': statusId,
    'reply_to_status_media_url': statusMediaUrl,
    'reply_to_status_media_type': statusMediaType,
  });

  await _syncForYouReaction(statusId, content);
}

/// Emoji (with or without the variation selector) to reaction type.
const Map<String, String> _emojiToReaction = {
  '❤️': 'favorite',
  '❤': 'favorite',
  '✌️': 'peace',
  '✌': 'peace',
  '😂': 'laugh',
  '😢': 'sad',
  '😠': 'angry',
};

Future<void> _syncForYouReaction(String statusId, String content) async {
  final type = _emojiToReaction[content.trim()];
  final uid = SupaFlow.client.auth.currentUser?.id;
  if (type == null || uid == null || statusId.isEmpty) return;

  try {
    final rows = await SupaFlow.client
        .from('status_reactions')
        .select('reaction_type')
        .eq('status_id', statusId)
        .eq('user_id', uid);

    final mine = <String>{};
    for (final r in rows) {
      final t = r['reaction_type'] as String?;
      if (t != null) mine.add(t == 'thumbs' ? 'laugh' : t);
    }

    // Already picked, or already at the 2-reaction limit: nothing to do.
    if (mine.contains(type) || mine.length >= 2) return;

    await SupaFlow.client.from('status_reactions').insert({
      'status_id': statusId,
      'user_id': uid,
      'reaction_type': type,
    });
  } catch (_) {
    // The chat message was sent; a failed reaction sync is not an error
    // for the user (e.g. the database 2-reaction limit).
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
