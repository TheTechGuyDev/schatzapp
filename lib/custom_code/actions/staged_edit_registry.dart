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

import 'dart:typed_data';

/// Placeholder action body - never called directly. It only exists so
/// FlutterFlow has a declaration matching this action's name; the real
/// logic other custom code actually uses is the map and helper functions
/// below, exported via this same file.
Future<void> stagedEditRegistry() async {}

/// In-memory registry mapping a staged-media identifier (file path or
/// photo_manager asset id) to the edited bytes that should be sent instead
/// of the original, once the user edits it from the composer's batch
/// editor. Lives only for the lifetime of the app - never persisted, and
/// always cleared right after a successful send.
final Map<String, Uint8List> stagedEditsByIdentifier = {};

void setStagedEdit(String identifier, Uint8List bytes) {
  stagedEditsByIdentifier[identifier] = bytes;
}

Uint8List? getStagedEdit(String identifier) =>
    stagedEditsByIdentifier[identifier];

void clearStagedEdit(String identifier) {
  stagedEditsByIdentifier.remove(identifier);
}

void clearAllStagedEdits() {
  stagedEditsByIdentifier.clear();
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
