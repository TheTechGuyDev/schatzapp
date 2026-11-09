import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'set_p_i_n_widget.dart' show SetPINWidget;
import 'package:flutter/material.dart';

class SetPINModel extends FlutterFlowModel<SetPINWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for FirstPinCode widget.
  TextEditingController? firstPinCode;
  FocusNode? firstPinCodeFocusNode;
  String? Function(BuildContext, String?)? firstPinCodeValidator;

  @override
  void initState(BuildContext context) {
    firstPinCode = TextEditingController();
  }

  @override
  void dispose() {
    firstPinCodeFocusNode?.dispose();
    firstPinCode?.dispose();
  }
}
