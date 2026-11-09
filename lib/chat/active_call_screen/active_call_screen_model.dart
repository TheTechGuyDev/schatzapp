import '/flutter_flow/flutter_flow_util.dart';
import 'active_call_screen_widget.dart' show ActiveCallScreenWidget;
import 'package:flutter/material.dart';

class ActiveCallScreenModel extends FlutterFlowModel<ActiveCallScreenWidget> {
  ///  Local state fields for this page.

  String? agoraDebugStatus;

  int refreshTick = 0;

  bool isMutedDisplay = false;

  bool isVideoOffDisplay = false;

  bool isSpeakerOnDisplay = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - joinAgoraCall] action in ActiveCallScreen widget.
  String? joinResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
