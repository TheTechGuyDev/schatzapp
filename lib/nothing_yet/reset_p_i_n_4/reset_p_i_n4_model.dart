import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'reset_p_i_n4_widget.dart' show ResetPIN4Widget;
import 'package:flutter/material.dart';

class ResetPIN4Model extends FlutterFlowModel<ResetPIN4Widget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for PinCode1 widget.
  TextEditingController? pinCode1;
  FocusNode? pinCode1FocusNode;
  String? Function(BuildContext, String?)? pinCode1Validator;
  // State field(s) for PinCode2 widget.
  TextEditingController? pinCode2;
  FocusNode? pinCode2FocusNode;
  String? Function(BuildContext, String?)? pinCode2Validator;
  // Stores action output result for [Custom Action - resetWalletPin] action in Container widget.
  bool? resetPinResult;

  @override
  void initState(BuildContext context) {
    pinCode1 = TextEditingController();
    pinCode2 = TextEditingController();
  }

  @override
  void dispose() {
    pinCode1FocusNode?.dispose();
    pinCode1?.dispose();

    pinCode2FocusNode?.dispose();
    pinCode2?.dispose();
  }
}
