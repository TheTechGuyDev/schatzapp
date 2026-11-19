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

// mode: 'get' reads the setting, 'on' / 'off' change it.
// Always returns the setting as it is afterwards.
Future<bool> saveToGallerySetting(
  String conversationId,
  String mode,
) async {
  try {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null || conversationId.isEmpty) return true;
    if (mode == 'on' || mode == 'off') {
      await SupaFlow.client.rpc('set_save_to_gallery', params: {
        'p_conversation_id': conversationId,
        'p_value': mode == 'on',
      });
    }
    final rows = await SupaFlow.client
        .from('conversation_participants')
        .select('save_to_gallery')
        .eq('conversation_id', conversationId)
        .eq('user_id', uid)
        .limit(1);
    final list = rows as List;
    if (list.isEmpty) return true;
    return list.first['save_to_gallery'] != false;
  } catch (_) {
    return true;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
