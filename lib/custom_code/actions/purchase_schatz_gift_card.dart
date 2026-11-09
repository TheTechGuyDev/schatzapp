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
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

Future<String> purchaseSchatzGiftCard(
  double schatzAmount,
  String deliveryMethod,
  String? recipientInput,
  String? recipientUserIdDirect,
) async {
  try {
    final idempotencyKey = const Uuid().v4();

    final result =
        await SupaFlow.client.rpc('purchase_schatz_giftcard', params: {
      'p_schatz_amount': schatzAmount,
      'p_delivery_method': deliveryMethod,
      'p_recipient_input': recipientInput,
      'p_idempotency_key': idempotencyKey,
      'p_recipient_user_id_direct': recipientUserIdDirect,
    });

    if (result is Map && result['success'] == true) {
      final emailTarget = result['recipientEmail'] as String?;

      if (emailTarget != null && emailTarget.trim().isNotEmpty) {
        try {
          const supabaseUrl = 'https://hkcykdxiinvmepxebdsm.supabase.co';
          const anonKey =
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhrY3lrZHhpaW52bWVweGViZHNtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODczMTY0OTgsImV4cCI6MjEwMjg5MjQ5OH0.YSHUDWqOAd5mSuABx9_J4_phV0rdidy-CIBdqqVWJ1U';

          await http.post(
            Uri.parse('$supabaseUrl/functions/v1/send-giftcard-email'),
            headers: {
              'Authorization': 'Bearer $anonKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'recipientEmail': emailTarget,
              'code': result['code'],
              'schatzAmount': schatzAmount,
            }),
          );
        } catch (_) {
          // Email send failing must never undo a successful purchase.
        }
      }

      return jsonEncode(result);
    }

    if (result is Map) {
      return jsonEncode(result);
    }
    return jsonEncode({'success': false, 'message': 'Unexpected response'});
  } catch (e) {
    return jsonEncode({'success': false, 'message': e.toString()});
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
