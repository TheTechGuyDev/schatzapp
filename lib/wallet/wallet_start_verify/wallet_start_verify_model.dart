import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'wallet_start_verify_widget.dart' show WalletStartVerifyWidget;
import 'package:flutter/material.dart';

class WalletStartVerifyModel extends FlutterFlowModel<WalletStartVerifyWidget> {
  ///  Local state fields for this page.

  String kycStatus = ' ';

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in wallet_Start_Verify widget.
  List<WalletsRow>? walletsqueryResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
