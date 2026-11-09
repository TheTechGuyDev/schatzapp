import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'change_app_passowrd_widget.dart' show ChangeAppPassowrdWidget;
import 'package:flutter/material.dart';

class ChangeAppPassowrdModel extends FlutterFlowModel<ChangeAppPassowrdWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  late FocusNode textFieldPasswordVisibilityFocusNode;
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Custom Action - verifyAppPassword] action in Button widget.
  bool? oldPasswordVerified;

  @override
  void initState(BuildContext context) {
    textFieldPasswordVisibilityFocusNode = FocusNode();
    passwordVisibility = false;
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
    textFieldPasswordVisibilityFocusNode.dispose();
  }
}
