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

  bool myLock = false;

  bool saveGallery = true;

  bool settingsLoaded = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getResolvedDisplayName] action in User_profile widget.
  String? resolvedNameResult;
  // Stores action output result for [Custom Action - getProfileStats] action in User_profile widget.
  ProfileStatsStruct? profileStatsResult;
  // Stores action output result for [Custom Action - isMyPrivateLock] action in User_profile widget.
  bool? myLockResult;
  // Stores action output result for [Custom Action - saveToGallerySetting] action in User_profile widget.
  bool? saveResult;
  // Stores action output result for [Custom Action - isPrivateLocked] action in User_profile widget.
  bool? lockResult;
  // Stores action output result for [Custom Action - getMutualPhone] action in User_profile widget.
  String? phoneResult;
  // Stores action output result for [Custom Action - isPrivateLocked] action in User_profile widget.
  bool? lockCheck;
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
  // State field(s) for Switch widget.
  bool? switchValue1;
  // Stores action output result for [Custom Action - setPrivateLock] action in Switch widget.
  bool? lockOk;
  // Stores action output result for [Custom Action - setPrivateLock] action in Switch widget.
  bool? unlockOk;
  // State field(s) for Switch widget.
  bool? switchValue2;
  // Stores action output result for [Custom Action - getDirectConversationId] action in Theme_Column widget.
  String? themeConvId;
  // Stores action output result for [Custom Action - findOrCreateConversation] action in Icon widget.
  String? profileMessageSeaarchResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
