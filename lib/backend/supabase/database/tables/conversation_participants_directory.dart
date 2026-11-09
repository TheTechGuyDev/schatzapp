import '../database.dart';

class ConversationParticipantsDirectoryTable
    extends SupabaseTable<ConversationParticipantsDirectoryRow> {
  @override
  String get tableName => 'conversation_participants_directory';

  @override
  ConversationParticipantsDirectoryRow createRow(Map<String, dynamic> data) =>
      ConversationParticipantsDirectoryRow(data);
}

class ConversationParticipantsDirectoryRow extends SupabaseDataRow {
  ConversationParticipantsDirectoryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ConversationParticipantsDirectoryTable();

  String? get participantId => getField<String>('participant_id');
  set participantId(String? value) => setField<String>('participant_id', value);

  String? get conversationId => getField<String>('conversation_id');
  set conversationId(String? value) =>
      setField<String>('conversation_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get role => getField<String>('role');
  set role(String? value) => setField<String>('role', value);

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  String? get avatarUrl => getField<String>('avatar_url');
  set avatarUrl(String? value) => setField<String>('avatar_url', value);
}
