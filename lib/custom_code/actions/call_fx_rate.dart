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

Future<double> callFxRate(String fromCurrency, String toCurrency) async {
  try {
    final response = await SupaFlow.client.functions.invoke(
      'fx-rate?from=$fromCurrency&to=$toCurrency',
      method: HttpMethod.get,
    );

    dynamic data = response.data;
    if (data is String) {
      data = jsonDecode(data);
    }
    if (data is Map && data['success'] == true && data['rate'] != null) {
      final rate = data['rate'];
      if (rate is num) {
        return rate.toDouble();
      }
      return double.tryParse(rate.toString()) ?? 0.0;
    }
    return 0.0;
  } catch (e) {
    return 0.0;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
