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

Future<String> fetchGiftCardProducts(String countryCode) async {
  final raw = await callReloadly(
    'giftcards',
    '/countries/$countryCode/products',
    'GET',
    '',
  );
  final decoded = jsonDecode(raw);

  if (decoded is Map && decoded.containsKey('error')) {
    return jsonEncode({
      'success': false,
      'message': decoded['message'] ?? 'Failed to fetch gift cards',
    });
  }

  if (decoded is! List) {
    return jsonEncode({
      'success': false,
      'message': 'No gift cards found for this country',
    });
  }

  final products = decoded
      .map((p) {
        if (p is! Map) return null;
        final fixedAmounts = p['fixedRecipientDenominations'];
        return {
          'productId': p['productId'],
          'productName': p['productName'],
          'brandName':
              (p['brand'] is Map) ? p['brand']['brandName'] : p['productName'],
          'logoUrl': p['logoUrls'] is List && (p['logoUrls'] as List).isNotEmpty
              ? p['logoUrls'][0]
              : null,
          'currencyCode': p['recipientCurrencyCode'],
          'denominationType': p['denominationType'],
          'fixedAmounts': fixedAmounts is List ? fixedAmounts : [],
          'minAmount': p['minRecipientDenomination'],
          'maxAmount': p['maxRecipientDenomination'],
          'redeemInstruction': (p['redeemInstruction'] is Map)
              ? p['redeemInstruction']['concise']
              : null,
        };
      })
      .whereType<Map>()
      .toList();

  return jsonEncode({
    'success': true,
    'products': products,
  });
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
