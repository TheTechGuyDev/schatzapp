import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'listcall_widget.dart' show ListcallWidget;
import 'package:flutter/material.dart';

class ListcallModel extends FlutterFlowModel<ListcallWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Custom Action - startCall] action in Icon widget.
  CallStartResultStruct? listcallVoiceCallResult;
  // Stores action output result for [Custom Action - startCall] action in Icon widget.
  CallStartResultStruct? listcallVideoCallResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
