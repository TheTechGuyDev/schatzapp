import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/components/email_verify_component_widget.dart';
import '/components/phone_verify_component_widget.dart';
import '/components/sign_up_component_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'home_page_widget.dart' show HomePageWidget;
import 'package:flutter/material.dart';

class HomePageModel extends FlutterFlowModel<HomePageWidget> {
  ///  Local state fields for this page.

  List<ChatListItemStruct> allChats = [];
  void addToAllChats(ChatListItemStruct item) => allChats.add(item);
  void removeFromAllChats(ChatListItemStruct item) => allChats.remove(item);
  void removeAtIndexFromAllChats(int index) => allChats.removeAt(index);
  void insertAtIndexInAllChats(int index, ChatListItemStruct item) =>
      allChats.insert(index, item);
  void updateAllChatsAtIndex(
          int index, Function(ChatListItemStruct) updateFn) =>
      allChats[index] = updateFn(allChats[index]);

  List<ChatListItemStruct> filteredChats = [];
  void addToFilteredChats(ChatListItemStruct item) => filteredChats.add(item);
  void removeFromFilteredChats(ChatListItemStruct item) =>
      filteredChats.remove(item);
  void removeAtIndexFromFilteredChats(int index) =>
      filteredChats.removeAt(index);
  void insertAtIndexInFilteredChats(int index, ChatListItemStruct item) =>
      filteredChats.insert(index, item);
  void updateFilteredChatsAtIndex(
          int index, Function(ChatListItemStruct) updateFn) =>
      filteredChats[index] = updateFn(filteredChats[index]);

  String selectedFilter = 'all';

  List<StoryRingViewRow> storyRing = [];
  void addToStoryRing(StoryRingViewRow item) => storyRing.add(item);
  void removeFromStoryRing(StoryRingViewRow item) => storyRing.remove(item);
  void removeAtIndexFromStoryRing(int index) => storyRing.removeAt(index);
  void insertAtIndexInStoryRing(int index, StoryRingViewRow item) =>
      storyRing.insert(index, item);
  void updateStoryRingAtIndex(int index, Function(StoryRingViewRow) updateFn) =>
      storyRing[index] = updateFn(storyRing[index]);

  List<CallHistoryEntryStruct> callHistoryList = [];
  void addToCallHistoryList(CallHistoryEntryStruct item) =>
      callHistoryList.add(item);
  void removeFromCallHistoryList(CallHistoryEntryStruct item) =>
      callHistoryList.remove(item);
  void removeAtIndexFromCallHistoryList(int index) =>
      callHistoryList.removeAt(index);
  void insertAtIndexInCallHistoryList(int index, CallHistoryEntryStruct item) =>
      callHistoryList.insert(index, item);
  void updateCallHistoryListAtIndex(
          int index, Function(CallHistoryEntryStruct) updateFn) =>
      callHistoryList[index] = updateFn(callHistoryList[index]);

  List<StoryGroupStruct> friendsStoriesList = [];
  void addToFriendsStoriesList(StoryGroupStruct item) =>
      friendsStoriesList.add(item);
  void removeFromFriendsStoriesList(StoryGroupStruct item) =>
      friendsStoriesList.remove(item);
  void removeAtIndexFromFriendsStoriesList(int index) =>
      friendsStoriesList.removeAt(index);
  void insertAtIndexInFriendsStoriesList(int index, StoryGroupStruct item) =>
      friendsStoriesList.insert(index, item);
  void updateFriendsStoriesListAtIndex(
          int index, Function(StoryGroupStruct) updateFn) =>
      friendsStoriesList[index] = updateFn(friendsStoriesList[index]);

  StoryGroupStruct? myStoryGroup;
  void updateMyStoryGroupStruct(Function(StoryGroupStruct) updateFn) {
    updateFn(myStoryGroup ??= StoryGroupStruct());
  }

  bool isSelectionMode = false;

  List<String> selectedConversationIds = [];
  void addToSelectedConversationIds(String item) =>
      selectedConversationIds.add(item);
  void removeFromSelectedConversationIds(String item) =>
      selectedConversationIds.remove(item);
  void removeAtIndexFromSelectedConversationIds(int index) =>
      selectedConversationIds.removeAt(index);
  void insertAtIndexInSelectedConversationIds(int index, String item) =>
      selectedConversationIds.insert(index, item);
  void updateSelectedConversationIdsAtIndex(
          int index, Function(String) updateFn) =>
      selectedConversationIds[index] = updateFn(selectedConversationIds[index]);

  bool showHiddenStories = true;

  String chatListFilter = 'all';

  List<StoryGroupStruct> forYouFeed = [];
  void addToForYouFeed(StoryGroupStruct item) => forYouFeed.add(item);
  void removeFromForYouFeed(StoryGroupStruct item) => forYouFeed.remove(item);
  void removeAtIndexFromForYouFeed(int index) => forYouFeed.removeAt(index);
  void insertAtIndexInForYouFeed(int index, StoryGroupStruct item) =>
      forYouFeed.insert(index, item);
  void updateForYouFeedAtIndex(
          int index, Function(StoryGroupStruct) updateFn) =>
      forYouFeed[index] = updateFn(forYouFeed[index]);

