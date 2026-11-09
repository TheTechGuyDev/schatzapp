import '../database.dart';

class MessageStatusTable extends SupabaseTable<MessageStatusRow> {
  @override
  String get tableName => 'message_status';

  @override
  MessageStatusRow createRow(Map<String, dynamic> data) =>
      MessageStatusRow(data);
}

class MessageStatusRow extends SupabaseDataRow {
  MessageStatusRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MessageStatusTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get messageId => getField<String>('message_id')!;
  set messageId(String value) => setField<String>('message_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get statusAt => getField<DateTime>('status_at');
  set statusAt(DateTime? value) => setField<DateTime>('status_at', value);
}
