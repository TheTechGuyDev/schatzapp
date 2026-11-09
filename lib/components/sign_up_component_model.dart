import '/flutter_flow/flutter_flow_util.dart';
import 'sign_up_component_widget.dart' show SignUpComponentWidget;
import 'package:flutter/material.dart';

class SignUpComponentModel extends FlutterFlowModel<SignUpComponentWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for EnterFullNameTextField widget.
  FocusNode? enterFullNameTextFieldFocusNode;
  TextEditingController? enterFullNameTextFieldTextController;
  String? Function(BuildContext, String?)?
      enterFullNameTextFieldTextControllerValidator;
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

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    enterFullNameTextFieldFocusNode?.dispose();
    enterFullNameTextFieldTextController?.dispose();

    enterEmailTextFieldFocusNode?.dispose();
    enterEmailTextFieldTextController?.dispose();

    enterPhoneTextFieldFocusNode?.dispose();
    enterPhoneTextFieldTextController?.dispose();
  }
}
