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
  String? dialCode,
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

  // Build the full number: country code + national number (no leading 0).
  // With no country code we fall back to the last 10 digits, as before.
  final dial = (dialCode ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  var digits = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
  String key;
  String national;
  if (dial.isEmpty) {
    key = digits.length > 10 ? digits.substring(digits.length - 10) : digits;
    national = key;
  } else {
    if (phoneNumber.trim().startsWith('+') && digits.startsWith(dial)) {
      digits = digits.substring(dial.length);
    }
    national = digits.replaceFirst(RegExp(r'^0+'), '');
    key = dial + national;
  }
  if (national.length < 7) return fail('Enter a valid phone number');
  final tail =
      national.length > 9 ? national.substring(national.length - 9) : national;

  bool matches(String stored) {
    final cd = stored.replaceAll(RegExp(r'[^0-9]'), '');
    if (cd.endsWith(key)) return true;
    return dial == '234' &&
        national.length >= 10 &&
        cd.endsWith(national.substring(national.length - 10));
  }

  try {
    String? matchedUserId;
    String matchedFullName = '';
    String matchedAvatarUrl = '';

    final cand = await SupaFlow.client
        .from('profiles')
        .select('id, full_name, avatar_url, phone_number')
        .ilike('phone_number', '%$tail')
        .limit(25);
    for (final r in (cand as List)) {
      if (matches(((r['phone_number'] ?? '') as String))) {
        matchedUserId = r['id'] as String?;
        matchedFullName = (r['full_name'] as String?) ?? '';
        matchedAvatarUrl = (r['avatar_url'] as String?) ?? '';
        break;
      }
    }
    if (matchedUserId != null && matchedUserId == ownerId) {
      return fail("You can't add yourself as a contact");
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
      if (byUser.isNotEmpty) existing = Map<String, dynamic>.from(byUser.first);
    }
    if (existing == null) {
      final byPhone = await SupaFlow.client
          .from('contacts')
          .select('id, saved_name, contact_user_id, phone_number')
          .eq('owner_id', ownerId)
          .ilike('phone_number', '%$tail')
          .limit(25);
      for (final r in (byPhone as List)) {
        if (matches(((r['phone_number'] ?? '') as String))) {
          existing = Map<String, dynamic>.from(r as Map);
          break;
        }
      }
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
        'phone_number': dial.isEmpty ? phoneNumber : '+$key',
      });
      // Tell them about it so they can accept and add you back.
      if (matchedUserId != null) {
        try {
          await SupaFlow.client
              .rpc('send_friend_request', params: {'p_target': matchedUserId});
        } catch (_) {}
      }
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
