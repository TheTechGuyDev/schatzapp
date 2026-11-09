import '/flutter_flow/flutter_flow_util.dart';
import 'help_support_p_widget.dart' show HelpSupportPWidget;
import 'package:flutter/material.dart';

class HelpSupportPModel extends FlutterFlowModel<HelpSupportPWidget> {
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
