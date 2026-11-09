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

Future<PrivacySettingsRow> getOrCreatePrivacySettings(
  String currentUserId,
) async {
  final existing = await PrivacySettingsTable().queryRows(
    queryFn: (q) => q.eqOrNull('user_id', currentUserId),
  );
  if (existing.isNotEmpty) return existing.first;

  return PrivacySettingsTable().insert({
    'user_id': currentUserId,
    'last_seen_visibility': 'everyone',
    'profile_photo_visibility': 'everyone',
    'about_visibility': 'everyone',
    'status_visibility': 'everyone',
    'read_receipts_enabled': true,
  });
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
