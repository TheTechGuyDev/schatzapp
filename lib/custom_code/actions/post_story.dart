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

Future<String> postStory(
  String userId,
  String mediaUrl,
  String mediaType,
  String caption,
  String backgroundColor,
  List<String> taggedUserIds,
  int fontIndex,
  int durationHours,
  String batchId,
) async {
  final now = DateTime.now().toUtc();
  final hours = durationHours > 0 ? durationHours : 24;
  final response = await SupaFlow.client
      .from('statuses')
      .insert({
        'user_id': userId,
        'media_url': mediaUrl.isEmpty ? null : mediaUrl,
        'media_type': mediaType,
        'caption': caption.isEmpty ? null : caption,
        'background_color': backgroundColor.isEmpty ? null : backgroundColor,
        'text_font_index': fontIndex,
        'created_at': now.toIso8601String(),
        'expires_at': now.add(Duration(hours: hours)).toIso8601String(),
        if (batchId.isNotEmpty) 'batch_id': batchId,
      })
      .select()
      .single();

  final statusId = response['id'] as String;

  if (taggedUserIds.isNotEmpty) {
    await SupaFlow.client.from('status_tags').insert(
          taggedUserIds
              .map((id) => {
                    'status_id': statusId,
                    'tagged_user_id': id,
                  })
              .toList(),
        );
  }

  return statusId;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
