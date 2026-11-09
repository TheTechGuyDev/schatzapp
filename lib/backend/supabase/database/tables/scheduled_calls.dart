import '../database.dart';

class ScheduledCallsTable extends SupabaseTable<ScheduledCallsRow> {
  @override
  String get tableName => 'scheduled_calls';

  @override
  ScheduledCallsRow createRow(Map<String, dynamic> data) =>
      ScheduledCallsRow(data);
}

class ScheduledCallsRow extends SupabaseDataRow {
  ScheduledCallsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ScheduledCallsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get conversationId => getField<String>('conversation_id')!;
  set conversationId(String value) =>
      setField<String>('conversation_id', value);

  String get creatorId => getField<String>('creator_id')!;
  set creatorId(String value) => setField<String>('creator_id', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String? get callType => getField<String>('call_type');
  set callType(String? value) => setField<String>('call_type', value);

  DateTime get scheduledAt => getField<DateTime>('scheduled_at')!;
  set scheduledAt(DateTime value) => setField<DateTime>('scheduled_at', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
