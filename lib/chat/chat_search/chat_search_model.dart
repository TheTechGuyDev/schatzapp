import '/flutter_flow/flutter_flow_util.dart';
import 'chat_search_widget.dart' show ChatSearchWidget;
import 'package:flutter/material.dart';

class ChatSearchModel extends FlutterFlowModel<ChatSearchWidget> {
  ///  Local state fields for this page.

  bool isSelectionMode = false;

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
