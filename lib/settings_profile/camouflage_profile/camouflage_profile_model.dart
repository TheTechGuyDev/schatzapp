import '/flutter_flow/flutter_flow_util.dart';
import 'camouflage_profile_widget.dart' show CamouflageProfileWidget;
import 'package:flutter/material.dart';

class CamouflageProfileModel extends FlutterFlowModel<CamouflageProfileWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // State field(s) for Checkbox widget.
  bool? checkboxValue;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
