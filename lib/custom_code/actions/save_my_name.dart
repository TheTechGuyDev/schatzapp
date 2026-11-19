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

Future<String> saveMyName(String newName) async {
  final uid = SupaFlow.client.auth.currentUser?.id;
  if (uid == null) return 'Please sign in again';
  final name = newName.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (name.isEmpty) return 'Name cannot be empty';
  if (name.length > 50) return 'Name can be up to 50 characters';
  try {
    await SupaFlow.client
        .from('profiles')
        .update({'full_name': name}).eq('id', uid);
    return 'OK';
  } catch (_) {
    return 'Could not save your name. Try again.';
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
