import '/flutter_flow/flutter_flow_util.dart';
import 'edit_image_widget.dart' show EditImageWidget;
import 'package:flutter/material.dart';

class EditImageModel extends FlutterFlowModel<EditImageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextFieldMessageMood widget.
  FocusNode? textFieldMessageMoodFocusNode;
  TextEditingController? textFieldMessageMoodTextController;
  String? Function(BuildContext, String?)?
      textFieldMessageMoodTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldMessageMoodFocusNode?.dispose();
    textFieldMessageMoodTextController?.dispose();
  }
}
