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

Future<String> purchaseGiftCard(
  String currentUserId,
  String productId,
  String countryCode,
  double unitPrice,
  int quantity,
  String productCurrency,
  String recipientEmail,
  String idempotencyKey,
) async {
  try {
    final walletRow = await SupaFlow.client
        .from('wallets')
        .select('currency')
        .eq('user_id', currentUserId)
        .maybeSingle();

    if (walletRow == null) {
      return jsonEncode({'success': false, 'message': 'Wallet not found'});
    }

    final profileRow = await SupaFlow.client
        .from('profiles')
        .select('full_name')
        .eq('id', currentUserId)
        .maybeSingle();

    final senderName = (profileRow?['full_name'] as String?)?.isNotEmpty == true
        ? profileRow!['full_name'] as String
        : 'Schatz User';

    final walletCurrency = (walletRow['currency'] ?? 'NGN').toString();

    final totalPrice = unitPrice * quantity;

    final rateToEur = await callFxRate(productCurrency, 'EUR');
    if (rateToEur <= 0) {
      return jsonEncode({
        'success': false,
        'message': 'Could not determine exchange rate for $productCurrency',
      });
    }
    final eurAmount = totalPrice * rateToEur;
    final schatzAmount = eurAmount * 100;

    double localDelta = eurAmount;
    if (walletCurrency.toUpperCase() != 'EUR') {
      final eurToLocalRate = await callFxRate('EUR', walletCurrency);
      if (eurToLocalRate > 0) {
        localDelta = eurAmount * eurToLocalRate;
      }
    }

    // Save the brand name and logo with the transaction so history can show it.
    final brandRaw = await getBrandInfo('giftcard', productId);
    final brand = jsonDecode(brandRaw);
    final brandName = brand is Map ? brand['name'] : null;
    final brandLogo = brand is Map ? brand['logoUrl'] : null;

    final debitResult =
        await SupaFlow.client.rpc('debit_wallet_for_purchase', params: {
      'p_type': 'giftcard_purchase',
      'p_schatz_amount': schatzAmount,
      'p_amount': totalPrice,
      'p_currency': productCurrency,
      'p_local_delta': localDelta,
      'p_metadata': {
        'productName': brandName,
        'logoUrl': brandLogo,
        'productId': productId,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'eurAmount': eurAmount,
        'schatzAmount': schatzAmount,
        'recipientEmail': recipientEmail,
      },
      'p_idempotency_key': idempotencyKey,
    });

    if (debitResult is! Map || debitResult['success'] != true) {
      return jsonEncode({
        'success': false,
        'message': debitResult is Map
            ? (debitResult['message'] ?? 'Could not debit wallet')
            : 'Could not debit wallet',
      });
    }

    if (debitResult['alreadyProcessed'] == true) {
      if (debitResult['status'] == 'success') {
        return jsonEncode(
            {'success': true, 'transactionId': debitResult['reference']});
      }
      return jsonEncode({
        'success': false,
        'message': 'Purchase already in progress, please wait'
      });
    }

    final reference = debitResult['reference'];
    final newSchatzBalance = debitResult['newSchatzBalance'];
    final newBalance = debitResult['newBalance'];

    final purchaseRes = await callReloadly(
      'giftcards',
      '/orders',
      'POST',
      jsonEncode({
        'productId': int.parse(productId),
        'countryCode': countryCode,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'customIdentifier': reference,
        'senderName': senderName,
        'recipientEmail': recipientEmail,
      }),
    );

    final purchaseData = jsonDecode(purchaseRes);
    final bool reloadlyFailed =
        (purchaseData is Map && purchaseData.containsKey('error')) ||
            purchaseData is! Map ||
            purchaseData['transactionId'] == null;

    if (reloadlyFailed) {
      final failMessage =
          (purchaseData is Map ? purchaseData['message'] : null) ??
              'Purchase failed';
      await SupaFlow.client.rpc('finalize_wallet_purchase', params: {
        'p_reference': reference,
        'p_success': false,
        'p_provider_reference': null,
        'p_message': failMessage,
      });
      return jsonEncode({'success': false, 'message': failMessage});
    }

    await SupaFlow.client.rpc('finalize_wallet_purchase', params: {
      'p_reference': reference,
      'p_success': true,
      'p_provider_reference': purchaseData['transactionId'].toString(),
      'p_message': null,
    });

    return jsonEncode({
      'success': true,
      'transactionId': purchaseData['transactionId'].toString(),
      'newSchatzBalance': newSchatzBalance,
      'newBalance': newBalance,
    });
  } catch (e) {
    return jsonEncode({'success': false, 'message': e.toString()});
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
