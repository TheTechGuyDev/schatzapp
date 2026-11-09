import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'reset_p_i_n2_widget.dart' show ResetPIN2Widget;
import 'package:flutter/material.dart';

class ResetPIN2Model extends FlutterFlowModel<ResetPIN2Widget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for PinCode widget.
  TextEditingController? pinCodeController;
  FocusNode? pinCodeFocusNode;
  String? Function(BuildContext, String?)? pinCodeControllerValidator;
  // Stores action output result for [Custom Action - checkWalletOtp] action in PinCode widget.
  bool? otpCheckResult;
  // Stores action output result for [Custom Action - getKycStatus] action in PinCode widget.
  String? kycStatusResult;
  // Stores action output result for [Custom Action - generateResetToken] action in PinCode widget.
  String? resetTokenResult;

  @override
  void initState(BuildContext context) {
    pinCodeController = TextEditingController();
  }

  @override
  void dispose() {
    pinCodeFocusNode?.dispose();
    pinCodeController?.dispose();
  }
}
