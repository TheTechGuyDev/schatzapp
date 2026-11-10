import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'chatpage_widget.dart' show ChatpageWidget;
import 'package:flutter/material.dart';

class ChatpageModel extends FlutterFlowModel<ChatpageWidget> {
  ///  Local state fields for this page.

  ProfilesRow? otherUserProfile;

  bool showMediaPicker = false;

  List<String> stagedMediaUrls = [];
  void addToStagedMediaUrls(String item) => stagedMediaUrls.add(item);
  void removeFromStagedMediaUrls(String item) => stagedMediaUrls.remove(item);
  void removeAtIndexFromStagedMediaUrls(int index) =>
      stagedMediaUrls.removeAt(index);
  void insertAtIndexInStagedMediaUrls(int index, String item) =>
      stagedMediaUrls.insert(index, item);
  void updateStagedMediaUrlsAtIndex(int index, Function(String) updateFn) =>
      stagedMediaUrls[index] = updateFn(stagedMediaUrls[index]);

  bool isSending = false;

  bool hasStagedMedia = false;

  String? replyingToMessageId;

  String? replyingToContent;

  bool replyingToIsOwn = false;

  String? forwardingMessageId;

  String? forwardingContent;

  String? forwardingMessageType;

  String? forwardingMediaUrl;

  bool isRecordingVoice = false;

  String selectedFilter = 'all';

  List<PendingWebImageStruct> pendingWebChatImages = [];
  void addToPendingWebChatImages(PendingWebImageStruct item) =>
      pendingWebChatImages.add(item);
  void removeFromPendingWebChatImages(PendingWebImageStruct item) =>
      pendingWebChatImages.remove(item);
  void removeAtIndexFromPendingWebChatImages(int index) =>
      pendingWebChatImages.removeAt(index);
  void insertAtIndexInPendingWebChatImages(
          int index, PendingWebImageStruct item) =>
      pendingWebChatImages.insert(index, item);
  void updatePendingWebChatImagesAtIndex(
          int index, Function(PendingWebImageStruct) updateFn) =>
      pendingWebChatImages[index] = updateFn(pendingWebChatImages[index]);

  bool isPrivateLocked = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - isPrivateLocked] action in chatpage widget.
  bool? lockResult;
  // Stores action output result for [Backend Call - Query Rows] action in chatpage widget.
  List<ProfilesRow>? otherUserProfileResult;
  // Stores action output result for [Custom Action - pickMultipleWebChatMedia] action in Icon widget.
  List<PendingWebImageStruct>? pickedImages;
  // State field(s) for TextFieldMessageMood widget.
  FocusNode? textFieldMessageMoodFocusNode;
  TextEditingController? textFieldMessageMoodTextController;
  String? Function(BuildContext, String?)?
      textFieldMessageMoodTextControllerValidator;
  // Stores action output result for [Custom Action - sendPendingWebChatImages] action in Icon widget.
  String? sendError;
  // Stores action output result for [Custom Action - uploadStagedAssetsWithEdits] action in Icon widget.
  List<String>? uploadedImageUrls;
  // Stores action output result for [Custom Action - uploadVoiceNote] action in VoiceRecorderBar widget.
  String? voiceNoteUrl;
  // Stores action output result for [Custom Action - uploadStagedAssets] action in Text widget.
  List<String>? uploadedImageUrls2;
  // Stores action output result for [Custom Action - captureAndSaveCameraPhoto] action in DeviceGalleryGrid widget.
  String? newCameraAssetId;
  // Stores action output result for [Custom Action - startCall] action in Icon widget.
  CallStartResultStruct? callResult;
  // Stores action output result for [Custom Action - startCall] action in Icon widget.
  CallStartResultStruct? callResult2;
  // Stores action output result for [Custom Action - sendBimp] action in Icon widget.
  bool? bimpSent;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldMessageMoodFocusNode?.dispose();
    textFieldMessageMoodTextController?.dispose();

    textFieldFocusNode?.dispose();
    textController2?.dispose();
  }
}
