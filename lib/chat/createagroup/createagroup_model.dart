import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'createagroup_widget.dart' show CreateagroupWidget;
import 'package:flutter/material.dart';

class CreateagroupModel extends FlutterFlowModel<CreateagroupWidget> {
  ///  Local state fields for this component.

  String? groupPhotoUrl;

  bool isCreatingGroup = false;

  List<GroupMemberStructStruct> selectedMembers = [];
  void addToSelectedMembers(GroupMemberStructStruct item) =>
      selectedMembers.add(item);
  void removeFromSelectedMembers(GroupMemberStructStruct item) =>
      selectedMembers.remove(item);
  void removeAtIndexFromSelectedMembers(int index) =>
      selectedMembers.removeAt(index);
  void insertAtIndexInSelectedMembers(
          int index, GroupMemberStructStruct item) =>
      selectedMembers.insert(index, item);
  void updateSelectedMembersAtIndex(
          int index, Function(GroupMemberStructStruct) updateFn) =>
      selectedMembers[index] = updateFn(selectedMembers[index]);

  bool isPrivateGroup = false;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - createGroupConversation] action in Button widget.
  String? newConversationId;
  // Stores action output result for [Custom Action - pickAndUploadGroupAvatar] action in Stack widget.
  String? avatarUrl;
  // State field(s) for PrivateChatLockgroupSwitch widget.
  bool? privateChatLockgroupSwitchValue;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // Stores action output result for [Custom Action - toggleGroupMemberSelection] action in Icon widget.
  List<GroupMemberStructStruct>? updatedSelection2;
  // Stores action output result for [Custom Action - toggleContactSelection] action in Column widget.
  List<GroupMemberStructStruct>? updatedSelection;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();
  }
}
