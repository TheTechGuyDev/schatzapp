import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'topupwallet_widget.dart' show TopupwalletWidget;
import 'package:flutter/material.dart';

class TopupwalletModel extends FlutterFlowModel<TopupwalletWidget> {
  ///  Local state fields for this page.

  double sfzAmount = 0.0;

  String selectedPaymentMethod = ' ';

  String transferReference = ' ';

  String senderCurrency = ' ';

  double senderFxRate = 0.0;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in Topupwallet widget.
  List<BankTransferSettingsRow>? bankSettings;
  // Stores action output result for [Custom Action - getOwnWalletCurrency] action in Topupwallet widget.
  String? getOwnWalletCurrencyOutput;
  // Stores action output result for [Custom Action - callFxRate] action in Topupwallet widget.
  double? callFxRateOutput;
  // Stores action output result for [Custom Action - creditWalletTopup] action in Container widget.
  String? topupResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
