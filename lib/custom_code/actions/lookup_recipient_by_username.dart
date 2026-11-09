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

import 'dart:convert';

Future<String> lookupRecipientByUsername(
  String username,
  String requesterId,
) async {
  try {
    final result = await SupaFlow.client.rpc(
      'lookup_recipient_by_username',
      params: {'p_username': username},
    );

    if (result == null || (result as List).isEmpty) {
      return jsonEncode(
          {'success': false, 'message': 'No user found with this username'});
    }

    final row = result.first as Map<String, dynamic>;
    final matchedUserId = row['user_id'] as String;
    final registeredName = row['full_name'] as String? ?? '';

    String displayName = registeredName;
    final contactMatch = await SupaFlow.client
        .from('contacts')
        .select('saved_name')
        .eq('owner_id', requesterId)
        .eq('contact_user_id', matchedUserId)
        .limit(1);

    if (contactMatch.isNotEmpty) {
      final savedName = contactMatch.first['saved_name'] as String?;
      if (savedName != null && savedName.trim().isNotEmpty) {
        displayName = savedName;
      }
    }

    return jsonEncode({
      'success': true,
      'userId': matchedUserId,
      'fullName': displayName,
      'registeredName': registeredName,
      'avatarUrl': row['avatar_url'] ?? '',
      'currency': row['currency'] ?? '',
      'username': row['username'] ?? '',
    });
  } catch (e) {
    return jsonEncode({'success': false, 'message': e.toString()});
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
