import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'user_profile_widget.dart' show UserProfileWidget;
import 'package:flutter/material.dart';

class UserProfileModel extends FlutterFlowModel<UserProfileWidget> {
  ///  Local state fields for this page.

  ProfileStatsStruct? profileStats;
  void updateProfileStatsStruct(Function(ProfileStatsStruct) updateFn) {
    updateFn(profileStats ??= ProfileStatsStruct());
  }

  String resolvedName = ' ';

  String mutualPhone = ' ';

  bool isPrivateLocked = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getResolvedDisplayName] action in User_profile widget.
  String? resolvedNameResult;
  // Stores action output result for [Custom Action - getProfileStats] action in User_profile widget.
  ProfileStatsStruct? profileStatsResult;
  // Stores action output result for [Custom Action - isPrivateLocked] action in User_profile widget.
  bool? lockResult;
  // Stores action output result for [Custom Action - getMutualPhone] action in User_profile widget.
  String? phoneResult;
  // Stores action output result for [Custom Action - getResolvedDisplayName] action in Icon widget.
  String? newName;
  // Stores action output result for [Custom Action - findOrCreateConversation] action in Container widget.
  String? profileMessageResult;
  // Stores action output result for [Custom Action - findOrCreateConversation] action in Container widget.
  String? profileVoiceResult;
  // Stores action output result for [Custom Action - startCall] action in Container widget.
  CallStartResultStruct? profileVoiceCallResult;
  // Stores action output result for [Custom Action - findOrCreateConversation] action in Container widget.
  String? profileVideoResult;
  // Stores action output result for [Custom Action - startCall] action in Container widget.
  CallStartResultStruct? profileVideoCallResult;
  // Stores action output result for [Custom Action - getDirectConversationId] action in Theme_Column widget.
  String? themeConvId;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
