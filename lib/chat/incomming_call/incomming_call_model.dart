import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'incomming_call_widget.dart' show IncommingCallWidget;
import 'package:flutter/material.dart';

class IncommingCallModel extends FlutterFlowModel<IncommingCallWidget> {
  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - declineCall] action in IconButton widget.
  String? declineResult;
  // Stores action output result for [Custom Action - acceptCall] action in IconButton widget.
  AcceptCallResultStruct? acceptResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
