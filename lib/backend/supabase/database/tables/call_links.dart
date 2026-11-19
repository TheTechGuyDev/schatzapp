import '../database.dart';

class CallLinksTable extends SupabaseTable<CallLinksRow> {
  @override
  String get tableName => 'call_links';

  @override
  CallLinksRow createRow(Map<String, dynamic> data) => CallLinksRow(data);
}

class CallLinksRow extends SupabaseDataRow {
  CallLinksRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CallLinksTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get code => getField<String>('code')!;
  set code(String value) => setField<String>('code', value);

  String get callId => getField<String>('call_id')!;
  set callId(String value) => setField<String>('call_id', value);

  String get creatorId => getField<String>('creator_id')!;
  set creatorId(String value) => setField<String>('creator_id', value);

  String? get callType => getField<String>('call_type');
  set callType(String? value) => setField<String>('call_type', value);

  String get agoraChannelName => getField<String>('agora_channel_name')!;
  set agoraChannelName(String value) =>
      setField<String>('agora_channel_name', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  bool? get requiresApproval => getField<bool>('requires_approval');
  set requiresApproval(bool? value) =>
      setField<bool>('requires_approval', value);

  int? get maxParticipants => getField<int>('max_participants');
  set maxParticipants(int? value) => setField<int>('max_participants', value);

  DateTime? get expiresAt => getField<DateTime>('expires_at');
  set expiresAt(DateTime? value) => setField<DateTime>('expires_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
