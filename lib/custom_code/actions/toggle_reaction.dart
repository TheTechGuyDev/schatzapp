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

/// Reaction types in display order.
const List<String> kReactionTypes = [
  'favorite',
  'peace',
  'laugh',
  'sad',
  'angry',
];

/// Emoji for each reaction type. 'thumbs' is legacy and shows as laugh.
const Map<String, String> kReactionEmoji = {
  'favorite': '❤️',
  'peace': '✌️',
  'laugh': '😂',
  'sad': '😢',
  'angry': '😠',
};

/// Shown when the user already has 2 reactions on a post.
const String kReactionLimitMessage =
    'You can pick up to 2 reactions. Tap one to remove it first.';

/// Thrown when a 3rd reaction is attempted on the same post.
class ReactionLimitException implements Exception {
  const ReactionLimitException();
  @override
  String toString() => kReactionLimitMessage;
}

/// Toggles one reaction for the signed-in user on a status post.
///
/// - Already picked: removes it. Removing 'laugh' also removes old 'thumbs'.
/// - Not picked: adds it, unless the user already has 2 reactions, in which
///   case it throws [ReactionLimitException] and saves nothing.
///   The database also blocks a 3rd insert (P0001); that is converted to
///   [ReactionLimitException] too.
Future<void> toggleReaction(
  String statusId,
  String viewerId,
  String reactionType,
) async {
  final liveUserId = SupaFlow.client.auth.currentUser?.id;

  if (liveUserId == null) {
    throw Exception(
      'No active Supabase session - the user is not actually signed in '
      '(or the session expired). Reaction was not saved.',
    );
  }

  // Old thumbs rows are treated as laugh.
  final type = reactionType == 'thumbs' ? 'laugh' : reactionType;
  final matchTypes = type == 'laugh' ? ['laugh', 'thumbs'] : [type];

  final mine = await SupaFlow.client
      .from('status_reactions')
      .select('reaction_type')
      .eq('status_id', statusId)
      .eq('user_id', liveUserId);

  final myTypes = <String>{};
  for (final row in mine) {
    final t = row['reaction_type'] as String?;
    if (t == null) continue;
    myTypes.add(t == 'thumbs' ? 'laugh' : t);
  }

  if (myTypes.contains(type)) {
    await SupaFlow.client
        .from('status_reactions')
        .delete()
        .eq('status_id', statusId)
        .eq('user_id', liveUserId)
        .inFilter('reaction_type', matchTypes);
    return;
  }

  if (myTypes.length >= 2) {
    throw const ReactionLimitException();
  }

  try {
    await SupaFlow.client.from('status_reactions').insert({
      'status_id': statusId,
      'user_id': liveUserId,
      'reaction_type': type,
    });
  } on PostgrestException catch (e) {
    final isLimit = e.code == 'P0001' ||
        e.message.toLowerCase().contains('up to 2 reactions');
    if (isLimit) throw const ReactionLimitException();
    rethrow;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
