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

Future<ReactionSummaryStructStruct> getReactionSummary(
  String statusId,
  String viewerId,
) async {
  final rows = await SupaFlow.client
      .from('status_reactions')
      .select('user_id, reaction_type')
      .eq('status_id', statusId);

  int favoriteCount = 0;
  int peaceCount = 0;
  int thumbsCount = 0;

  bool favoriteActive = false;
  bool peaceActive = false;
  bool thumbsActive = false;

  for (final row in rows) {
    final type = row['reaction_type'] as String?;
    final userId = row['user_id'] as String?;

    if (type == null || userId == null) {
      continue;
    }

    switch (type) {
      case 'favorite':
        favoriteCount++;
        if (userId == viewerId) {
          favoriteActive = true;
        }
        break;

      case 'peace':
        peaceCount++;
        if (userId == viewerId) {
          peaceActive = true;
        }
        break;

      case 'thumbs':
        thumbsCount++;
        if (userId == viewerId) {
          thumbsActive = true;
        }
        break;
    }
  }

  return ReactionSummaryStructStruct(
    favoriteCount: favoriteCount,
    peaceCount: peaceCount,
    thumbsCount: thumbsCount,
    favoriteActive: favoriteActive,
    peaceActive: peaceActive,
    thumbsActive: thumbsActive,
  );
}
