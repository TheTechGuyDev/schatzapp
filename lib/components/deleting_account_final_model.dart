import '/flutter_flow/flutter_flow_util.dart';
import 'deleting_account_final_widget.dart' show DeletingAccountFinalWidget;
import 'package:flutter/material.dart';

class DeletingAccountFinalModel
    extends FlutterFlowModel<DeletingAccountFinalWidget> {
  ///  State fields for stateful widgets in this component.

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
