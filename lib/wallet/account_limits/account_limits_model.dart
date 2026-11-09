import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'account_limits_widget.dart' show AccountLimitsWidget;
import 'package:flutter/material.dart';

class AccountLimitsModel extends FlutterFlowModel<AccountLimitsWidget> {
  ///  Local state fields for this page.

  String kycStatus = ' ';

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in Account_Limits widget.
  List<WalletsRow>? walletQueryResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
