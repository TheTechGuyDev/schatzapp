import '../database.dart';

class CallJoinRequestsTable extends SupabaseTable<CallJoinRequestsRow> {
  @override
  String get tableName => 'call_join_requests';

  @override
  CallJoinRequestsRow createRow(Map<String, dynamic> data) =>
      CallJoinRequestsRow(data);
}

class CallJoinRequestsRow extends SupabaseDataRow {
  CallJoinRequestsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CallJoinRequestsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get callId => getField<String>('call_id')!;
  set callId(String value) => setField<String>('call_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get decidedAt => getField<DateTime>('decided_at');
  set decidedAt(DateTime? value) => setField<DateTime>('decided_at', value);
}
