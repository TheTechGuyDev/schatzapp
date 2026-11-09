import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'wallet_verify_fail_widget.dart' show WalletVerifyFailWidget;
import 'package:flutter/material.dart';

class WalletVerifyFailModel extends FlutterFlowModel<WalletVerifyFailWidget> {
  ///  Local state fields for this page.

  bool hasProofOfAddressIssue = false;

  bool hasIdReuploadIssue = false;

  bool hasAgeMismatchIssue = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in wallet_Verify_fail widget.
  List<KycSubmissionsRow>? walletVerifyFailResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
