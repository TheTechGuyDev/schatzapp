import '/flutter_flow/flutter_flow_util.dart';
import 'set_app_password_widget.dart' show SetAppPasswordWidget;
import 'package:flutter/material.dart';

class SetAppPasswordModel extends FlutterFlowModel<SetAppPasswordWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  late FocusNode textFieldPasswordVisibilityFocusNode1;
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  late bool passwordVisibility1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  late FocusNode textFieldPasswordVisibilityFocusNode2;
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  late bool passwordVisibility2;
  String? Function(BuildContext, String?)? textController2Validator;
  // Stores action output result for [Custom Action - setAppPassword] action in Button widget.
  String? setPasswordResult;

  @override
  void initState(BuildContext context) {
    textFieldPasswordVisibilityFocusNode1 = FocusNode();
    passwordVisibility1 = false;
    textFieldPasswordVisibilityFocusNode2 = FocusNode();
    passwordVisibility2 = false;
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();
    textFieldPasswordVisibilityFocusNode1.dispose();
    textFieldFocusNode2?.dispose();
    textController2?.dispose();
    textFieldPasswordVisibilityFocusNode2.dispose();
  }
}
