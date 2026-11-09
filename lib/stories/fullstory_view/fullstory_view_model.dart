import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'fullstory_view_widget.dart' show FullstoryViewWidget;
import 'package:flutter/material.dart';

class FullstoryViewModel extends FlutterFlowModel<FullstoryViewWidget> {
  ///  Local state fields for this page.

  bool isMyStoryReady = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getMyStories] action in fullstory_view widget.
  StoryGroupStruct? fallbackMyStoryResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
