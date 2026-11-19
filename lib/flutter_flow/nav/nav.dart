import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/backend/schema/structs/index.dart';


import '/auth/base_auth_user_provider.dart';

import '/flutter_flow/flutter_flow_util.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) =>
          appStateNotifier.loggedIn ? HomePageWidget() : SplashScreenWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => appStateNotifier.loggedIn
              ? HomePageWidget()
              : SplashScreenWidget(),
        ),
        FFRoute(
          name: HomePageWidget.routeName,
          path: HomePageWidget.routePath,
          builder: (context, params) => HomePageWidget(),
        ),
        FFRoute(
          name: ChatpageWidget.routeName,
          path: ChatpageWidget.routePath,
          builder: (context, params) => ChatpageWidget(
            conversationId: params.getParam(
              'conversationId',
              ParamType.String,
            ),
            otherUserId: params.getParam(
              'otherUserId',
              ParamType.String,
            ),
            displayName: params.getParam(
              'displayName',
              ParamType.String,
            ),
            displayAvatar: params.getParam(
              'displayAvatar',
              ParamType.String,
            ),
            initialTargetMessageId: params.getParam(
              'initialTargetMessageId',
              ParamType.String,
            ),
            replyingToMessageId: params.getParam(
              'replyingToMessageId',
              ParamType.String,
            ),
            replyToContent: params.getParam(
              'replyToContent',
              ParamType.String,
            ),
            replyingToIsOwn: params.getParam(
              'replyingToIsOwn',
              ParamType.bool,
            ),
            startSearch: params.getParam(
              'startSearch',
              ParamType.bool,
            ),
          ),
        ),
        FFRoute(
          name: SendmoneyWidget.routeName,
          path: SendmoneyWidget.routePath,
          builder: (context, params) => SendmoneyWidget(),
        ),
        FFRoute(
          name: AddfriendsWidget.routeName,
          path: AddfriendsWidget.routePath,
          builder: (context, params) => AddfriendsWidget(),
        ),
        FFRoute(
          name: TopupwalletWidget.routeName,
          path: TopupwalletWidget.routePath,
          builder: (context, params) => TopupwalletWidget(),
        ),
        FFRoute(
          name: AirtimeWidget.routeName,
          path: AirtimeWidget.routePath,
          builder: (context, params) => AirtimeWidget(),
        ),
        FFRoute(
          name: GiftcardWidget.routeName,
          path: GiftcardWidget.routePath,
          builder: (context, params) => GiftcardWidget(),
        ),
        FFRoute(
          name: AdminUsersWidget.routeName,
          path: AdminUsersWidget.routePath,
          builder: (context, params) => AdminUsersWidget(),
        ),
        FFRoute(
          name: GroupProfileDetailsPageWidget.routeName,
          path: GroupProfileDetailsPageWidget.routePath,
          builder: (context, params) => GroupProfileDetailsPageWidget(
            groupConversationId: params.getParam(
              'groupConversationId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: AddbynumberWidget.routeName,
          path: AddbynumberWidget.routePath,
          builder: (context, params) => AddbynumberWidget(),
        ),
        FFRoute(
          name: SavedcontactWidget.routeName,
          path: SavedcontactWidget.routePath,
          builder: (context, params) => SavedcontactWidget(
            savedName: params.getParam(
              'savedName',
              ParamType.String,
            ),
            phoneOrUsername: params.getParam(
              'phoneOrUsername',
              ParamType.String,
            ),
            contactUserId: params.getParam(
              'contactUserId',
              ParamType.String,
            ),
            matchedAvatarUrl: params.getParam(
              'matchedAvatarUrl',
              ParamType.String,
            ),
            matchedFullName: params.getParam(
              'matchedFullName',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: AddbyuserNameWidget.routeName,
          path: AddbyuserNameWidget.routePath,
          builder: (context, params) => AddbyuserNameWidget(),
        ),
        FFRoute(
          name: BynumberorusersnameWidget.routeName,
          path: BynumberorusersnameWidget.routePath,
          builder: (context, params) => BynumberorusersnameWidget(),
        ),
        FFRoute(
          name: UserProfileWidget.routeName,
          path: UserProfileWidget.routePath,
          builder: (context, params) => UserProfileWidget(
            otherUserId: params.getParam(
              'otherUserId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: MediaLinksFileWidget.routeName,
          path: MediaLinksFileWidget.routePath,
          builder: (context, params) => MediaLinksFileWidget(
            conversationId: params.getParam(
              'conversationId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: GroupsInCommonWidget.routeName,
          path: GroupsInCommonWidget.routePath,
          builder: (context, params) => GroupsInCommonWidget(
            otherUserId: params.getParam(
              'otherUserId',
              ParamType.String,
            ),
            otherUserName: params.getParam(
              'otherUserName',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: GroupChatpageWidget.routeName,
          path: GroupChatpageWidget.routePath,
          builder: (context, params) => GroupChatpageWidget(
            groupConversationId: params.getParam(
              'groupConversationId',
              ParamType.String,
            ),
            groupNameParam: params.getParam(
              'groupNameParam',
              ParamType.String,
            ),
            groupAvatarParam: params.getParam(
              'groupAvatarParam',
              ParamType.String,
            ),
            displayName: params.getParam(
              'displayName',
              ParamType.String,
            ),
            conversationId: params.getParam(
              'conversationId',
              ParamType.String,
            ),
            displayAvatar: params.getParam(
              'displayAvatar',
              ParamType.String,
            ),
            initialTargetMessageId: params.getParam(
              'initialTargetMessageId',
              ParamType.String,
            ),
            startSearch: params.getParam(
              'startSearch',
              ParamType.bool,
            ),
          ),
        ),
        FFRoute(
          name: GiftcardpurchaseWidget.routeName,
          path: GiftcardpurchaseWidget.routePath,
          builder: (context, params) => GiftcardpurchaseWidget(
            productJson: params.getParam(
              'productJson',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: DataWidget.routeName,
          path: DataWidget.routePath,
          builder: (context, params) => DataWidget(),
        ),
        FFRoute(
          name: TransactionDetailsWidget.routeName,
          path: TransactionDetailsWidget.routePath,
          builder: (context, params) => TransactionDetailsWidget(
            transactionId: params.getParam(
              'transactionId',
              ParamType.String,
            ),
            amount: params.getParam(
              'amount',
              ParamType.double,
            ),
            operatorName: params.getParam(
              'operatorName',
              ParamType.String,
            ),
            recipientPhone: params.getParam(
              'recipientPhone',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: QrcodeWidget.routeName,
          path: QrcodeWidget.routePath,
          builder: (context, params) => QrcodeWidget(),
        ),
        FFRoute(
          name: SchatzAppWebLoginWidget.routeName,
          path: SchatzAppWebLoginWidget.routePath,
          builder: (context, params) => SchatzAppWebLoginWidget(),
        ),
        FFRoute(
          name: PhoneLoginWidget.routeName,
          path: PhoneLoginWidget.routePath,
          builder: (context, params) => PhoneLoginWidget(),
        ),
        FFRoute(
          name: VerifyMobileNumberWidget.routeName,
          path: VerifyMobileNumberWidget.routePath,
          builder: (context, params) => VerifyMobileNumberWidget(
            phoneNumber: params.getParam(
              'phoneNumber',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: NeedHelpLogingInWidget.routeName,
          path: NeedHelpLogingInWidget.routePath,
          builder: (context, params) => NeedHelpLogingInWidget(),
        ),
        FFRoute(
          name: PrivacyWidget.routeName,
          path: PrivacyWidget.routePath,
          builder: (context, params) => PrivacyWidget(),
        ),
        FFRoute(
          name: SplashScreenWidget.routeName,
          path: SplashScreenWidget.routePath,
          builder: (context, params) => SplashScreenWidget(),
        ),
        FFRoute(
          name: AllNotificationsWidget.routeName,
          path: AllNotificationsWidget.routePath,
          builder: (context, params) => AllNotificationsWidget(),
        ),
        FFRoute(
          name: LisOfBlockedUsersWidget.routeName,
          path: LisOfBlockedUsersWidget.routePath,
          builder: (context, params) => LisOfBlockedUsersWidget(),
        ),
        FFRoute(
          name: EditImageWidget.routeName,
          path: EditImageWidget.routePath,
          builder: (context, params) => EditImageWidget(),
        ),
        FFRoute(
          name: ActiveCallScreenWidget.routeName,
          path: ActiveCallScreenWidget.routePath,
          builder: (context, params) => ActiveCallScreenWidget(
            callId: params.getParam(
              'callId',
              ParamType.String,
            ),
            conversationId: params.getParam(
              'conversationId',
              ParamType.String,
            ),
            calleeName: params.getParam(
              'calleeName',
              ParamType.String,
            ),
            calleeAvatar: params.getParam(
              'calleeAvatar',
              ParamType.String,
            ),
            callType: params.getParam(
              'callType',
              ParamType.String,
            ),
            agoraChannelName: params.getParam(
              'agoraChannelName',
              ParamType.String,
            ),
            agoraToken: params.getParam(
              'agoraToken',
              ParamType.String,
            ),
            agoraUid: params.getParam(
              'agoraUid',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: ConnectedCallScreenWidget.routeName,
          path: ConnectedCallScreenWidget.routePath,
          builder: (context, params) => ConnectedCallScreenWidget(
            callId: params.getParam(
              'callId',
              ParamType.String,
            ),
            conversationId: params.getParam(
              'conversationId',
              ParamType.String,
            ),
            otherUserName: params.getParam(
              'otherUserName',
              ParamType.String,
            ),
            otherUserAvatar: params.getParam(
              'otherUserAvatar',
              ParamType.String,
            ),
            callType: params.getParam(
              'callType',
              ParamType.String,
            ),
            agoraChannelName: params.getParam(
              'agoraChannelName',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: ServerWidget.routeName,
          path: ServerWidget.routePath,
          builder: (context, params) => ServerWidget(),
        ),
        FFRoute(
          name: ViewYourStoriesWidget.routeName,
          path: ViewYourStoriesWidget.routePath,
          builder: (context, params) => ViewYourStoriesWidget(
            storyGroup: params.getParam(
              'storyGroup',
              ParamType.DataStruct,
              isList: false,
              structBuilder: StoryGroupStruct.fromSerializableMap,
            ),
          ),
        ),
        FFRoute(
          name: CreateAStoryWidget.routeName,
          path: CreateAStoryWidget.routePath,
          builder: (context, params) => CreateAStoryWidget(
            mediaUrl: params.getParam(
              'mediaUrl',
              ParamType.String,
            ),
            mediaType: params.getParam(
              'mediaType',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: UsersStoryWidget.routeName,
          path: UsersStoryWidget.routePath,
          builder: (context, params) => UsersStoryWidget(
            storyGroups: params.getParam<StoryGroupStruct>(
              'storyGroups',
              ParamType.DataStruct,
              isList: true,
              structBuilder: StoryGroupStruct.fromSerializableMap,
            ),
            groupIndex: params.getParam(
              'groupIndex',
              ParamType.int,
            ),
            currentUserId: params.getParam(
              'currentUserId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: FullstoryViewWidget.routeName,
          path: FullstoryViewWidget.routePath,
          builder: (context, params) => FullstoryViewWidget(
            startIndex: params.getParam(
              'startIndex',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: EditPostImageWidget.routeName,
          path: EditPostImageWidget.routePath,
          builder: (context, params) => EditPostImageWidget(),
        ),
        FFRoute(
          name: WriteStoryWidget.routeName,
          path: WriteStoryWidget.routePath,
          builder: (context, params) => WriteStoryWidget(),
        ),
        FFRoute(
          name: CallSearchWidget.routeName,
          path: CallSearchWidget.routePath,
          builder: (context, params) => CallSearchWidget(),
        ),
        FFRoute(
          name: ChatSearchWidget.routeName,
          path: ChatSearchWidget.routePath,
          builder: (context, params) => ChatSearchWidget(),
        ),
        FFRoute(
          name: StorySettingsWidget.routeName,
          path: StorySettingsWidget.routePath,
          builder: (context, params) => StorySettingsWidget(),
        ),
        FFRoute(
          name: LanguageSeletorWidget.routeName,
          path: LanguageSeletorWidget.routePath,
          builder: (context, params) => LanguageSeletorWidget(),
        ),
        FFRoute(
          name: RedeemYourSchatzGiftcardWidget.routeName,
          path: RedeemYourSchatzGiftcardWidget.routePath,
          builder: (context, params) => RedeemYourSchatzGiftcardWidget(),
        ),
        FFRoute(
          name: ImportantPagesListWidget.routeName,
          path: ImportantPagesListWidget.routePath,
          builder: (context, params) => ImportantPagesListWidget(
            conversationId: params.getParam(
              'conversationId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: LinkADeviceWidget.routeName,
          path: LinkADeviceWidget.routePath,
          builder: (context, params) => LinkADeviceWidget(),
        ),
        FFRoute(
          name: WhocanseemynumberWidget.routeName,
          path: WhocanseemynumberWidget.routePath,
          builder: (context, params) => WhocanseemynumberWidget(),
        ),
        FFRoute(
          name: NotificationWidget.routeName,
          path: NotificationWidget.routePath,
          builder: (context, params) => NotificationWidget(),
        ),
        FFRoute(
          name: ProfileWidget.routeName,
          path: ProfileWidget.routePath,
          builder: (context, params) => ProfileWidget(),
        ),
        FFRoute(
          name: BioChangingPageWidget.routeName,
          path: BioChangingPageWidget.routePath,
          builder: (context, params) => BioChangingPageWidget(),
        ),
        FFRoute(
          name: EditNamePageWidget.routeName,
          path: EditNamePageWidget.routePath,
          builder: (context, params) => EditNamePageWidget(),
        ),
        FFRoute(
          name: AddLinkPageWidget.routeName,
          path: AddLinkPageWidget.routePath,
          builder: (context, params) => AddLinkPageWidget(),
        ),
        FFRoute(
          name: HelpSupportWidget.routeName,
          path: HelpSupportWidget.routePath,
          builder: (context, params) => HelpSupportWidget(),
        ),
        FFRoute(
          name: SecurityWidget.routeName,
          path: SecurityWidget.routePath,
          builder: (context, params) => SecurityWidget(),
        ),
        FFRoute(
          name: DeleteAccountWidget.routeName,
          path: DeleteAccountWidget.routePath,
          builder: (context, params) => DeleteAccountWidget(),
        ),
        FFRoute(
          name: ForYouDummyTestWidget.routeName,
          path: ForYouDummyTestWidget.routePath,
          builder: (context, params) => ForYouDummyTestWidget(),
        ),
        FFRoute(
          name: LockchatWidget.routeName,
          path: LockchatWidget.routePath,
          builder: (context, params) => LockchatWidget(),
        ),
        FFRoute(
          name: UsernameChangingPageWidget.routeName,
          path: UsernameChangingPageWidget.routePath,
          builder: (context, params) => UsernameChangingPageWidget(),
        ),
        FFRoute(
          name: CamouflageMessageWidget.routeName,
          path: CamouflageMessageWidget.routePath,
          builder: (context, params) => CamouflageMessageWidget(),
        ),
        FFRoute(
          name: CamouflageProfileWidget.routeName,
          path: CamouflageProfileWidget.routePath,
          builder: (context, params) => CamouflageProfileWidget(),
        ),
        FFRoute(
          name: LockChatPrivacyWidget.routeName,
          path: LockChatPrivacyWidget.routePath,
          builder: (context, params) => LockChatPrivacyWidget(),
        ),
        FFRoute(
          name: SetAppPasswordWidget.routeName,
          path: SetAppPasswordWidget.routePath,
          builder: (context, params) => SetAppPasswordWidget(),
        ),
        FFRoute(
          name: ChangeAppPassowrdWidget.routeName,
          path: ChangeAppPassowrdWidget.routePath,
          builder: (context, params) => ChangeAppPassowrdWidget(),
        ),
        FFRoute(
          name: SeeAllWalletTransactionsWidget.routeName,
          path: SeeAllWalletTransactionsWidget.routePath,
          builder: (context, params) => SeeAllWalletTransactionsWidget(),
        ),
        FFRoute(
          name: AddCardWidget.routeName,
          path: AddCardWidget.routePath,
          builder: (context, params) => AddCardWidget(),
        ),
        FFRoute(
          name: DonationPageWidget.routeName,
          path: DonationPageWidget.routePath,
          builder: (context, params) => DonationPageWidget(),
        ),
        FFRoute(
          name: WalletStartVerifyWidget.routeName,
          path: WalletStartVerifyWidget.routePath,
          builder: (context, params) => WalletStartVerifyWidget(),
        ),
        FFRoute(
          name: WalletStartFaceVerify4Widget.routeName,
          path: WalletStartFaceVerify4Widget.routePath,
          builder: (context, params) => WalletStartFaceVerify4Widget(),
        ),
        FFRoute(
          name: WalletStart1VerifyWidget.routeName,
          path: WalletStart1VerifyWidget.routePath,
          builder: (context, params) => WalletStart1VerifyWidget(),
        ),
        FFRoute(
          name: WalletStart2VerifyWidget.routeName,
          path: WalletStart2VerifyWidget.routePath,
          builder: (context, params) => WalletStart2VerifyWidget(),
        ),
        FFRoute(
          name: WalletStart3VerifyWidget.routeName,
          path: WalletStart3VerifyWidget.routePath,
          builder: (context, params) => WalletStart3VerifyWidget(),
        ),
        FFRoute(
          name: WalletStartKYCReviewWidget.routeName,
          path: WalletStartKYCReviewWidget.routePath,
          builder: (context, params) => WalletStartKYCReviewWidget(),
        ),
        FFRoute(
          name: WalletVerifyCompletedWidget.routeName,
          path: WalletVerifyCompletedWidget.routePath,
          builder: (context, params) => WalletVerifyCompletedWidget(),
        ),
        FFRoute(
          name: WalletVerifyFailWidget.routeName,
          path: WalletVerifyFailWidget.routePath,
          builder: (context, params) => WalletVerifyFailWidget(),
        ),
        FFRoute(
          name: WalletProfileWidget.routeName,
          path: WalletProfileWidget.routePath,
          builder: (context, params) => WalletProfileWidget(),
        ),
        FFRoute(
          name: PersonalInformationWidget.routeName,
          path: PersonalInformationWidget.routePath,
          builder: (context, params) => PersonalInformationWidget(),
        ),
        FFRoute(
          name: AccountLimitsWidget.routeName,
          path: AccountLimitsWidget.routePath,
          builder: (context, params) => AccountLimitsWidget(),
        ),
        FFRoute(
          name: HelpSupportPWidget.routeName,
          path: HelpSupportPWidget.routePath,
          builder: (context, params) => HelpSupportPWidget(),
        ),
        FFRoute(
          name: WalletPendingVerifyWidget.routeName,
          path: WalletPendingVerifyWidget.routePath,
          builder: (context, params) => WalletPendingVerifyWidget(),
        ),
        FFRoute(
          name: BuySchatzGiftcardWidget.routeName,
          path: BuySchatzGiftcardWidget.routePath,
          builder: (context, params) => BuySchatzGiftcardWidget(),
        ),
        FFRoute(
          name: StatementDownloadWidget.routeName,
          path: StatementDownloadWidget.routePath,
          builder: (context, params) => StatementDownloadWidget(),
        ),
        FFRoute(
          name: SetPINWidget.routeName,
          path: SetPINWidget.routePath,
          builder: (context, params) => SetPINWidget(),
        ),
        FFRoute(
          name: SetPINConfirmWidget.routeName,
          path: SetPINConfirmWidget.routePath,
          builder: (context, params) => SetPINConfirmWidget(
            firstPin: params.getParam(
              'firstPin',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: ResetPIN1Widget.routeName,
          path: ResetPIN1Widget.routePath,
          builder: (context, params) => ResetPIN1Widget(),
        ),
        FFRoute(
          name: ResetPIN2Widget.routeName,
          path: ResetPIN2Widget.routePath,
          builder: (context, params) => ResetPIN2Widget(
            resetEmail: params.getParam(
              'resetEmail',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: ResetPIN3Widget.routeName,
          path: ResetPIN3Widget.routePath,
          builder: (context, params) => ResetPIN3Widget(),
        ),
        FFRoute(
          name: ResetPIN4Widget.routeName,
          path: ResetPIN4Widget.routePath,
          builder: (context, params) => ResetPIN4Widget(
            resetToken: params.getParam(
              'resetToken',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: GiftCardchatviewWidget.routeName,
          path: GiftCardchatviewWidget.routePath,
          builder: (context, params) => GiftCardchatviewWidget(),
        ),
        FFRoute(
          name: MediaQualityWidget.routeName,
          path: MediaQualityWidget.routePath,
          builder: (context, params) => MediaQualityWidget(),
        ),
        FFRoute(
          name: ScheduledCallsWidget.routeName,
          path: ScheduledCallsWidget.routePath,
          builder: (context, params) => ScheduledCallsWidget(),
        ),
        FFRoute(
          name: JoincallWidget.routeName,
          path: JoincallWidget.routePath,
          builder: (context, params) => JoincallWidget(
            code: params.getParam(
              'code',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: GroupMembersPageWidget.routeName,
          path: GroupMembersPageWidget.routePath,
          builder: (context, params) => GroupMembersPageWidget(
            groupConversationId: params.getParam(
              'groupConversationId',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: JoinGroupPageWidget.routeName,
          path: JoinGroupPageWidget.routePath,
          builder: (context, params) => JoinGroupPageWidget(
            code: params.getParam(
              'code',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: PrivateChatWidget.routeName,
          path: PrivateChatWidget.routePath,
          builder: (context, params) => PrivateChatWidget(),
        )
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    StructBuilder<T>? structBuilder,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      structBuilder: structBuilder,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/splashScreen';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Image.asset(
                      'assets/images/WhatsApp_Image_2026-08-20_at_6.28.58_PM-removebg-preview.png',
                      height: 110.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  name: state.name,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    curve: transitionInfo.transitionType ==
                            PageTransitionType.scale
                        ? const Interval(0.0, 0.5)
                        : Curves.linear,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey, name: state.name, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
