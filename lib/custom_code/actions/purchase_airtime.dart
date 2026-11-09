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

Future<String> purchaseAirtime(
  String currentUserId,
  String operatorId,
  double amount,
  String recipientPhone,
  String recipientCountryCode,
  String senderPhone,
  String operatorCurrency,
  String idempotencyKey,
) async {
  const double minNgnAirtime = 100;
  if (amount.isNaN || amount <= 0) {
    return jsonEncode({'success': false, 'message': 'Enter an amount'});
  }
  if (operatorCurrency.toUpperCase() == 'NGN' && amount < minNgnAirtime) {
    return jsonEncode({
      'success': false,
      'message': 'Minimum airtime purchase is ₦100',
    });
  }

  try {
    final walletRow = await SupaFlow.client
        .from('wallets')
        .select('currency')
        .eq('user_id', currentUserId)
        .maybeSingle();

    if (walletRow == null) {
      return jsonEncode({'success': false, 'message': 'Wallet not found'});
    }

    final walletCurrency = (walletRow['currency'] ?? 'NGN').toString();

    final rateToEur = await callFxRate(operatorCurrency, 'EUR');
    if (rateToEur <= 0) {
      return jsonEncode({
        'success': false,
        'message': 'Could not determine exchange rate for $operatorCurrency',
      });
    }
    final eurAmount = amount * rateToEur;
    final schatzAmount = eurAmount * 100;

    final rateEurToWalletCurrency = await callFxRate('EUR', walletCurrency);
    final localDelta = eurAmount * rateEurToWalletCurrency;

    // Save the brand name and logo with the transaction so history can show it.
    final brandRaw = await getBrandInfo('operator', operatorId);
    final brand = jsonDecode(brandRaw);
    final brandName = brand is Map ? brand['name'] : null;
    final brandLogo = brand is Map ? brand['logoUrl'] : null;

    final debitResult =
        await SupaFlow.client.rpc('debit_wallet_for_purchase', params: {
      'p_type': 'airtime',
      'p_schatz_amount': schatzAmount,
      'p_amount': amount,
      'p_currency': operatorCurrency,
      'p_local_delta': localDelta,
      'p_metadata': {
        'operatorName': brandName,
        'logoUrl': brandLogo,
        'operatorId': operatorId,
        'recipientPhone': recipientPhone,
        'eurAmount': eurAmount,
        'schatzAmount': schatzAmount,
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
      'topups',
      '/topups',
      'POST',
      jsonEncode({
        'operatorId': int.parse(operatorId),
        'amount': amount,
        'useLocalAmount': true,
        'customIdentifier': reference,
        'recipientPhone': {
          'countryCode': recipientCountryCode,
          'number': recipientPhone,
        },
        'senderPhone': {
          'countryCode': recipientCountryCode,
          'number': senderPhone,
        },
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
