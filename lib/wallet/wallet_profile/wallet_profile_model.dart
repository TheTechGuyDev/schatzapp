import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'wallet_profile_widget.dart' show WalletProfileWidget;
import 'package:flutter/material.dart';

class WalletProfileModel extends FlutterFlowModel<WalletProfileWidget> {
  ///  Local state fields for this page.

  String kycStatus = ' ';

  String fullName = ' ';

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in wallet_profile widget.
  List<WalletsRow>? walletProfileQueryResult;
  // Stores action output result for [Backend Call - Query Rows] action in wallet_profile widget.
  List<ProfilesRow>? profileQueryResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
