import 'package:flutter/material.dart'
    show ChangeNotifier, Color, Colors, VoidCallback;
import '/backend/schema/structs/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _walletLocked = prefs.getBool('ff_walletLocked') ?? _walletLocked;
    });
    _safeInit(() {
      _lastBackgroundedAt = prefs.containsKey('ff_lastBackgroundedAt')
          ? DateTime.fromMillisecondsSinceEpoch(
              prefs.getInt('ff_lastBackgroundedAt')!)
          : _lastBackgroundedAt;
    });
    _safeInit(() {
      _hasPinSetup = prefs.getBool('ff_hasPinSetup') ?? _hasPinSetup;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  CountryStruct _selectedCountry = CountryStruct.fromSerializableMap(jsonDecode(
      '{\"name\":\"Nigeria\",\"dialCode\":\"234\",\"isoCode\":\"NG\",\"flagUrl\":\"https://flagcdn.com/w80/ng.png\"}'));
  CountryStruct get selectedCountry => _selectedCountry;
  set selectedCountry(CountryStruct value) {
    _selectedCountry = value;
  }

  void updateSelectedCountryStruct(Function(CountryStruct) updateFn) {
    updateFn(_selectedCountry);
  }

  StoryGroupStruct _myStoryGroup = StoryGroupStruct();
  StoryGroupStruct get myStoryGroup => _myStoryGroup;
  set myStoryGroup(StoryGroupStruct value) {
    _myStoryGroup = value;
  }

  void updateMyStoryGroupStruct(Function(StoryGroupStruct) updateFn) {
    updateFn(_myStoryGroup);
  }

  List<StoryGroupStruct> _friendsStoriesList = [];
  List<StoryGroupStruct> get friendsStoriesList => _friendsStoriesList;
  set friendsStoriesList(List<StoryGroupStruct> value) {
    _friendsStoriesList = value;
  }

  void addToFriendsStoriesList(StoryGroupStruct value) {
    friendsStoriesList.add(value);
  }

  void removeFromFriendsStoriesList(StoryGroupStruct value) {
    friendsStoriesList.remove(value);
  }

  void removeAtIndexFromFriendsStoriesList(int index) {
    friendsStoriesList.removeAt(index);
  }

  void updateFriendsStoriesListAtIndex(
    int index,
    StoryGroupStruct Function(StoryGroupStruct) updateFn,
  ) {
    friendsStoriesList[index] = updateFn(_friendsStoriesList[index]);
  }

  void insertAtIndexInFriendsStoriesList(int index, StoryGroupStruct value) {
    friendsStoriesList.insert(index, value);
  }

  List<String> _pendingStoryImagePaths = [];
  List<String> get pendingStoryImagePaths => _pendingStoryImagePaths;
  set pendingStoryImagePaths(List<String> value) {
    _pendingStoryImagePaths = value;
  }

  void addToPendingStoryImagePaths(String value) {
    pendingStoryImagePaths.add(value);
  }

  void removeFromPendingStoryImagePaths(String value) {
    pendingStoryImagePaths.remove(value);
  }

  void removeAtIndexFromPendingStoryImagePaths(int index) {
    pendingStoryImagePaths.removeAt(index);
  }

  void updatePendingStoryImagePathsAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    pendingStoryImagePaths[index] = updateFn(_pendingStoryImagePaths[index]);
  }

  void insertAtIndexInPendingStoryImagePaths(int index, String value) {
    pendingStoryImagePaths.insert(index, value);
  }

  List<StoryUploadResultStruct> _pendingStoryUploadedUrls = [];
  List<StoryUploadResultStruct> get pendingStoryUploadedUrls =>
      _pendingStoryUploadedUrls;
  set pendingStoryUploadedUrls(List<StoryUploadResultStruct> value) {
    _pendingStoryUploadedUrls = value;
  }

  void addToPendingStoryUploadedUrls(StoryUploadResultStruct value) {
    pendingStoryUploadedUrls.add(value);
  }

  void removeFromPendingStoryUploadedUrls(StoryUploadResultStruct value) {
    pendingStoryUploadedUrls.remove(value);
  }

  void removeAtIndexFromPendingStoryUploadedUrls(int index) {
    pendingStoryUploadedUrls.removeAt(index);
  }

  void updatePendingStoryUploadedUrlsAtIndex(
    int index,
    StoryUploadResultStruct Function(StoryUploadResultStruct) updateFn,
  ) {
    pendingStoryUploadedUrls[index] =
        updateFn(_pendingStoryUploadedUrls[index]);
  }

  void insertAtIndexInPendingStoryUploadedUrls(
      int index, StoryUploadResultStruct value) {
    pendingStoryUploadedUrls.insert(index, value);
  }

  List<PendingWebImageStruct> _pendingWebStoryImages = [];
  List<PendingWebImageStruct> get pendingWebStoryImages =>
      _pendingWebStoryImages;
  set pendingWebStoryImages(List<PendingWebImageStruct> value) {
    _pendingWebStoryImages = value;
  }

  void addToPendingWebStoryImages(PendingWebImageStruct value) {
    pendingWebStoryImages.add(value);
  }

  void removeFromPendingWebStoryImages(PendingWebImageStruct value) {
    pendingWebStoryImages.remove(value);
  }

  void removeAtIndexFromPendingWebStoryImages(int index) {
    pendingWebStoryImages.removeAt(index);
  }

  void updatePendingWebStoryImagesAtIndex(
    int index,
    PendingWebImageStruct Function(PendingWebImageStruct) updateFn,
  ) {
    pendingWebStoryImages[index] = updateFn(_pendingWebStoryImages[index]);
  }

  void insertAtIndexInPendingWebStoryImages(
      int index, PendingWebImageStruct value) {
    pendingWebStoryImages.insert(index, value);
  }

  List<String> _pendingStoryTaggedUserIds = [];
  List<String> get pendingStoryTaggedUserIds => _pendingStoryTaggedUserIds;
  set pendingStoryTaggedUserIds(List<String> value) {
    _pendingStoryTaggedUserIds = value;
  }

  void addToPendingStoryTaggedUserIds(String value) {
    pendingStoryTaggedUserIds.add(value);
  }

  void removeFromPendingStoryTaggedUserIds(String value) {
    pendingStoryTaggedUserIds.remove(value);
  }

  void removeAtIndexFromPendingStoryTaggedUserIds(int index) {
    pendingStoryTaggedUserIds.removeAt(index);
  }

  void updatePendingStoryTaggedUserIdsAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    pendingStoryTaggedUserIds[index] =
        updateFn(_pendingStoryTaggedUserIds[index]);
  }

  void insertAtIndexInPendingStoryTaggedUserIds(int index, String value) {
    pendingStoryTaggedUserIds.insert(index, value);
  }

  List<HiddenPersonStruct> _hiddenList = [];
  List<HiddenPersonStruct> get hiddenList => _hiddenList;
  set hiddenList(List<HiddenPersonStruct> value) {
    _hiddenList = value;
  }

  void addToHiddenList(HiddenPersonStruct value) {
    hiddenList.add(value);
  }

  void removeFromHiddenList(HiddenPersonStruct value) {
    hiddenList.remove(value);
  }

  void removeAtIndexFromHiddenList(int index) {
    hiddenList.removeAt(index);
  }

  void updateHiddenListAtIndex(
    int index,
    HiddenPersonStruct Function(HiddenPersonStruct) updateFn,
  ) {
    hiddenList[index] = updateFn(_hiddenList[index]);
  }

  void insertAtIndexInHiddenList(int index, HiddenPersonStruct value) {
    hiddenList.insert(index, value);
  }

  List<String> _storyDraftOriginalImages = [];
  List<String> get storyDraftOriginalImages => _storyDraftOriginalImages;
  set storyDraftOriginalImages(List<String> value) {
    _storyDraftOriginalImages = value;
  }

  void addToStoryDraftOriginalImages(String value) {
    storyDraftOriginalImages.add(value);
  }

  void removeFromStoryDraftOriginalImages(String value) {
    storyDraftOriginalImages.remove(value);
  }

  void removeAtIndexFromStoryDraftOriginalImages(int index) {
    storyDraftOriginalImages.removeAt(index);
  }

  void updateStoryDraftOriginalImagesAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    storyDraftOriginalImages[index] =
        updateFn(_storyDraftOriginalImages[index]);
  }

  void insertAtIndexInStoryDraftOriginalImages(int index, String value) {
    storyDraftOriginalImages.insert(index, value);
  }

  List<String> _storyDraftEditedImages = [];
  List<String> get storyDraftEditedImages => _storyDraftEditedImages;
  set storyDraftEditedImages(List<String> value) {
    _storyDraftEditedImages = value;
  }

  void addToStoryDraftEditedImages(String value) {
    storyDraftEditedImages.add(value);
  }

  void removeFromStoryDraftEditedImages(String value) {
    storyDraftEditedImages.remove(value);
  }

  void removeAtIndexFromStoryDraftEditedImages(int index) {
    storyDraftEditedImages.removeAt(index);
  }

  void updateStoryDraftEditedImagesAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    storyDraftEditedImages[index] = updateFn(_storyDraftEditedImages[index]);
  }

  void insertAtIndexInStoryDraftEditedImages(int index, String value) {
    storyDraftEditedImages.insert(index, value);
  }

  List<String> _storyDraftMediaTypes = [];
  List<String> get storyDraftMediaTypes => _storyDraftMediaTypes;
  set storyDraftMediaTypes(List<String> value) {
    _storyDraftMediaTypes = value;
  }

  void addToStoryDraftMediaTypes(String value) {
    storyDraftMediaTypes.add(value);
  }

  void removeFromStoryDraftMediaTypes(String value) {
    storyDraftMediaTypes.remove(value);
  }

  void removeAtIndexFromStoryDraftMediaTypes(int index) {
    storyDraftMediaTypes.removeAt(index);
  }

  void updateStoryDraftMediaTypesAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    storyDraftMediaTypes[index] = updateFn(_storyDraftMediaTypes[index]);
  }

  void insertAtIndexInStoryDraftMediaTypes(int index, String value) {
    storyDraftMediaTypes.insert(index, value);
  }

  int _storyDraftEditingIndex = -1;
  int get storyDraftEditingIndex => _storyDraftEditingIndex;
  set storyDraftEditingIndex(int value) {
    _storyDraftEditingIndex = value;
  }

  int _storyDraftDurationHours = 24;
  int get storyDraftDurationHours => _storyDraftDurationHours;
  set storyDraftDurationHours(int value) {
    _storyDraftDurationHours = value;
  }

  List<String> _storyDraftCaptions = [];
  List<String> get storyDraftCaptions => _storyDraftCaptions;
  set storyDraftCaptions(List<String> value) {
    _storyDraftCaptions = value;
  }

  void addToStoryDraftCaptions(String value) {
    storyDraftCaptions.add(value);
  }

  void removeFromStoryDraftCaptions(String value) {
    storyDraftCaptions.remove(value);
  }

  void removeAtIndexFromStoryDraftCaptions(int index) {
    storyDraftCaptions.removeAt(index);
  }

  void updateStoryDraftCaptionsAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    storyDraftCaptions[index] = updateFn(_storyDraftCaptions[index]);
  }

  void insertAtIndexInStoryDraftCaptions(int index, String value) {
    storyDraftCaptions.insert(index, value);
  }

  int _storyDraftRefreshTick = 0;
  int get storyDraftRefreshTick => _storyDraftRefreshTick;
  set storyDraftRefreshTick(int value) {
    _storyDraftRefreshTick = value;
  }

  bool _callSelectionMode = false;
  bool get callSelectionMode => _callSelectionMode;
  set callSelectionMode(bool value) {
    _callSelectionMode = value;
  }

  List<String> _selectedCallIds = [];
  List<String> get selectedCallIds => _selectedCallIds;
  set selectedCallIds(List<String> value) {
    _selectedCallIds = value;
  }

  void addToSelectedCallIds(String value) {
    selectedCallIds.add(value);
  }

  void removeFromSelectedCallIds(String value) {
    selectedCallIds.remove(value);
  }

  void removeAtIndexFromSelectedCallIds(int index) {
    selectedCallIds.removeAt(index);
  }

  void updateSelectedCallIdsAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    selectedCallIds[index] = updateFn(_selectedCallIds[index]);
  }

  void insertAtIndexInSelectedCallIds(int index, String value) {
    selectedCallIds.insert(index, value);
  }

  List<bool> _storyDraftCarousel = [];
  List<bool> get storyDraftCarousel => _storyDraftCarousel;
  set storyDraftCarousel(List<bool> value) {
    _storyDraftCarousel = value;
  }

  void addToStoryDraftCarousel(bool value) {
    storyDraftCarousel.add(value);
  }

  void removeFromStoryDraftCarousel(bool value) {
    storyDraftCarousel.remove(value);
  }

  void removeAtIndexFromStoryDraftCarousel(int index) {
    storyDraftCarousel.removeAt(index);
  }

  void updateStoryDraftCarouselAtIndex(
    int index,
    bool Function(bool) updateFn,
  ) {
    storyDraftCarousel[index] = updateFn(_storyDraftCarousel[index]);
  }

  void insertAtIndexInStoryDraftCarousel(int index, bool value) {
    storyDraftCarousel.insert(index, value);
  }

  String _kycFirstName = '';
  String get kycFirstName => _kycFirstName;
  set kycFirstName(String value) {
    _kycFirstName = value;
  }

  String _kycLastName = '';
  String get kycLastName => _kycLastName;
  set kycLastName(String value) {
    _kycLastName = value;
  }

  String _kycDateOfBirth = '';
  String get kycDateOfBirth => _kycDateOfBirth;
  set kycDateOfBirth(String value) {
    _kycDateOfBirth = value;
  }

  String _kycGender = '';
  String get kycGender => _kycGender;
  set kycGender(String value) {
    _kycGender = value;
  }

  String _kycStreetAddress = '';
  String get kycStreetAddress => _kycStreetAddress;
  set kycStreetAddress(String value) {
    _kycStreetAddress = value;
  }

  String _kycCity = '';
  String get kycCity => _kycCity;
  set kycCity(String value) {
    _kycCity = value;
  }

  String _kycState = '';
  String get kycState => _kycState;
  set kycState(String value) {
    _kycState = value;
  }

  String _kycPostcode = '';
  String get kycPostcode => _kycPostcode;
  set kycPostcode(String value) {
    _kycPostcode = value;
  }

  String _kycCountry = '';
  String get kycCountry => _kycCountry;
  set kycCountry(String value) {
    _kycCountry = value;
  }

  String _kycIdType = '';
  String get kycIdType => _kycIdType;
  set kycIdType(String value) {
    _kycIdType = value;
  }

  String _kycIdFrontUrl = '';
  String get kycIdFrontUrl => _kycIdFrontUrl;
  set kycIdFrontUrl(String value) {
    _kycIdFrontUrl = value;
  }

  String _kycIdBackUrl = '';
  String get kycIdBackUrl => _kycIdBackUrl;
  set kycIdBackUrl(String value) {
    _kycIdBackUrl = value;
  }

  String _kycSelfieUrl = '';
  String get kycSelfieUrl => _kycSelfieUrl;
  set kycSelfieUrl(String value) {
    _kycSelfieUrl = value;
  }

  bool _walletLocked = false;
  bool get walletLocked => _walletLocked;
  set walletLocked(bool value) {
    _walletLocked = value;
    prefs.setBool('ff_walletLocked', value);
  }

  DateTime? _lastBackgroundedAt;
  DateTime? get lastBackgroundedAt => _lastBackgroundedAt;
  set lastBackgroundedAt(DateTime? value) {
    _lastBackgroundedAt = value;
    value != null
        ? prefs.setInt('ff_lastBackgroundedAt', value.millisecondsSinceEpoch)
        : prefs.remove('ff_lastBackgroundedAt');
  }

  bool _sessionHomeLoaded = false;
  bool get sessionHomeLoaded => _sessionHomeLoaded;
  set sessionHomeLoaded(bool value) {
    _sessionHomeLoaded = value;
  }

  int _previousTabIndex = 0;
  int get previousTabIndex => _previousTabIndex;
  set previousTabIndex(int value) {
    _previousTabIndex = value;
  }

  String _resetErrorMessage = '';
  String get resetErrorMessage => _resetErrorMessage;
  set resetErrorMessage(String value) {
    _resetErrorMessage = value;
  }

  bool _hasPinSetup = false;
  bool get hasPinSetup => _hasPinSetup;
  set hasPinSetup(bool value) {
    _hasPinSetup = value;
    prefs.setBool('ff_hasPinSetup', value);
  }

  String _selectedCardId = '';
  String get selectedCardId => _selectedCardId;
  set selectedCardId(String value) {
    _selectedCardId = value;
  }

  String _walletPinBuffer = '';
  String get walletPinBuffer => _walletPinBuffer;
  set walletPinBuffer(String value) {
    _walletPinBuffer = value;
  }

  bool _walletPinResult = false;
  bool get walletPinResult => _walletPinResult;
  set walletPinResult(bool value) {
    _walletPinResult = value;
  }

  String _recentContactSelectedPhone = '';
  String get recentContactSelectedPhone => _recentContactSelectedPhone;
  set recentContactSelectedPhone(String value) {
    _recentContactSelectedPhone = value;
  }

  double _topUpTypedAmount = 0.0;
  double get topUpTypedAmount => _topUpTypedAmount;
  set topUpTypedAmount(double value) {
    _topUpTypedAmount = value;
  }

  bool _groupReplyIsOwn = false;
  bool get groupReplyIsOwn => _groupReplyIsOwn;
  set groupReplyIsOwn(bool value) {
    _groupReplyIsOwn = value;
  }

  bool _newCallGroupMode = false;
  bool get newCallGroupMode => _newCallGroupMode;
  set newCallGroupMode(bool value) {
    _newCallGroupMode = value;
  }

  bool _callsSearchActive = false;
  bool get callsSearchActive => _callsSearchActive;
  set callsSearchActive(bool value) {
    _callsSearchActive = value;
  }

  bool _chatBlocked = false;
  bool get chatBlocked => _chatBlocked;
  set chatBlocked(bool value) {
    _chatBlocked = value;
  }

  bool _storyDraftCommentsEnabled = false;
  bool get storyDraftCommentsEnabled => _storyDraftCommentsEnabled;
  set storyDraftCommentsEnabled(bool value) {
    _storyDraftCommentsEnabled = value;
  }

  DateTime? _privateUnlockedAt;
  DateTime? get privateUnlockedAt => _privateUnlockedAt;
  set privateUnlockedAt(DateTime? value) {
    _privateUnlockedAt = value;
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
