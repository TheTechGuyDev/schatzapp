import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'status_reaction_bar_widget.dart' show StatusReactionBarWidget;
import 'package:flutter/material.dart';

class StatusReactionBarModel extends FlutterFlowModel<StatusReactionBarWidget> {
  ///  Local state fields for this component.

  /// Count per reaction type: favorite, peace, laugh, sad, angry.
  Map<String, int> counts = {
    'favorite': 0,
    'peace': 0,
    'laugh': 0,
    'sad': 0,
    'angry': 0,
  };

  /// Reaction types the viewer picked (max 2).
  Set<String> mine = {};

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - getReactionSummary] action in StatusReactionBar widget.
  ReactionSummaryStructStruct? getReaction;

  void applySummary(ReactionSummaryStructStruct s) {
    getReaction = s;
    counts = {
      'favorite': s.favoriteCount,
      'peace': s.peaceCount,
      'laugh': s.laughCount,
      'sad': s.sadCount,
      'angry': s.angryCount,
    };
    mine = {
      if (s.favoriteActive) 'favorite',
      if (s.peaceActive) 'peace',
      if (s.laughActive) 'laugh',
      if (s.sadActive) 'sad',
      if (s.angryActive) 'angry',
    };
  }

  void flip(String type, bool on) {
    final c = counts[type] ?? 0;
    if (on) {
      mine.add(type);
      counts[type] = c + 1;
    } else {
      mine.remove(type);
      counts[type] = c > 0 ? c - 1 : 0;
    }
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
