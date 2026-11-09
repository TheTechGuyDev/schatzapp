import '../database.dart';

class MessageReportsTable extends SupabaseTable<MessageReportsRow> {
  @override
  String get tableName => 'message_reports';

  @override
  MessageReportsRow createRow(Map<String, dynamic> data) =>
      MessageReportsRow(data);
}

class MessageReportsRow extends SupabaseDataRow {
  MessageReportsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MessageReportsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get messageId => getField<String>('message_id')!;
  set messageId(String value) => setField<String>('message_id', value);

  String get reporterId => getField<String>('reporter_id')!;
  set reporterId(String value) => setField<String>('reporter_id', value);

  String get reportedUserId => getField<String>('reported_user_id')!;
  set reportedUserId(String value) =>
      setField<String>('reported_user_id', value);

  String get reason => getField<String>('reason')!;
  set reason(String value) => setField<String>('reason', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
