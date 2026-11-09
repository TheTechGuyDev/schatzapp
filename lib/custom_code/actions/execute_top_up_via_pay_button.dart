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

Future<void> executeTopUpViaPayButton(
  BuildContext context,
  double amountSchatz,
) async {
  if (amountSchatz <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enter an amount to top up')),
    );
    return;
  }

  final result = await creditWalletTopup(amountSchatz);
  final decoded = jsonDecode(result) as Map<String, dynamic>;

  if (decoded['success'] == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wallet topped up successfully')),
    );
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text((decoded['message'] ?? 'Top up failed').toString())),
    );
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
