import '/flutter_flow/flutter_flow_util.dart';
import 'app_password_gate_widget.dart' show AppPasswordGateWidget;
import 'package:flutter/material.dart';

class AppPasswordGateModel extends FlutterFlowModel<AppPasswordGateWidget> {
  ///  Local state fields for this component.

  String passwordInput = ' ';

  ///  State fields for stateful widgets in this component.

  // State field(s) for Enterapppassword widget.
  late FocusNode enterapppasswordPasswordVisibilityFocusNode;
  FocusNode? enterapppasswordFocusNode;
  TextEditingController? enterapppasswordTextController;
  late bool enterapppasswordVisibility;
  String? Function(BuildContext, String?)?
      enterapppasswordTextControllerValidator;
  // Stores action output result for [Custom Action - verifyAppPassword] action in Button widget.
  bool? appPasswordVerified;

  @override
  void initState(BuildContext context) {
    enterapppasswordPasswordVisibilityFocusNode = FocusNode();
    enterapppasswordVisibility = false;
  }

  @override
  void dispose() {
    enterapppasswordFocusNode?.dispose();
    enterapppasswordTextController?.dispose();
    enterapppasswordPasswordVisibilityFocusNode.dispose();
  }
}
