import '/flutter_flow/flutter_flow_util.dart';
import 'phone_verify_component_widget.dart' show PhoneVerifyComponentWidget;
import 'package:flutter/material.dart';

class PhoneVerifyComponentModel
    extends FlutterFlowModel<PhoneVerifyComponentWidget> {
  ///  Local state fields for this component.

  int secondsLeft = 45;

  ///  State fields for stateful widgets in this component.

  // State field(s) for PhonePinCode widget.
  TextEditingController? phonePinCode;
  FocusNode? phonePinCodeFocusNode;
  String? Function(BuildContext, String?)? phonePinCodeValidator;
  // Stores action output result for [Custom Action - checkWalletOtp] action in Container widget.
  bool? walletCreateResult;

  @override
  void initState(BuildContext context) {
    phonePinCode = TextEditingController();
  }

  @override
  void dispose() {
    phonePinCodeFocusNode?.dispose();
    phonePinCode?.dispose();
  }
}
