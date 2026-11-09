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

Future<SavedContactResultStructStruct> saveContactByNumber(
  String ownerId,
  String savedName,
  String phoneNumber,
) async {
  SavedContactResultStructStruct fail(String msg) =>
      SavedContactResultStructStruct(
        success: false,
        errorMessage: msg,
        savedName: savedName,
        phoneOrUsername: phoneNumber,
        contactUserId: '',
        matchedAvatarUrl: '',
        matchedFullName: '',
      );

  // Compare numbers by their last 10 digits so 080..., +23480... and
  // 23480... all count as the same number.
  var key = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
  if (key.length > 10) key = key.substring(key.length - 10);
  if (key.length < 7) return fail('Enter a valid phone number');

  try {
    final matchRows = await SupaFlow.client
        .from('profiles')
        .select('id, full_name, avatar_url, phone_number')
        .ilike('phone_number', '%$key')
        .limit(1);

    String? matchedUserId;
    String matchedFullName = '';
    String matchedAvatarUrl = '';
    if (matchRows.isNotEmpty) {
      final match = matchRows.first;
      matchedUserId = match['id'] as String?;
      matchedFullName = (match['full_name'] as String?) ?? '';
      matchedAvatarUrl = (match['avatar_url'] as String?) ?? '';
      if (matchedUserId == ownerId) {
        return fail("You can't add yourself as a contact");
      }
    }

    // Already saved? Look by user id first, then by number.
    Map<String, dynamic>? existing;
    if (matchedUserId != null) {
      final byUser = await SupaFlow.client
          .from('contacts')
          .select('id, saved_name, contact_user_id')
          .eq('owner_id', ownerId)
          .eq('contact_user_id', matchedUserId)
          .limit(1);
      if (byUser.isNotEmpty) existing = byUser.first;
    }
    if (existing == null) {
      final byPhone = await SupaFlow.client
          .from('contacts')
          .select('id, saved_name, contact_user_id')
          .eq('owner_id', ownerId)
          .ilike('phone_number', '%$key')
          .limit(1);
      if (byPhone.isNotEmpty) existing = byPhone.first;
    }

    String finalName = savedName;
    if (existing != null) {
      final old = ((existing['saved_name'] as String?) ?? '').trim();
      if (old.isNotEmpty) finalName = old;
      // Link the saved number to the user if it was not linked yet.
      if (existing['contact_user_id'] == null && matchedUserId != null) {
        await SupaFlow.client.from('contacts').update(
            {'contact_user_id': matchedUserId}).eq('id', existing['id']);
      }
    } else {
      await SupaFlow.client.from('contacts').insert({
        'owner_id': ownerId,
        'contact_user_id': matchedUserId,
        'saved_name': savedName,
        'phone_number': phoneNumber,
      });
    }

    return SavedContactResultStructStruct(
      success: true,
      errorMessage: '',
      savedName: finalName,
      phoneOrUsername: phoneNumber,
      contactUserId: matchedUserId ?? '',
      matchedAvatarUrl: matchedAvatarUrl,
      matchedFullName: matchedFullName,
    );
  } catch (e) {
    debugPrint('saveContactByNumber failed: $e');
    return fail('Something went wrong. Please try again.');
  }
}
