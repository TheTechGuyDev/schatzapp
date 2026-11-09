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
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<String?> pickAndUploadGroupAvatar() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile == null) return null;

  final rawBytes = await pickedFile.readAsBytes();

  final compressedBytes = await FlutterImageCompress.compressWithList(
    rawBytes,
    minWidth: 500,
    minHeight: 500,
    quality: 80,
    format: CompressFormat.jpeg,
  );

  final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
  final path = 'avatars/$fileName';

  await SupaFlow.client.storage.from('group-avatars').uploadBinary(
        path,
        compressedBytes,
        fileOptions: const FileOptions(upsert: true),
      );

  return SupaFlow.client.storage.from('group-avatars').getPublicUrl(path);
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
