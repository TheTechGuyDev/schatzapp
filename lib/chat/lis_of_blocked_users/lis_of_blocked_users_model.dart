import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'lis_of_blocked_users_widget.dart' show LisOfBlockedUsersWidget;
import 'package:flutter/material.dart';

class LisOfBlockedUsersModel extends FlutterFlowModel<LisOfBlockedUsersWidget> {
  ///  Local state fields for this page.

  List<BlockedUserStructStruct> blockedUsersLists = [];
  void addToBlockedUsersLists(BlockedUserStructStruct item) =>
      blockedUsersLists.add(item);
  void removeFromBlockedUsersLists(BlockedUserStructStruct item) =>
      blockedUsersLists.remove(item);
  void removeAtIndexFromBlockedUsersLists(int index) =>
      blockedUsersLists.removeAt(index);
  void insertAtIndexInBlockedUsersLists(
          int index, BlockedUserStructStruct item) =>
      blockedUsersLists.insert(index, item);
  void updateBlockedUsersListsAtIndex(
          int index, Function(BlockedUserStructStruct) updateFn) =>
      blockedUsersLists[index] = updateFn(blockedUsersLists[index]);

  String searchQuerys = 'c';

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getBlockedUsers] action in Lis_of_blockedUsers widget.
  List<BlockedUserStructStruct>? blockedUsersList;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Custom Action - unblockUser] action in IconButton widget.
  bool? unblockUser;
  // Stores action output result for [Custom Action - getBlockedUsers] action in IconButton widget.
  List<BlockedUserStructStruct>? getBlockedUsers;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
