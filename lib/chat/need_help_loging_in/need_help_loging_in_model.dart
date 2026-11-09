import '/flutter_flow/flutter_flow_util.dart';
import 'need_help_loging_in_widget.dart' show NeedHelpLogingInWidget;
import 'package:flutter/material.dart';

class NeedHelpLogingInModel extends FlutterFlowModel<NeedHelpLogingInWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
