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

Future<void> postImageStories(
  String userId,
  List<String> paths,
  String caption,
  List<String> taggedUserIds,
) async {
  if (paths.isEmpty) return;

  final uploadedUrls = await uploadStagedAssets(paths);
  final storySettings = await getOrCreateStorySettings(userId);

  for (final url in uploadedUrls) {
    await postStory(userId, url, 'image', caption, '', taggedUserIds, 0,
        storySettings.durationHours ?? 24, '');
  }

  final refreshed = await getMyStories(userId);
  FFAppState().myStoryGroup = refreshed;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
