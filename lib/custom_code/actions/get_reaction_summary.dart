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

/// Counts each reaction type on a status post and flags the viewer's picks.
/// Old 'thumbs' rows count as 'laugh'. Each user counts once per type, so a
/// user with both a 'thumbs' and a 'laugh' row adds 1 to laugh, not 2.
Future<ReactionSummaryStructStruct> getReactionSummary(
  String statusId,
  String viewerId,
) async {
  final rows = await SupaFlow.client
      .from('status_reactions')
      .select('user_id, reaction_type')
      .eq('status_id', statusId);

  final usersByType = <String, Set<String>>{
    'favorite': <String>{},
    'peace': <String>{},
    'laugh': <String>{},
    'sad': <String>{},
    'angry': <String>{},
  };

  for (final row in rows) {
    var type = row['reaction_type'] as String?;
    final userId = row['user_id'] as String?;
    if (type == null || userId == null) continue;
    if (type == 'thumbs') type = 'laugh';
    usersByType[type]?.add(userId);
  }

  int count(String t) => usersByType[t]!.length;
  bool active(String t) => usersByType[t]!.contains(viewerId);

  return ReactionSummaryStructStruct(
    favoriteCount: count('favorite'),
    peaceCount: count('peace'),
    laughCount: count('laugh'),
    sadCount: count('sad'),
    angryCount: count('angry'),
    favoriteActive: active('favorite'),
    peaceActive: active('peace'),
    laughActive: active('laugh'),
    sadActive: active('sad'),
    angryActive: active('angry'),
  );
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
