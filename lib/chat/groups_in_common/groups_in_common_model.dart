import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'groups_in_common_widget.dart' show GroupsInCommonWidget;
import 'package:flutter/material.dart';

class GroupsInCommonModel extends FlutterFlowModel<GroupsInCommonWidget> {
  ///  Local state fields for this page.

  List<GroupInCommonStructStruct> groupsList = [];
  void addToGroupsList(GroupInCommonStructStruct item) => groupsList.add(item);
  void removeFromGroupsList(GroupInCommonStructStruct item) =>
      groupsList.remove(item);
  void removeAtIndexFromGroupsList(int index) => groupsList.removeAt(index);
  void insertAtIndexInGroupsList(int index, GroupInCommonStructStruct item) =>
      groupsList.insert(index, item);
  void updateGroupsListAtIndex(
          int index, Function(GroupInCommonStructStruct) updateFn) =>
      groupsList[index] = updateFn(groupsList[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getGroupsInCommon] action in Groups_in_common widget.
  List<GroupInCommonStructStruct>? getGroupsInCommon;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
