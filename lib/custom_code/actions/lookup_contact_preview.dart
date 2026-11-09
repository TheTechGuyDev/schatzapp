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

Future<SavedContactResultStructStruct> lookupContactPreview(
  String ownerId,
  String query,
  String mode,
) async {
  SavedContactResultStructStruct none() => SavedContactResultStructStruct(
        success: false,
        errorMessage: '',
        savedName: '',
        phoneOrUsername: query,
        contactUserId: '',
        matchedAvatarUrl: '',
        matchedFullName: '',
      );

  try {
    List<dynamic> rows = [];
    if (mode == 'username') {
      final u = query.trim().replaceFirst(RegExp(r'^@'), '').toLowerCase();
      if (u.length < 2) return none();
      // Searching by username needs a username and wallet on both sides.
      final me = await SupaFlow.client
          .from('profiles')
          .select('username')
          .eq('id', ownerId)
          .limit(1);
      final myName =
          me.isEmpty ? '' : ((me.first['username'] as String?) ?? '').trim();
      final myWallet = await SupaFlow.client
          .from('wallets')
          .select('user_id')
          .eq('user_id', ownerId)
          .limit(1);
      if (myName.isEmpty || myWallet.isEmpty) return none();
      rows = await SupaFlow.client
          .from('profiles')
          .select('id, full_name, avatar_url')
          .ilike('username', u)
          .limit(1);
      if (rows.isNotEmpty) {
        final w = await SupaFlow.client
            .from('wallets')
            .select('user_id')
            .eq('user_id', (rows.first as Map<String, dynamic>)['id'])
            .limit(1);
        if (w.isEmpty) return none();
      }
    } else {
      var key = query.replaceAll(RegExp(r'[^0-9]'), '');
      if (key.length > 10) key = key.substring(key.length - 10);
      if (key.length < 10) return none();
      rows = await SupaFlow.client
          .from('profiles')
          .select('id, full_name, avatar_url')
          .ilike('phone_number', '%$key')
          .limit(1);
    }
    if (rows.isEmpty) return none();
    final m = rows.first as Map<String, dynamic>;
    final id = (m['id'] as String?) ?? '';
    if (id == ownerId) return none();
    return SavedContactResultStructStruct(
      success: true,
      errorMessage: '',
      savedName: '',
      phoneOrUsername: query,
      contactUserId: id,
      matchedAvatarUrl: (m['avatar_url'] as String?) ?? '',
      matchedFullName: (m['full_name'] as String?) ?? '',
    );
  } catch (e) {
    return none();
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
