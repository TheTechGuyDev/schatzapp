import '../database.dart';

class MessageStarsTable extends SupabaseTable<MessageStarsRow> {
  @override
  String get tableName => 'message_stars';

  @override
  MessageStarsRow createRow(Map<String, dynamic> data) => MessageStarsRow(data);
}

class MessageStarsRow extends SupabaseDataRow {
  MessageStarsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MessageStarsTable();

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String get messageId => getField<String>('message_id')!;
  set messageId(String value) => setField<String>('message_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
