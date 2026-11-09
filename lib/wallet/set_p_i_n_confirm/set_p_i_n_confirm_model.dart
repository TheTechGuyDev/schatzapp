import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'set_p_i_n_confirm_widget.dart' show SetPINConfirmWidget;
import 'package:flutter/material.dart';

class SetPINConfirmModel extends FlutterFlowModel<SetPINConfirmWidget> {
  ///  Local state fields for this page.

  bool showMismatchError = false;

  bool showSaveError = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for PinCode widget.
  TextEditingController? pinCodeController;
  FocusNode? pinCodeFocusNode;
  String? Function(BuildContext, String?)? pinCodeControllerValidator;
  // Stores action output result for [Custom Action - setWalletPin] action in PinCode widget.
  bool? setPinResult;

  @override
  void initState(BuildContext context) {
    pinCodeController = TextEditingController();
  }

  @override
  void dispose() {
    pinCodeFocusNode?.dispose();
    pinCodeController?.dispose();
  }
}
