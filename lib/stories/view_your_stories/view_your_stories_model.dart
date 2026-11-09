import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'view_your_stories_widget.dart' show ViewYourStoriesWidget;
import 'package:flutter/material.dart';

class ViewYourStoriesModel extends FlutterFlowModel<ViewYourStoriesWidget> {
  ///  Local state fields for this page.

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

  int currentStoryIndex = 0;

  StoryGroupStruct? myStoryGroup;
  void updateMyStoryGroupStruct(Function(StoryGroupStruct) updateFn) {
    updateFn(myStoryGroup ??= StoryGroupStruct());
  }

  bool isMyStoryReady = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getMyStories] action in view_your_stories widget.
  StoryGroupStruct? fallbackMyStoryResult;
  // State field(s) for Carousel widget.
  CarouselSliderController? carouselController;
  int carouselCurrentIndex = 0;

  // Stores action output result for [Custom Action - getStatusViewers] action in Carousel widget.
  List<StatusViewerStruct>? currentStatusViewersResult;
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
