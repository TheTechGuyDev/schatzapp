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
import 'package:image_picker/image_picker.dart';

Future<PendingWebImageStruct?> pickWebChatVideo() async {
  final picker = ImagePicker();
  final XFile? picked = await picker.pickVideo(source: ImageSource.gallery);
  if (picked == null) return null;

  final Uint8List bytes = await picked.readAsBytes();
  return PendingWebImageStruct(
    base64Data: base64Encode(bytes),
    mediaType: 'video',
  );
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
