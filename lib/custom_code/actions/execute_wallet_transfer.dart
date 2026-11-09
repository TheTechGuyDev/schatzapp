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

Future<String> executeWalletTransfer(
  String senderUserId,
  String recipientUserId,
  String recipientCurrency,
  double sfzAmount,
  String note,
  String idempotencyKey,
  String recipientHandle,
) async {
  try {
    if (senderUserId == recipientUserId) {
      return jsonEncode(
          {'success': false, 'message': 'You cannot send money to yourself'});
    }

    if (sfzAmount <= 0) {
      return jsonEncode({'success': false, 'message': 'Enter a valid amount'});
    }

    final senderWallet = await SupaFlow.client
        .from('wallets')
        .select()
        .eq('user_id', senderUserId)
        .maybeSingle();
    if (senderWallet == null) {
      return jsonEncode(
          {'success': false, 'message': 'Sender wallet not found'});
    }

    final senderCurrency = (senderWallet['currency'] ?? 'NGN').toString();
    final eurAmount = sfzAmount / 100;

    final senderRateEurToLocal = await callFxRate('EUR', senderCurrency);
    final recipientRateEurToLocal = await callFxRate('EUR', recipientCurrency);

    final senderLocalDelta = eurAmount * senderRateEurToLocal;
    final recipientLocalDelta = eurAmount * recipientRateEurToLocal;

    final result = await SupaFlow.client.rpc('transfer_schatz', params: {
      'p_sender_id': senderUserId,
      'p_recipient_id': recipientUserId,
      'p_sfz_amount': sfzAmount,
      'p_note': note,
      'p_sender_local_delta': senderLocalDelta,
      'p_recipient_local_delta': recipientLocalDelta,
      'p_idempotency_key': idempotencyKey,
    });

    // Remember how the recipient was found (account number or @username) so
    // the receipt can show it later. Never blocks or fails the transfer.
    try {
      if (recipientHandle.trim().isNotEmpty && result is Map) {
        final ref = (result['reference'] ?? '').toString();
        if (result['success'] == true && ref.isNotEmpty) {
          await SupaFlow.client.rpc('set_transfer_recipient_handle', params: {
            'p_reference': ref,
            'p_handle': recipientHandle.trim(),
          });
        }
      }
    } catch (_) {}

    return jsonEncode(result);
  } catch (e) {
    return jsonEncode({'success': false, 'message': e.toString()});
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
