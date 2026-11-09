import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'call_search_widget.dart' show CallSearchWidget;
import 'package:flutter/material.dart';

class CallSearchModel extends FlutterFlowModel<CallSearchWidget> {
  ///  Local state fields for this page.

  List<CallHistoryEntryStruct> callHistoryList = [];
  void addToCallHistoryList(CallHistoryEntryStruct item) =>
      callHistoryList.add(item);
  void removeFromCallHistoryList(CallHistoryEntryStruct item) =>
      callHistoryList.remove(item);
  void removeAtIndexFromCallHistoryList(int index) =>
      callHistoryList.removeAt(index);
  void insertAtIndexInCallHistoryList(int index, CallHistoryEntryStruct item) =>
      callHistoryList.insert(index, item);
  void updateCallHistoryListAtIndex(
          int index, Function(CallHistoryEntryStruct) updateFn) =>
      callHistoryList[index] = updateFn(callHistoryList[index]);

  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Custom Action - startCall] action in Icon widget.
  CallStartResultStruct? contactVoiceCallResult;
  // Stores action output result for [Custom Action - startCall] action in Icon widget.
  CallStartResultStruct? contactVideoCallResult;
  // Stores action output result for [Custom Action - startCall] action in Icon widget.
  CallStartResultStruct? contactVoiceCallResult1;
  // Stores action output result for [Custom Action - startCall] action in Icon widget.
  CallStartResultStruct? contactVideoCallResult2;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
