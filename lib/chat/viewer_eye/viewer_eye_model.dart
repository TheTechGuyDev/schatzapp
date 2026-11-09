import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'viewer_eye_widget.dart' show ViewerEyeWidget;
import 'package:flutter/material.dart';

class ViewerEyeModel extends FlutterFlowModel<ViewerEyeWidget> {
  ///  Local state fields for this component.

  List<StatusViewerStruct> statusViewers = [];
  void addToStatusViewers(StatusViewerStruct item) => statusViewers.add(item);
  void removeFromStatusViewers(StatusViewerStruct item) =>
      statusViewers.remove(item);
  void removeAtIndexFromStatusViewers(int index) =>
      statusViewers.removeAt(index);
  void insertAtIndexInStatusViewers(int index, StatusViewerStruct item) =>
      statusViewers.insert(index, item);
  void updateStatusViewersAtIndex(
          int index, Function(StatusViewerStruct) updateFn) =>
      statusViewers[index] = updateFn(statusViewers[index]);

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - getStatusViewers] action in viewer_eye widget.
  List<StatusViewerStruct>? viewerListResult;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
