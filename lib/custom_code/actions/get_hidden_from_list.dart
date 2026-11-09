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

Future<List<HiddenPersonStruct>> getHiddenFromList(String ownerId) async {
  final rows = await SupaFlow.client
      .from('status_hidden_from')
      .select(
          'hidden_user_id, profiles!status_hidden_from_hidden_user_id_fkey(full_name, avatar_url)')
      .eq('owner_id', ownerId);

  return rows
      .where((row) => row['profiles'] != null)
      .map((row) => HiddenPersonStruct(
            id: row['hidden_user_id'] as String,
            fullName: (row['profiles']['full_name'] as String?) ?? '',
            avatarUrl: (row['profiles']['avatar_url'] as String?) ?? '',
          ))
      .toList();
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
