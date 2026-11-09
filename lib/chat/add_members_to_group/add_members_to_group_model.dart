import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'add_members_to_group_widget.dart' show AddMembersToGroupWidget;
import 'package:flutter/material.dart';

class AddMembersToGroupModel extends FlutterFlowModel<AddMembersToGroupWidget> {
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

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - addMembersToExistingGroup] action in Button widget.
  bool? addSuccess;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Custom Action - toggleGroupMemberSelection] action in Icon widget.
  List<GroupMemberStructStruct>? updatedSelection2;
  // Stores action output result for [Custom Action - toggleGroupMemberSelection] action in Column widget.
  List<GroupMemberStructStruct>? updatedSelection;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
