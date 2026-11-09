import '../database.dart';

class CallParticipantsTable extends SupabaseTable<CallParticipantsRow> {
  @override
  String get tableName => 'call_participants';

  @override
  CallParticipantsRow createRow(Map<String, dynamic> data) =>
      CallParticipantsRow(data);
}

class CallParticipantsRow extends SupabaseDataRow {
  CallParticipantsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CallParticipantsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get callId => getField<String>('call_id')!;
  set callId(String value) => setField<String>('call_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  DateTime? get joinedAt => getField<DateTime>('joined_at');
  set joinedAt(DateTime? value) => setField<DateTime>('joined_at', value);

  DateTime? get leftAt => getField<DateTime>('left_at');
  set leftAt(DateTime? value) => setField<DateTime>('left_at', value);

  int? get agoraUid => getField<int>('agora_uid');
  set agoraUid(int? value) => setField<int>('agora_uid', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);
}
