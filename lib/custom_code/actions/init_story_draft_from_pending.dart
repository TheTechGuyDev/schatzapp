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

import 'dart:io';
import 'dart:convert';

Future<void> initStoryDraftFromPending() async {
  final List<String> originals = [];
  final List<String> mediaTypes = [];

  final nativePaths = FFAppState().pendingStoryImagePaths;
  for (final path in nativePaths) {
    try {
      final file = File(path);
      if (!await file.exists()) continue;
      final bytes = await file.readAsBytes();
      originals.add(base64Encode(bytes));

      final lower = path.toLowerCase();
      final isVideo = lower.endsWith('.mp4') ||
          lower.endsWith('.mov') ||
          lower.endsWith('.webm') ||
          lower.endsWith('.m4v');
      mediaTypes.add(isVideo ? 'video' : 'image');
    } catch (_) {
      continue;
    }
  }

  final webImages = FFAppState().pendingWebStoryImages;
  for (final img in webImages) {
    if (img.base64Data.isEmpty) continue;
    originals.add(img.base64Data);
    mediaTypes.add(img.mediaType.isNotEmpty ? img.mediaType : 'image');
  }

  FFAppState().storyDraftOriginalImages = originals;
  FFAppState().storyDraftEditedImages = List<String>.filled(
    originals.length,
    '',
  );
  FFAppState().storyDraftMediaTypes = mediaTypes;
  FFAppState().storyDraftCaptions = List<String>.filled(
    originals.length,
    '',
  );
  FFAppState().storyDraftCarousel = List<bool>.filled(
    originals.length,
    false,
  );
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
