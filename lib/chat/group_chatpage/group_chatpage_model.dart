import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'group_chatpage_widget.dart' show GroupChatpageWidget;
import 'package:flutter/material.dart';

class GroupChatpageModel extends FlutterFlowModel<GroupChatpageWidget> {
  ///  Local state fields for this page.

  String? memberNamesSummary;

  bool showMediaPicker = false;

  bool isSending = false;

  bool hasStagedMedia = false;

  bool isRecordingVoice = false;

  bool replyingToIsOwn = false;

  List<String> stagedMediaUrls = [];
  void addToStagedMediaUrls(String item) => stagedMediaUrls.add(item);
  void removeFromStagedMediaUrls(String item) => stagedMediaUrls.remove(item);
  void removeAtIndexFromStagedMediaUrls(int index) =>
      stagedMediaUrls.removeAt(index);
  void insertAtIndexInStagedMediaUrls(int index, String item) =>
      stagedMediaUrls.insert(index, item);
  void updateStagedMediaUrlsAtIndex(int index, Function(String) updateFn) =>
      stagedMediaUrls[index] = updateFn(stagedMediaUrls[index]);

  String? replyingToMessageId;

  String? replyingToContent;

  String? forwardingMessageId;

  String? forwardingContent;

  String? forwardingMessageType;

  String? forwardingMediaUrl;

  String selectedFilter = 'all';

  List<ProfilesRow> groupParticipantProfiles = [];
  void addToGroupParticipantProfiles(ProfilesRow item) =>
      groupParticipantProfiles.add(item);
  void removeFromGroupParticipantProfiles(ProfilesRow item) =>
      groupParticipantProfiles.remove(item);
  void removeAtIndexFromGroupParticipantProfiles(int index) =>
      groupParticipantProfiles.removeAt(index);
  void insertAtIndexInGroupParticipantProfiles(int index, ProfilesRow item) =>
      groupParticipantProfiles.insert(index, item);
  void updateGroupParticipantProfilesAtIndex(
          int index, Function(ProfilesRow) updateFn) =>
      groupParticipantProfiles[index] =
          updateFn(groupParticipantProfiles[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getGroupMemberSummary] action in Group_chatpage widget.
  String? summaryResult;
  // Stores action output result for [Custom Action - getGroupParticipantProfiles] action in Group_chatpage widget.
  List<ProfilesRow>? groupParticipantProfilesResult;
  Stream<List<ConversationParticipantsRow>>? wallpapperContainerSupabaseStream;
  // State field(s) for TextFieldMessageMood widget.
  FocusNode? textFieldMessageMoodFocusNode;
  TextEditingController? textFieldMessageMoodTextController;
  String? Function(BuildContext, String?)?
      textFieldMessageMoodTextControllerValidator;
  // Stores action output result for [Custom Action - uploadStagedAssets] action in Icon widget.
  List<String>? uploadedImageUrls;
  // Stores action output result for [Custom Action - uploadVoiceNote] action in VoiceRecorderBar widget.
  String? voiceNoteUrl;
  // Stores action output result for [Custom Action - uploadStagedAssets] action in Text widget.
  List<String>? uploadedImageUrls2;
  // Stores action output result for [Custom Action - captureAndSaveCameraPhoto] action in DeviceGalleryGrid widget.
  String? newCameraAssetId;
  // Stores action output result for [Custom Action - startCall] action in Icon widget.
  CallStartResultStruct? callResult2;
  // Stores action output result for [Custom Action - startCall] action in Icon widget.
  CallStartResultStruct? callResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldMessageMoodFocusNode?.dispose();
    textFieldMessageMoodTextController?.dispose();
  }
}