  double schatzBalance = 0.0;

  String walletCurrency = 'NGN';

  double localBalance = 0.0;

  bool isBalanceHidden = false;

  double localEquivalentAmount = 0.0;

  String walletAuthStep = 'onboarding';

  String signupFullName = ' ';

  String signupEmail = ' ';

  String signupPhone = ' ';

  bool hasWallet = false;

  String phoneOtpCode = ' ';

  String kycStatus = ' ';

  bool showPinLoginError = false;

  bool pinBlocked = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in HomePage widget.
  List<StoryRingViewRow>? storyRingResult;
  // Stores action output result for [Custom Action - getCallHistory] action in HomePage widget.
  List<CallHistoryEntryStruct>? callHistoryResult;
  // Stores action output result for [Custom Action - getFriendsStories] action in HomePage widget.
  List<StoryGroupStruct>? friendsStoriesResult;
  // Stores action output result for [Custom Action - getMyStories] action in HomePage widget.
  StoryGroupStruct? myStoryResult;
  // Stores action output result for [Custom Action - getHiddenFromList] action in HomePage widget.
  List<HiddenPersonStruct>? hiddenListResult;
  // Stores action output result for [Backend Call - Query Rows] action in HomePage widget.
  List<WalletsRow>? walletQueryResult;
  // Stores action output result for [Custom Action - checkHasPin] action in HomePage widget.
  bool? hasPinResult;
  // Stores action output result for [Custom Action - callFxRate] action in HomePage widget.
  double? eurToLocalRateResult;
  // Stores action output result for [Backend Call - Query Rows] action in HomePage widget.
  List<WalletTransactionsRow>? recentTransactionsList;
  // State field(s) for TabBar widget.
  TabController? tabBarController1;
  int get tabBarCurrentIndex1 =>
      tabBarController1 != null ? tabBarController1!.index : 0;
  int get tabBarPreviousIndex1 =>
      tabBarController1 != null ? tabBarController1!.previousIndex : 0;

  // Stores action output result for [Custom Action - getForYouFeed] action in TabBar widget.
  List<StoryGroupStruct>? getForYouFeed;
  // State field(s) for TextForSearch widget.
  FocusNode? textForSearchFocusNode;
  TextEditingController? textForSearchTextController;
  String? Function(BuildContext, String?)? textForSearchTextControllerValidator;
  // State field(s) for TabBar widget.
  TabController? tabBarController2;
  int get tabBarCurrentIndex2 =>
      tabBarController2 != null ? tabBarController2!.index : 0;
  int get tabBarPreviousIndex2 =>
      tabBarController2 != null ? tabBarController2!.previousIndex : 0;

  // Model for SignUpComponent component.
  late SignUpComponentModel signUpComponentModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for PinCode widget.
  TextEditingController? pinCodeController;
  FocusNode? pinCodeFocusNode;
  String? Function(BuildContext, String?)? pinCodeControllerValidator;
  // Model for EmailVerifyComponent component.
  late EmailVerifyComponentModel emailVerifyComponentModel;
  // Model for PhoneVerifyComponent component.
  late PhoneVerifyComponentModel phoneVerifyComponentModel;
  // State field(s) for PinCodeEnter widget.
  TextEditingController? pinCodeEnter;
  FocusNode? pinCodeEnterFocusNode;
  String? Function(BuildContext, String?)? pinCodeEnterValidator;
  // Stores action output result for [Custom Action - verifyWalletPinDetailed] action in PinCodeEnter widget.
  String? pinVerifyDetailed;
  // State field(s) for TabBar widget.
  TabController? tabBarController3;
  int get tabBarCurrentIndex3 =>
      tabBarController3 != null ? tabBarController3!.index : 0;
  int get tabBarPreviousIndex3 =>
      tabBarController3 != null ? tabBarController3!.previousIndex : 0;

  // Stores action output result for [Custom Action - getHiddenFromList] action in IconButton widget.
  List<HiddenPersonStruct>? refreshedHiddenResult;

  @override
  void initState(BuildContext context) {
    signUpComponentModel = createModel(context, () => SignUpComponentModel());
    pinCodeController = TextEditingController();
    emailVerifyComponentModel =
        createModel(context, () => EmailVerifyComponentModel());
    phoneVerifyComponentModel =
        createModel(context, () => PhoneVerifyComponentModel());
    pinCodeEnter = TextEditingController();
  }

  @override
  void dispose() {
    tabBarController1?.dispose();
    textForSearchFocusNode?.dispose();
    textForSearchTextController?.dispose();

    tabBarController2?.dispose();
    signUpComponentModel.dispose();
    textFieldFocusNode?.dispose();
    textController2?.dispose();

    pinCodeFocusNode?.dispose();
    pinCodeController?.dispose();

    emailVerifyComponentModel.dispose();
    phoneVerifyComponentModel.dispose();
    pinCodeEnterFocusNode?.dispose();
    pinCodeEnter?.dispose();

    tabBarController3?.dispose();
  }
}
