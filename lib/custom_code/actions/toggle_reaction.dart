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

/// Shown when the user tries to remove a reaction older than 3 seconds.
const String kReactionLockedMessage =
    "Reactions can't be changed after 3 seconds";

/// A reaction can only be removed within this window (a DB trigger enforces
/// the same rule).
const Duration kReactionEditWindow = Duration(seconds: 3);

/// Thrown when removing/changing a reaction after [kReactionEditWindow].
class ReactionLockedException implements Exception {
  const ReactionLockedException();
  @override
  String toString() => kReactionLockedMessage;
}

bool _isLockedError(PostgrestException e) {
  final m = e.message.toLowerCase();
  return m.contains('after 3 seconds') || m.contains("can't be changed");
}

bool _isLimitError(PostgrestException e) =>
    e.message.toLowerCase().contains('up to 2 reactions');

/// Toggles one reaction for the signed-in user on a status post.
///
/// - Already picked: removes it, but only within 3 seconds of adding it;
///   after that it throws [ReactionLockedException] and nothing changes.
///   Removing 'laugh' also removes old 'thumbs'.
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
      .select('reaction_type, created_at')
      .eq('status_id', statusId)
      .eq('user_id', liveUserId);

  final myTypes = <String>{};
  DateTime? oldestMatch;
  for (final row in mine) {
    final raw = row['reaction_type'] as String?;
    if (raw == null) continue;
    final t = raw == 'thumbs' ? 'laugh' : raw;
    myTypes.add(t);
    if (t == type) {
      final at = DateTime.tryParse('${row['created_at'] ?? ''}');
      if (at != null && (oldestMatch == null || at.isBefore(oldestMatch))) {
        oldestMatch = at;
      }
    }
  }

  if (myTypes.contains(type)) {
    // Locked after 3 seconds: don't even try the delete.
    final age = oldestMatch == null
        ? null
        : DateTime.now().toUtc().difference(oldestMatch.toUtc());
    if (oldestMatch == null || age! > kReactionEditWindow) {
      throw const ReactionLockedException();
    }
    try {
      await SupaFlow.client
          .from('status_reactions')
          .delete()
          .eq('status_id', statusId)
          .eq('user_id', liveUserId)
          .inFilter('reaction_type', matchTypes);
    } on PostgrestException catch (e) {
      if (e.code == 'P0001' || _isLockedError(e)) {
        throw const ReactionLockedException();
      }
      rethrow;
    }
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
    if (_isLockedError(e)) throw const ReactionLockedException();
    if (e.code == 'P0001' || _isLimitError(e)) {
      throw const ReactionLimitException();
    }
    rethrow;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
