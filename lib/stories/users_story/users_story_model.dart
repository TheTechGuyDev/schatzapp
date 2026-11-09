import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'users_story_widget.dart' show UsersStoryWidget;
import 'package:flutter/material.dart';

class UsersStoryModel extends FlutterFlowModel<UsersStoryWidget> {
  ///  Local state fields for this page.

  List<StoryGroupStruct> friendsStoriesList = [];
  void addToFriendsStoriesList(StoryGroupStruct item) =>
      friendsStoriesList.add(item);
  void removeFromFriendsStoriesList(StoryGroupStruct item) =>
      friendsStoriesList.remove(item);
  void removeAtIndexFromFriendsStoriesList(int index) =>
      friendsStoriesList.removeAt(index);
  void insertAtIndexInFriendsStoriesList(int index, StoryGroupStruct item) =>
      friendsStoriesList.insert(index, item);
  void updateFriendsStoriesListAtIndex(
          int index, Function(StoryGroupStruct) updateFn) =>
      friendsStoriesList[index] = updateFn(friendsStoriesList[index]);

  int currentStoryItemIndex = 0;

  ///  State fields for stateful widgets in this page.

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
