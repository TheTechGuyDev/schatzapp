import '../database.dart';

class ChatListViewTable extends SupabaseTable<ChatListViewRow> {
  @override
  String get tableName => 'chat_list_view';

  @override
  ChatListViewRow createRow(Map<String, dynamic> data) => ChatListViewRow(data);
}

class ChatListViewRow extends SupabaseDataRow {
  ChatListViewRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ChatListViewTable();

  String? get conversationId => getField<String>('conversation_id');
  set conversationId(String? value) =>
      setField<String>('conversation_id', value);

  String? get type => getField<String>('type');
  set type(String? value) => setField<String>('type', value);

  String? get viewerId => getField<String>('viewer_id');
  set viewerId(String? value) => setField<String>('viewer_id', value);

  String? get displayName => getField<String>('display_name');
  set displayName(String? value) => setField<String>('display_name', value);

  String? get displayAvatar => getField<String>('display_avatar');
  set displayAvatar(String? value) => setField<String>('display_avatar', value);

  bool? get isOnline => getField<bool>('is_online');
  set isOnline(bool? value) => setField<bool>('is_online', value);

  String? get lastMessageContent => getField<String>('last_message_content');
  set lastMessageContent(String? value) =>
      setField<String>('last_message_content', value);

  String? get lastMessageType => getField<String>('last_message_type');
  set lastMessageType(String? value) =>
      setField<String>('last_message_type', value);

  String? get lastMessageSenderId => getField<String>('last_message_sender_id');
  set lastMessageSenderId(String? value) =>
      setField<String>('last_message_sender_id', value);

  DateTime? get lastMessageAt => getField<DateTime>('last_message_at');
  set lastMessageAt(DateTime? value) =>
      setField<DateTime>('last_message_at', value);

  bool? get isMuted => getField<bool>('is_muted');
  set isMuted(bool? value) => setField<bool>('is_muted', value);

  bool? get isArchived => getField<bool>('is_archived');
  set isArchived(bool? value) => setField<bool>('is_archived', value);

  bool? get isPinned => getField<bool>('is_pinned');
  set isPinned(bool? value) => setField<bool>('is_pinned', value);

  int? get unreadCount => getField<int>('unread_count');
  set unreadCount(int? value) => setField<int>('unread_count', value);

  String? get otherUserId => getField<String>('other_user_id');
  set otherUserId(String? value) => setField<String>('other_user_id', value);

  DateTime? get leftAt => getField<DateTime>('left_at');
  set leftAt(DateTime? value) => setField<DateTime>('left_at', value);

  bool? get isLocked => getField<bool>('is_locked');
  set isLocked(bool? value) => setField<bool>('is_locked', value);
}
