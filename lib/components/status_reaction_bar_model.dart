import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'status_reaction_bar_widget.dart' show StatusReactionBarWidget;
import 'package:flutter/material.dart';

class StatusReactionBarModel extends FlutterFlowModel<StatusReactionBarWidget> {
  ///  Local state fields for this component.

  int favoriteCount = 0;

  int peaceCount = 0;

  int thumbsCount = 0;

  bool favoriteActive = false;

  bool peaceActive = false;

  bool thumbsActive = false;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - getReactionSummary] action in StatusReactionBar widget.
  ReactionSummaryStructStruct? getReaction;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
