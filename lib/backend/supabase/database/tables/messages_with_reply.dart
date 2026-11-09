import '../database.dart';

class MessagesWithReplyTable extends SupabaseTable<MessagesWithReplyRow> {
  @override
  String get tableName => 'messages_with_reply';

  @override
  MessagesWithReplyRow createRow(Map<String, dynamic> data) =>
      MessagesWithReplyRow(data);
}

class MessagesWithReplyRow extends SupabaseDataRow {
  MessagesWithReplyRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MessagesWithReplyTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get conversationId => getField<String>('conversation_id');
  set conversationId(String? value) =>
      setField<String>('conversation_id', value);

  String? get senderId => getField<String>('sender_id');
  set senderId(String? value) => setField<String>('sender_id', value);

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

  String? get replyToMessageType => getField<String>('reply_to_message_type');
  set replyToMessageType(String? value) =>
      setField<String>('reply_to_message_type', value);

  String? get replyToSenderId => getField<String>('reply_to_sender_id');
  set replyToSenderId(String? value) =>
      setField<String>('reply_to_sender_id', value);
}
