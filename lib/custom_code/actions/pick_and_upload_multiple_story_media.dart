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

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<StoryUploadResultStruct>> pickAndUploadMultipleStoryMedia(
    String source) async {
  final picker = ImagePicker();
  List<XFile> files = [];

  if (source == 'camera') {
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) files = [file];
  } else {
    files = await picker.pickMultipleMedia();
  }

  if (files.isEmpty) return [];

  final results = <StoryUploadResultStruct>[];

  for (final file in files) {
    final mimeType = file.mimeType ?? '';
    final lowerName = file.name.toLowerCase();
    final isVideo = mimeType.startsWith('video') ||
        lowerName.endsWith('.mp4') ||
        lowerName.endsWith('.mov') ||
        lowerName.endsWith('.m4v');

    final bytes = await file.readAsBytes();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final path = 'status_media/$fileName';

    await SupaFlow.client.storage.from('chat-media').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    final url = SupaFlow.client.storage.from('chat-media').getPublicUrl(path);

    results.add(StoryUploadResultStruct(
      mediaUrl: url,
      mediaType: isVideo ? 'video' : 'image',
    ));
  }

  return results;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
