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

Future<bool> changeGroupAvatar(String conversationId) async {
  try {
    final url = await pickAndUploadGroupAvatar();
    if (url == null || url.isEmpty) return false;
    final r = await SupaFlow.client.rpc('set_group_avatar',
        params: {'p_conversation': conversationId, 'p_url': url});
    return r == 'OK';
  } catch (_) {
    return false;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
