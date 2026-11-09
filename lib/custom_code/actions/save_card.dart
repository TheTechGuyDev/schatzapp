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

Future<String> saveCard(
  String cardNumber,
  String firstName,
  String lastName,
  String street,
  String city,
  String state,
  String postcode,
  String country,
) async {
  try {
    final digitsOnly = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 4) {
      return jsonEncode(
          {'success': false, 'message': 'Enter a valid card number'});
    }
    final lastFour = digitsOnly.substring(digitsOnly.length - 4);

    String brand;
    if (digitsOnly.startsWith('4')) {
      brand = 'Visa';
    } else if (RegExp(r'^5[1-5]').hasMatch(digitsOnly) ||
        RegExp(r'^2(2[2-9][1-9]|2[3-9]\d|[3-6]\d\d|7[0-1]\d|720)')
            .hasMatch(digitsOnly)) {
      brand = 'Mastercard';
    } else {
      brand = 'Verve';
    }

    final result = await SupaFlow.client.rpc('add_saved_card', params: {
      'p_card_last_four': lastFour,
      'p_card_brand': brand,
      'p_billing_first_name': firstName,
      'p_billing_last_name': lastName,
      'p_billing_address': street,
      'p_billing_city': city,
      'p_billing_state': state,
      'p_billing_postcode': postcode,
      'p_billing_country': country,
    });

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
