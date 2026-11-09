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

Future<String> detectReloadlyOperator(
  String phoneNumber,
  String countryCode,
) async {
  final path =
      '/operators/auto-detect/phone/$phoneNumber/countries/$countryCode?httpErrorCodeOnInvalidPhone=true';

  final raw = await callReloadly('topups', path, 'GET', '');
  final decoded = jsonDecode(raw);

  if (decoded is Map && decoded.containsKey('error')) {
    return jsonEncode({
      'success': false,
      'message': decoded['message'] ?? decoded['error'],
    });
  }

  if (decoded is! Map || decoded['id'] == null) {
    return jsonEncode({
      'success': false,
      'message': 'Operator not found for this number',
    });
  }

  final denominationType = decoded['denominationType'];
  List<dynamic> amounts = [];
  if (denominationType == 'FIXED') {
    amounts = (decoded['localFixedAmounts'] ?? decoded['fixedAmounts'] ?? [])
        as List<dynamic>;
  }

  return jsonEncode({
    'success': true,
    'operatorId': decoded['id'],
    'operatorName': decoded['name'],
    'logoUrl':
        decoded['logoUrls'] is List && (decoded['logoUrls'] as List).isNotEmpty
            ? decoded['logoUrls'][0]
            : null,
    'denominationType': denominationType,
    'amounts': amounts,
    'minAmount': decoded['localMinAmount'] ?? decoded['minAmount'],
    'maxAmount': decoded['localMaxAmount'] ?? decoded['maxAmount'],
    'currency': decoded['destinationCurrencyCode'],
  });
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
