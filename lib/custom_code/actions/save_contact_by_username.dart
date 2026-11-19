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

Future<SavedContactResultStructStruct> saveContactByUsername(
  String ownerId,
  String savedName,
  String username,
) async {
  SavedContactResultStructStruct fail(String msg, String shown) =>
      SavedContactResultStructStruct(
        success: false,
        errorMessage: msg,
        savedName: savedName,
        phoneOrUsername: shown,
        contactUserId: '',
        matchedAvatarUrl: '',
        matchedFullName: '',
      );

  final cleanUsername =
      username.trim().replaceFirst(RegExp(r'^@+'), '').toLowerCase();
  if (cleanUsername.isEmpty) return fail('Enter a username', username);

  try {
    // Escape % and _ so a username is matched exactly, not as a pattern.
    final pattern =
        cleanUsername.replaceAllMapped(RegExp(r'[\\%_]'), (m) => '\\${m[0]}');

    final matchRows = await SupaFlow.client
        .from('profiles')
        .select('id, full_name, avatar_url')
        .ilike('username', pattern)
        .limit(1);

    if (matchRows.isEmpty) {
      return fail('No user found with that username', cleanUsername);
    }

    final match = matchRows.first;
    final matchedUserId = match['id'] as String;
    if (matchedUserId == ownerId) {
      return fail("You can't add yourself as a contact", cleanUsername);
    }

    final matchedFullName = (match['full_name'] as String?) ?? '';
    final matchedAvatarUrl = (match['avatar_url'] as String?) ?? '';

    // Already a contact? Keep the name the user saved before.
    final existing = await SupaFlow.client
        .from('contacts')
        .select('id, saved_name')
        .eq('owner_id', ownerId)
        .eq('contact_user_id', matchedUserId)
        .limit(1);

    String finalName = savedName;
    if (existing.isNotEmpty) {
      final old = ((existing.first['saved_name'] as String?) ?? '').trim();
      if (old.isNotEmpty) finalName = old;
    } else {
      // Username adds never copy the phone number.
      await SupaFlow.client.from('contacts').insert({
        'owner_id': ownerId,
        'contact_user_id': matchedUserId,
        'saved_name': savedName,
        'phone_number': null,
      });
      // Tell them about it so they can accept and add you back.
      try {
        await SupaFlow.client
            .rpc('send_friend_request', params: {'p_target': matchedUserId});
      } catch (_) {}
    }

    return SavedContactResultStructStruct(
      success: true,
      errorMessage: '',
      savedName: finalName,
      phoneOrUsername: cleanUsername,
      contactUserId: matchedUserId,
      matchedAvatarUrl: matchedAvatarUrl,
      matchedFullName: matchedFullName,
    );
  } catch (e) {
    debugPrint('saveContactByUsername failed: $e');
    return fail('Something went wrong. Please try again.', username);
  }
}
