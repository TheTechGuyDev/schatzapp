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

Future<String> detectReloadlyDataOperator(
  String phoneNumber,
  String countryCode,
) async {
  final airtimeRaw = await detectReloadlyOperator(phoneNumber, countryCode);
  final airtimeDecoded = jsonDecode(airtimeRaw);

  if (airtimeDecoded is! Map || airtimeDecoded['success'] != true) {
    return jsonEncode({
      'success': false,
      'message': 'Could not detect carrier for this number',
    });
  }

  final carrierName = (airtimeDecoded['operatorName'] as String? ?? '');
  final baseName = carrierName
      .replaceAll(RegExp(r'\s*Airtime\s*', caseSensitive: false), '')
      .trim()
      .toLowerCase();

  final listRaw = await callReloadly(
    'topups',
    '/operators/countries/$countryCode?dataOnly=true',
    'GET',
    '',
  );
  final listDecoded = jsonDecode(listRaw);

  if (listDecoded is Map && listDecoded.containsKey('error')) {
    return jsonEncode({
      'success': false,
      'message': listDecoded['message'] ?? 'Failed to fetch data operators',
    });
  }

  if (listDecoded is! List) {
    return jsonEncode({
      'success': false,
      'message': 'No data operators found for this country',
    });
  }

  Map<String, dynamic>? match;
  for (final op in listDecoded) {
    if (op is Map) {
      final name = (op['name'] as String? ?? '').toLowerCase();
      if (baseName.isNotEmpty && name.contains(baseName)) {
        match = op.cast<String, dynamic>();
        break;
      }
    }
  }

  if (match == null) {
    return jsonEncode({
      'success': false,
      'message': 'No matching data plans found for $carrierName',
    });
  }

  final denominationType = match['denominationType'];
  List<dynamic> amounts = [];
  Map<String, dynamic> descriptions = {};
  if (denominationType == 'FIXED') {
    amounts = (match['localFixedAmounts'] ?? match['fixedAmounts'] ?? [])
        as List<dynamic>;
    final rawDescriptions = (match['localFixedAmountsDescriptions'] ??
        match['fixedAmountsDescriptions'] ??
        {});
    if (rawDescriptions is Map) {
      descriptions = rawDescriptions.cast<String, dynamic>();
    }
  }

  return jsonEncode({
    'success': true,
    'operatorId': match['id'],
    'operatorName': match['name'],
    'logoUrl':
        match['logoUrls'] is List && (match['logoUrls'] as List).isNotEmpty
            ? match['logoUrls'][0]
            : null,
    'denominationType': denominationType,
    'amounts': jsonEncode(amounts),
    'descriptions': jsonEncode(descriptions),
    'minAmount': match['localMinAmount'] ?? match['minAmount'],
    'maxAmount': match['localMaxAmount'] ?? match['maxAmount'],
    'currency': match['destinationCurrencyCode'],
  });
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
