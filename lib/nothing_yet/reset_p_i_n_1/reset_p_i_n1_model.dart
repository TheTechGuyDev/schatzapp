import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'reset_p_i_n1_widget.dart' show ResetPIN1Widget;
import 'package:flutter/material.dart';

class ResetPIN1Model extends FlutterFlowModel<ResetPIN1Widget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for EnterEmailTextField widget.
  FocusNode? enterEmailTextFieldFocusNode;
  TextEditingController? enterEmailTextFieldTextController;
  String? Function(BuildContext, String?)?
      enterEmailTextFieldTextControllerValidator;
  // State field(s) for EnterPhoneTextField widget.
  FocusNode? enterPhoneTextFieldFocusNode;
  TextEditingController? enterPhoneTextFieldTextController;
  String? Function(BuildContext, String?)?
      enterPhoneTextFieldTextControllerValidator;
  // Stores action output result for [Custom Action - validateResetIdentity] action in Container widget.
  bool? resetValidationResult;
  // Stores action output result for [Custom Action - checkOtpRateLimit] action in Container widget.
  bool? rateLimitResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    enterEmailTextFieldFocusNode?.dispose();
    enterEmailTextFieldTextController?.dispose();

    enterPhoneTextFieldFocusNode?.dispose();
    enterPhoneTextFieldTextController?.dispose();
  }
}
