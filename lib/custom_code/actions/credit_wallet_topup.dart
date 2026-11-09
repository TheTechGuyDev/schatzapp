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

Future<String> creditWalletTopup(double amountSchatz) async {
  try {
    final reference = 'TXN-${const Uuid().v4().substring(0, 8).toUpperCase()}';

    final result = await SupaFlow.client.rpc('credit_wallet_topup', params: {
      'p_amount_schatz': amountSchatz,
      'p_reference': reference,
      'p_method': 'bank_transfer',
    });

    if (result is Map) {
      final response = Map<String, dynamic>.from(result);
      response['reference'] = reference;
      return jsonEncode(response);
    }
    return jsonEncode({'success': false, 'message': 'Unexpected response'});
  } catch (e) {
    return jsonEncode({'success': false, 'message': e.toString()});
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
