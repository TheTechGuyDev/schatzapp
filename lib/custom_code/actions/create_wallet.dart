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

Future<bool> createWallet(
  String userId,
  String fullName,
  String email,
  String dialCode,
  String isoCode,
  String localPhone,
) async {
  try {
    final dialDigits = dialCode.replaceAll(RegExp(r'[^0-9]'), '');
    var digitsOnly = localPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (dialDigits.isNotEmpty && digitsOnly.startsWith(dialDigits)) {
      digitsOnly = digitsOnly.substring(dialDigits.length);
    }
    final currency = currencyForCountryCode(isoCode);
    await SupaFlow.client.from('profiles').update({
      'full_name': fullName,
    }).eq('id', userId);
    await SupaFlow.client.from('wallets').insert({
      'user_id': userId,
      'wallet_phone_number': digitsOnly,
      'wallet_country_code': isoCode,
      'email': email,
      'currency': currency,
      'balance': 0,
      'schatz_balance': 0,
      'kyc_status': 'not_started',
      'wallet_status': 'active',
    });
    return true;
  } catch (e) {
    print('createWallet failed: $e');
    return false;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
