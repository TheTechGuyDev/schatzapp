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

Future<String> getResolvedDisplayName(
  String currentUserId,
  String otherUserId,
) async {
  String clean(String name) {
    final cleaned = name.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }

  try {
    final contactRows = await SupaFlow.client
        .from('contacts')
        .select('saved_name')
        .eq('owner_id', currentUserId)
        .eq('contact_user_id', otherUserId)
        .limit(1);
    if (contactRows.isNotEmpty) {
      final saved = (contactRows.first['saved_name'] as String?) ?? '';
      if (clean(saved).isNotEmpty) return clean(saved);
    }

    final profileRows = await SupaFlow.client
        .from('profiles')
        .select('full_name, username')
        .eq('id', otherUserId)
        .limit(1);
    if (profileRows.isNotEmpty) {
      final uname = (profileRows.first['username'] as String?) ?? '';
      if (clean(uname).isNotEmpty) return clean(uname);
      final full = (profileRows.first['full_name'] as String?) ?? '';
      if (clean(full).isNotEmpty) return clean(full);
    }
  } catch (_) {}
  return 'Unknown';
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
