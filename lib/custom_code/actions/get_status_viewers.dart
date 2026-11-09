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

Future<List<StatusViewerStruct>> getStatusViewers(String statusId) async {
  final rows = await SupaFlow.client
      .from('status_views')
      .select('viewer_id, viewed_at, profiles(full_name, avatar_url)')
      .eq('status_id', statusId)
      .order('viewed_at', ascending: false);

  return rows.map((row) {
    final profile = row['profiles'] as Map<String, dynamic>?;
    return StatusViewerStruct(
      viewerId: row['viewer_id'] as String,
      fullName: (profile?['full_name'] as String?) ?? '',
      avatarUrl: (profile?['avatar_url'] as String?) ?? '',
      viewedAt: row['viewed_at'] != null
          ? DateTime.parse(row['viewed_at'] as String)
          : null,
    );
  }).toList();
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
