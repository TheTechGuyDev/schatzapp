import '../database.dart';

class ProfilesTable extends SupabaseTable<ProfilesRow> {
  @override
  String get tableName => 'profiles';

  @override
  ProfilesRow createRow(Map<String, dynamic> data) => ProfilesRow(data);
}

class ProfilesRow extends SupabaseDataRow {
  ProfilesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ProfilesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get username => getField<String>('username');
  set username(String? value) => setField<String>('username', value);

  String get fullName => getField<String>('full_name')!;
  set fullName(String value) => setField<String>('full_name', value);

  String? get phoneNumber => getField<String>('phone_number');
  set phoneNumber(String? value) => setField<String>('phone_number', value);

  String? get avatarUrl => getField<String>('avatar_url');
  set avatarUrl(String? value) => setField<String>('avatar_url', value);

  String? get aboutText => getField<String>('about_text');
  set aboutText(String? value) => setField<String>('about_text', value);

  bool? get isOnline => getField<bool>('is_online');
  set isOnline(bool? value) => setField<bool>('is_online', value);

  DateTime? get lastSeenAt => getField<DateTime>('last_seen_at');
  set lastSeenAt(DateTime? value) => setField<DateTime>('last_seen_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  bool? get usernameChanged => getField<bool>('username_changed');
  set usernameChanged(bool? value) => setField<bool>('username_changed', value);

  String? get chatStatus => getField<String>('chat_status');
  set chatStatus(String? value) => setField<String>('chat_status', value);

  String? get appPasswordHash => getField<String>('app_password_hash');
  set appPasswordHash(String? value) =>
      setField<String>('app_password_hash', value);

  bool? get lockChatPrivacyEnabled =>
      getField<bool>('lock_chat_privacy_enabled');
  set lockChatPrivacyEnabled(bool? value) =>
      setField<bool>('lock_chat_privacy_enabled', value);

  bool? get offNotificationEnabled =>
      getField<bool>('off_notification_enabled');
  set offNotificationEnabled(bool? value) =>
      setField<bool>('off_notification_enabled', value);

  String? get camouflageMessage1 => getField<String>('camouflage_message_1');
  set camouflageMessage1(String? value) =>
      setField<String>('camouflage_message_1', value);

  String? get camouflageMessage2 => getField<String>('camouflage_message_2');
  set camouflageMessage2(String? value) =>
      setField<String>('camouflage_message_2', value);

  String? get camouflageMessage3 => getField<String>('camouflage_message_3');
  set camouflageMessage3(String? value) =>
      setField<String>('camouflage_message_3', value);

  bool? get pushNotificationsEnabled =>
      getField<bool>('push_notifications_enabled');
  set pushNotificationsEnabled(bool? value) =>
      setField<bool>('push_notifications_enabled', value);

  bool? get messagesNotificationsEnabled =>
      getField<bool>('messages_notifications_enabled');
  set messagesNotificationsEnabled(bool? value) =>
      setField<bool>('messages_notifications_enabled', value);

  bool? get privateChatNotificationsEnabled =>
      getField<bool>('private_chat_notifications_enabled');
  set privateChatNotificationsEnabled(bool? value) =>
      setField<bool>('private_chat_notifications_enabled', value);

  bool? get likesInteractionsNotificationsEnabled =>
      getField<bool>('likes_interactions_notifications_enabled');
  set likesInteractionsNotificationsEnabled(bool? value) =>
      setField<bool>('likes_interactions_notifications_enabled', value);

  bool? get appUpdatesNotificationsEnabled =>
      getField<bool>('app_updates_notifications_enabled');
  set appUpdatesNotificationsEnabled(bool? value) =>
      setField<bool>('app_updates_notifications_enabled', value);

  bool? get securityAlertsNotificationsEnabled =>
      getField<bool>('security_alerts_notifications_enabled');
  set securityAlertsNotificationsEnabled(bool? value) =>
      setField<bool>('security_alerts_notifications_enabled', value);

  bool? get doNotDisturbEnabled => getField<bool>('do_not_disturb_enabled');
  set doNotDisturbEnabled(bool? value) =>
      setField<bool>('do_not_disturb_enabled', value);

  bool? get dealsOffersNotificationsEnabled =>
      getField<bool>('deals_offers_notifications_enabled');
  set dealsOffersNotificationsEnabled(bool? value) =>
      setField<bool>('deals_offers_notifications_enabled', value);

  DateTime? get callsSeenAt => getField<DateTime>('calls_seen_at');
  set callsSeenAt(DateTime? value) =>
      setField<DateTime>('calls_seen_at', value);

  DateTime? get walletSeenAt => getField<DateTime>('wallet_seen_at');
  set walletSeenAt(DateTime? value) =>
      setField<DateTime>('wallet_seen_at', value);
}
