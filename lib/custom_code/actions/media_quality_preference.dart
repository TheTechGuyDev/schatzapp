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

import 'package:shared_preferences/shared_preferences.dart';

/// Reads or saves the media quality choice on this device.
/// Pass an empty string to read. Pass 'standard', 'hd' or 'original' to save.
/// Always returns the current value. Default is 'hd'.
Future<String> mediaQualityPreference(String newValue) async {
  const key = 'schatz_media_quality';
  try {
    final prefs = await SharedPreferences.getInstance();
    final v = newValue.trim().toLowerCase();
    if (v == 'standard' || v == 'hd' || v == 'original') {
      await prefs.setString(key, v);
      return v;
    }
    final saved = prefs.getString(key);
    if (saved == 'standard' || saved == 'hd' || saved == 'original') {
      return saved!;
    }
  } catch (_) {}
  return 'hd';
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
