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

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

Future<List<String>> pickAndUploadImages(List<String> existingUrls) async {
  final picker = ImagePicker();
  final pickedFiles = await picker.pickMultiImage();
  if (pickedFiles.isEmpty) {
    return existingUrls;
  }

  final urls = List<String>.from(existingUrls);
  for (final file in pickedFiles) {
    final bytes = await file.readAsBytes();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final path = 'upload_media/$fileName';

    await SupaFlow.client.storage.from('chat-media').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    final publicUrl =
        SupaFlow.client.storage.from('chat-media').getPublicUrl(path);
    urls.add(publicUrl);
  }

  return urls;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
