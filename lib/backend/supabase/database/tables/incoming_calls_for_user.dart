import '../database.dart';

class IncomingCallsForUserTable extends SupabaseTable<IncomingCallsForUserRow> {
  @override
  String get tableName => 'incoming_calls_for_user';

  @override
  IncomingCallsForUserRow createRow(Map<String, dynamic> data) =>
      IncomingCallsForUserRow(data);
}

class IncomingCallsForUserRow extends SupabaseDataRow {
  IncomingCallsForUserRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => IncomingCallsForUserTable();

  String? get callId => getField<String>('call_id');
  set callId(String? value) => setField<String>('call_id', value);

  String? get conversationId => getField<String>('conversation_id');
  set conversationId(String? value) =>
      setField<String>('conversation_id', value);

  String? get callerId => getField<String>('caller_id');
  set callerId(String? value) => setField<String>('caller_id', value);

  String? get callType => getField<String>('call_type');
  set callType(String? value) => setField<String>('call_type', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get startedAt => getField<DateTime>('started_at');
  set startedAt(DateTime? value) => setField<DateTime>('started_at', value);

  String? get callerName => getField<String>('caller_name');
  set callerName(String? value) => setField<String>('caller_name', value);

  String? get callerAvatar => getField<String>('caller_avatar');
  set callerAvatar(String? value) => setField<String>('caller_avatar', value);
}
