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

Future<String> saveProfileLink(
  String title,
  String url,
) async {
  final t = title.trim();
  var u = url.trim();
  final uid = SupaFlow.client.auth.currentUser?.id;
  if (uid == null) return 'Please sign in again.';
  if (t.isEmpty) return 'Please enter a link title.';
  if (u.isEmpty) return 'Please enter the link.';
  if (!u.toLowerCase().startsWith('http://') &&
      !u.toLowerCase().startsWith('https://')) {
    u = 'https://$u';
  }
  final uri = Uri.tryParse(u);
  if (uri == null || uri.host.isEmpty || !uri.host.contains('.')) {
    return 'That link does not look valid.';
  }
  try {
    final existing =
        await SupaFlow.client.from('links').select('id').eq('user_id', uid);
    if ((existing as List).length >= 3) {
      return 'You can only add up to 3 links.';
    }
    await SupaFlow.client
        .from('links')
        .insert({'user_id': uid, 'title': t, 'url': u});
    return 'ok';
  } catch (e) {
    if (e.toString().contains('LINK_LIMIT')) {
      return 'You can only add up to 3 links.';
    }
    var m = e.toString();
    if (m.length > 140) m = m.substring(0, 140);
    return 'Could not save: $m';
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
