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

import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

const _imageExt = ['jpg', 'jpeg', 'png', 'webp', 'gif', 'heic', 'heif', 'bmp'];
const _videoExt = ['mp4', 'mov', 'webm', 'm4v', 'avi', 'mkv'];

/// Opens the file explorer.
///
/// Photos and videos are staged as before; every other file is staged as a
/// document. A document's mediaType is "document:<file name>" so the file
/// name travels with it.
Future<List<PendingWebImageStruct>> pickMultipleWebChatMedia() async {
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    withData: true,
    type: FileType.any,
  );
  if (result == null || result.files.isEmpty) return [];

  final List<PendingWebImageStruct> results = [];
  for (final file in result.files) {
    final Uint8List? bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) continue;

    final name = file.name;
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';

    String type;
    if (_imageExt.contains(ext)) {
      type = 'image';
    } else if (_videoExt.contains(ext)) {
      type = 'video';
    } else {
      type = 'document:$name';
    }

    results.add(PendingWebImageStruct(
      base64Data: base64Encode(bytes),
      mediaType: type,
    ));
  }
  return results;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
