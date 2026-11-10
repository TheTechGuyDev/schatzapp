import '../database.dart';

class ConversationParticipantsTable
    extends SupabaseTable<ConversationParticipantsRow> {
  @override
  String get tableName => 'conversation_participants';

  @override
  ConversationParticipantsRow createRow(Map<String, dynamic> data) =>
      ConversationParticipantsRow(data);
}

class ConversationParticipantsRow extends SupabaseDataRow {
  ConversationParticipantsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ConversationParticipantsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get conversationId => getField<String>('conversation_id')!;
  set conversationId(String value) =>
      setField<String>('conversation_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String? get role => getField<String>('role');
  set role(String? value) => setField<String>('role', value);

  bool? get isMuted => getField<bool>('is_muted');
  set isMuted(bool? value) => setField<bool>('is_muted', value);

  DateTime? get lastReadAt => getField<DateTime>('last_read_at');
  set lastReadAt(DateTime? value) => setField<DateTime>('last_read_at', value);

  DateTime? get joinedAt => getField<DateTime>('joined_at');
  set joinedAt(DateTime? value) => setField<DateTime>('joined_at', value);

  DateTime? get leftAt => getField<DateTime>('left_at');
  set leftAt(DateTime? value) => setField<DateTime>('left_at', value);

  bool? get isArchived => getField<bool>('is_archived');
  set isArchived(bool? value) => setField<bool>('is_archived', value);

  bool? get isPinned => getField<bool>('is_pinned');
  set isPinned(bool? value) => setField<bool>('is_pinned', value);

  String? get participantKey => getField<String>('participant_key');
  set participantKey(String? value) =>
      setField<String>('participant_key', value);

  String? get chatTheme => getField<String>('chat_theme');
  set chatTheme(String? value) => setField<String>('chat_theme', value);

  String? get chatWallpaperUrl => getField<String>('chat_wallpaper_url');
  set chatWallpaperUrl(String? value) =>
      setField<String>('chat_wallpaper_url', value);

  String? get addedBy => getField<String>('added_by');
  set addedBy(String? value) => setField<String>('added_by', value);

  String? get leftBy => getField<String>('left_by');
  set leftBy(String? value) => setField<String>('left_by', value);

  bool? get privateLock => getField<bool>('private_lock');
  set privateLock(bool? value) => setField<bool>('private_lock', value);
}
