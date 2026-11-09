import '../database.dart';

class MessagesTable extends SupabaseTable<MessagesRow> {
  @override
  String get tableName => 'messages';

  @override
  MessagesRow createRow(Map<String, dynamic> data) => MessagesRow(data);
}

class MessagesRow extends SupabaseDataRow {
  MessagesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MessagesTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get conversationId => getField<String>('conversation_id')!;
  set conversationId(String value) =>
      setField<String>('conversation_id', value);

  String get senderId => getField<String>('sender_id')!;
  set senderId(String value) => setField<String>('sender_id', value);

  String? get messageType => getField<String>('message_type');
  set messageType(String? value) => setField<String>('message_type', value);

  String? get content => getField<String>('content');
  set content(String? value) => setField<String>('content', value);

  String? get mediaUrl => getField<String>('media_url');
  set mediaUrl(String? value) => setField<String>('media_url', value);

  int? get mediaSizeBytes => getField<int>('media_size_bytes');
  set mediaSizeBytes(int? value) => setField<int>('media_size_bytes', value);

  int? get mediaDurationSeconds => getField<int>('media_duration_seconds');
  set mediaDurationSeconds(int? value) =>
      setField<int>('media_duration_seconds', value);

  String? get thumbnailUrl => getField<String>('thumbnail_url');
  set thumbnailUrl(String? value) => setField<String>('thumbnail_url', value);

  String? get replyToMessageId => getField<String>('reply_to_message_id');
  set replyToMessageId(String? value) =>
      setField<String>('reply_to_message_id', value);

  bool? get isEdited => getField<bool>('is_edited');
  set isEdited(bool? value) => setField<bool>('is_edited', value);

  bool? get isDeleted => getField<bool>('is_deleted');
  set isDeleted(bool? value) => setField<bool>('is_deleted', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  bool? get isPinned => getField<bool>('is_pinned');
  set isPinned(bool? value) => setField<bool>('is_pinned', value);

  bool? get isImportant => getField<bool>('is_important');
  set isImportant(bool? value) => setField<bool>('is_important', value);

  String? get replyToContent => getField<String>('reply_to_content');
  set replyToContent(String? value) =>
      setField<String>('reply_to_content', value);

  bool? get replyToIsOwn => getField<bool>('reply_to_is_own');
  set replyToIsOwn(bool? value) => setField<bool>('reply_to_is_own', value);

  int? get durationSeconds => getField<int>('duration_seconds');
  set durationSeconds(int? value) => setField<int>('duration_seconds', value);

  List<String> get mediaUrls => getListField<String>('media_urls');
  set mediaUrls(List<String>? value) =>
      setListField<String>('media_urls', value);

  bool? get isForwarded => getField<bool>('is_forwarded');
  set isForwarded(bool? value) => setField<bool>('is_forwarded', value);

  List<String> get deletedForUserIds =>
      getListField<String>('deleted_for_user_ids');
  set deletedForUserIds(List<String>? value) =>
      setListField<String>('deleted_for_user_ids', value);

  String? get replyToStatusId => getField<String>('reply_to_status_id');
  set replyToStatusId(String? value) =>
      setField<String>('reply_to_status_id', value);

  String? get replyToStatusMediaUrl =>
      getField<String>('reply_to_status_media_url');
  set replyToStatusMediaUrl(String? value) =>
      setField<String>('reply_to_status_media_url', value);

  String? get replyToStatusMediaType =>
      getField<String>('reply_to_status_media_type');
  set replyToStatusMediaType(String? value) =>
      setField<String>('reply_to_status_media_type', value);

  int? get mediaPages => getField<int>('media_pages');
  set mediaPages(int? value) => setField<int>('media_pages', value);
}
