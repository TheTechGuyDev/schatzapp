import '/flutter_flow/flutter_flow_util.dart';
import 'email_verify_component_widget.dart' show EmailVerifyComponentWidget;
import 'package:flutter/material.dart';

class EmailVerifyComponentModel
    extends FlutterFlowModel<EmailVerifyComponentWidget> {
  ///  Local state fields for this component.

  int secondsLeft = 45;

  ///  State fields for stateful widgets in this component.

  // State field(s) for VerifyPinCode widget.
  TextEditingController? verifyPinCode;
  FocusNode? verifyPinCodeFocusNode;
  String? Function(BuildContext, String?)? verifyPinCodeValidator;
  // Stores action output result for [Custom Action - checkWalletOtp] action in Container widget.
  bool? emailOtpResult;

  @override
  void initState(BuildContext context) {
    verifyPinCode = TextEditingController();
  }

  @override
  void dispose() {
    verifyPinCodeFocusNode?.dispose();
    verifyPinCode?.dispose();
  }
}
