import '../database.dart';

class ActiveIncomingCallsTable extends SupabaseTable<ActiveIncomingCallsRow> {
  @override
  String get tableName => 'active_incoming_calls';

  @override
  ActiveIncomingCallsRow createRow(Map<String, dynamic> data) =>
      ActiveIncomingCallsRow(data);
}

class ActiveIncomingCallsRow extends SupabaseDataRow {
  ActiveIncomingCallsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ActiveIncomingCallsTable();

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String? get callId => getField<String>('call_id');
  set callId(String? value) => setField<String>('call_id', value);

  String? get conversationId => getField<String>('conversation_id');
  set conversationId(String? value) =>
      setField<String>('conversation_id', value);

  String? get callerId => getField<String>('caller_id');
  set callerId(String? value) => setField<String>('caller_id', value);

  String? get callerName => getField<String>('caller_name');
  set callerName(String? value) => setField<String>('caller_name', value);

  String? get callerAvatar => getField<String>('caller_avatar');
  set callerAvatar(String? value) => setField<String>('caller_avatar', value);

  String? get callType => getField<String>('call_type');
  set callType(String? value) => setField<String>('call_type', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get agoraChannelName => getField<String>('agora_channel_name');
  set agoraChannelName(String? value) =>
      setField<String>('agora_channel_name', value);
}
