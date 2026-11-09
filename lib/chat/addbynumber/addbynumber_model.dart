import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'addbynumber_widget.dart' show AddbynumberWidget;
import 'package:flutter/material.dart';

class AddbynumberModel extends FlutterFlowModel<AddbynumberWidget> {
  ///  Local state fields for this page.

  String previewAvatar = ' ';

  String previewName = ' ';

  bool previewFound = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // Stores action output result for [Custom Action - lookupContactPreview] action in TextField widget.
  SavedContactResultStructStruct? previewResult2;
  // Stores action output result for [Custom Action - saveContactByNumber] action in Button widget.
  SavedContactResultStructStruct? saveContactByNumber;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();
  }
}
