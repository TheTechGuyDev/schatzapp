import '/flutter_flow/flutter_flow_util.dart';
import 'edit_name_page_widget.dart' show EditNamePageWidget;
import 'package:flutter/material.dart';

class EditNamePageModel extends FlutterFlowModel<EditNamePageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for NewNameTextField widget.
  FocusNode? newNameTextFieldFocusNode;
  TextEditingController? newNameTextFieldTextController;
  String? Function(BuildContext, String?)?
      newNameTextFieldTextControllerValidator;
  // Stores action output result for [Custom Action - saveMyName] action in Container widget.
  String? nameResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController1?.dispose();

    newNameTextFieldFocusNode?.dispose();
    newNameTextFieldTextController?.dispose();
  }
}
