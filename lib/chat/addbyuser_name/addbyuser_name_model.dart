import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'addbyuser_name_widget.dart' show AddbyuserNameWidget;
import 'package:flutter/material.dart';

class AddbyuserNameModel extends FlutterFlowModel<AddbyuserNameWidget> {
  ///  Local state fields for this page.

  String previewAvatar = ' ';

  String previewName = ' ';

  bool previewFound = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Custom Action - lookupContactPreview] action in TextField widget.
  SavedContactResultStructStruct? previewResult;
  // Stores action output result for [Custom Action - saveContactByUsername] action in Button widget.
  SavedContactResultStructStruct? saveContactByUsername;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
