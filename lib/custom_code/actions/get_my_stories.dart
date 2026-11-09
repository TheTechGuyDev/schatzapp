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

Future<StoryGroupStruct> getMyStories(String currentUserId) async {
  final nowIso = DateTime.now().toUtc().toIso8601String();

  final statusRows = await SupaFlow.client
      .from('statuses')
      .select()
      .eq('user_id', currentUserId)
      .gt('expires_at', nowIso)
      .order('created_at', ascending: true);

  final profileRow = await SupaFlow.client
      .from('profiles')
      .select('full_name, avatar_url')
      .eq('id', currentUserId)
      .maybeSingle();

  // Batch-fetch view counts for every status at once, instead of one
  // query per item.
  final statusIds = statusRows.map((row) => row['id'] as String).toList();
  final Map<String, int> viewCounts = {};
  if (statusIds.isNotEmpty) {
    final viewRows = await SupaFlow.client
        .from('status_views')
        .select('status_id')
        .inFilter('status_id', statusIds);
    for (final row in viewRows) {
      final id = row['status_id'] as String;
      viewCounts[id] = (viewCounts[id] ?? 0) + 1;
    }
  }

  final items = statusRows
      .map((row) => StoryItemStruct(
            id: row['id'] as String,
            mediaUrl: (row['media_url'] as String?) ?? '',
            mediaType: (row['media_type'] as String?) ?? 'image',
            caption: (row['caption'] as String?) ?? '',
            backgroundColor: (row['background_color'] as String?) ?? '',
            createdAt: row['created_at'] != null
                ? DateTime.parse(row['created_at'] as String)
                : null,
            viewCount: viewCounts[row['id'] as String] ?? 0,
            fontIndex: (row['text_font_index'] as int?) ?? 0,
          ))
      .toList();

  return StoryGroupStruct(
    userId: currentUserId,
    fullName: (profileRow?['full_name'] as String?) ?? '',
    avatarUrl: (profileRow?['avatar_url'] as String?) ?? '',
    hasUnviewed: false,
    items: items,
  );
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
