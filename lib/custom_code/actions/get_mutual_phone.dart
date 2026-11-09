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

Future<String> getMutualPhone(
  String currentUserId,
  String otherUserId,
) async {
  // The phone number is shown only when BOTH people have saved each
  // other's number. Otherwise only the username is visible.
  try {
    final mine = await SupaFlow.client
        .from('contacts')
        .select('phone_number')
        .eq('owner_id', currentUserId)
        .eq('contact_user_id', otherUserId)
        .limit(1);
    final iSavedThem = mine.isNotEmpty &&
        ((mine.first['phone_number'] as String?) ?? '').trim().isNotEmpty;
    if (!iSavedThem) return '';

    final theirs = await SupaFlow.client
        .from('contacts')
        .select('phone_number')
        .eq('owner_id', otherUserId)
        .eq('contact_user_id', currentUserId)
        .limit(1);
    final theySavedMe = theirs.isNotEmpty &&
        ((theirs.first['phone_number'] as String?) ?? '').trim().isNotEmpty;
    if (!theySavedMe) return '';

    final prof = await SupaFlow.client
        .from('profiles')
        .select('phone_number')
        .eq('id', otherUserId)
        .limit(1);
    if (prof.isEmpty) return '';
    final p = ((prof.first['phone_number'] as String?) ?? '').trim();
    if (p.isEmpty) return '';
    return p.startsWith('+') ? p : '+$p';
  } catch (_) {
    return '';
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
