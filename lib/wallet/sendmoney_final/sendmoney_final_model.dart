import '/flutter_flow/flutter_flow_util.dart';
import 'sendmoney_final_widget.dart' show SendmoneyFinalWidget;
import 'package:flutter/material.dart';

class SendmoneyFinalModel extends FlutterFlowModel<SendmoneyFinalWidget> {
  ///  Local state fields for this component.

  bool isProcessing = false;

  String transferIdempotencyKey = ' ';

  bool pinVerifiedResult = false;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - generateUuid] action in sendmoney_final widget.
  String? uuidResult;
  // Stores action output result for [Custom Action - executeWalletTransfer] action in Row widget.
  String? transferResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
