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
import 'dart:io';

Future<String?> uploadVoiceNote(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) return null;

  final bytes = await file.readAsBytes();
  final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
  final path = 'voice_notes/$fileName';

  await SupaFlow.client.storage.from('voice-notes').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(
          upsert: true,
          contentType: 'audio/mp4',
        ),
      );

  return SupaFlow.client.storage.from('voice-notes').getPublicUrl(path);
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
