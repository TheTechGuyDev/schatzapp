import '/flutter_flow/flutter_flow_util.dart';
import 'username_changing_page_widget.dart' show UsernameChangingPageWidget;
import 'package:flutter/material.dart';

class UsernameChangingPageModel
    extends FlutterFlowModel<UsernameChangingPageWidget> {
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
