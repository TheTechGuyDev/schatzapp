import '/components/status_reaction_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'for_you_dummy_test_widget.dart' show ForYouDummyTestWidget;
import 'package:flutter/material.dart';

class ForYouDummyTestModel extends FlutterFlowModel<ForYouDummyTestWidget> {
  ///  State fields for stateful widgets in this page.

  // Models for StatusReactionBar dynamic component.
  late FlutterFlowDynamicModels<StatusReactionBarModel> statusReactionBarModels;

  @override
  void initState(BuildContext context) {
    statusReactionBarModels =
        FlutterFlowDynamicModels(() => StatusReactionBarModel());
  }

  @override
  void dispose() {
    statusReactionBarModels.dispose();
  }
}
