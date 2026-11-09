import '../database.dart';

class MessageDeletionsTable extends SupabaseTable<MessageDeletionsRow> {
  @override
  String get tableName => 'message_deletions';

  @override
  MessageDeletionsRow createRow(Map<String, dynamic> data) =>
      MessageDeletionsRow(data);
}

class MessageDeletionsRow extends SupabaseDataRow {
  MessageDeletionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MessageDeletionsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get messageId => getField<String>('message_id')!;
  set messageId(String value) => setField<String>('message_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  DateTime? get deletedAt => getField<DateTime>('deleted_at');
  set deletedAt(DateTime? value) => setField<DateTime>('deleted_at', value);
}
