import '../database.dart';

class CallsTable extends SupabaseTable<CallsRow> {
  @override
  String get tableName => 'calls';

  @override
  CallsRow createRow(Map<String, dynamic> data) => CallsRow(data);
}

class CallsRow extends SupabaseDataRow {
  CallsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CallsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get conversationId => getField<String>('conversation_id');
  set conversationId(String? value) =>
      setField<String>('conversation_id', value);

  String get callerId => getField<String>('caller_id')!;
  set callerId(String value) => setField<String>('caller_id', value);

  String? get callType => getField<String>('call_type');
  set callType(String? value) => setField<String>('call_type', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get startedAt => getField<DateTime>('started_at');
  set startedAt(DateTime? value) => setField<DateTime>('started_at', value);

  DateTime? get endedAt => getField<DateTime>('ended_at');
  set endedAt(DateTime? value) => setField<DateTime>('ended_at', value);

  int? get durationSeconds => getField<int>('duration_seconds');
  set durationSeconds(int? value) => setField<int>('duration_seconds', value);

  String? get calleeId => getField<String>('callee_id');
  set calleeId(String? value) => setField<String>('callee_id', value);

  String? get callerName => getField<String>('caller_name');
  set callerName(String? value) => setField<String>('caller_name', value);

  String? get callerAvatar => getField<String>('caller_avatar');
  set callerAvatar(String? value) => setField<String>('caller_avatar', value);

  bool? get isGroup => getField<bool>('is_group');
  set isGroup(bool? value) => setField<bool>('is_group', value);

  String? get videoRequestBy => getField<String>('video_request_by');
  set videoRequestBy(String? value) =>
      setField<String>('video_request_by', value);

  DateTime? get answeredAt => getField<DateTime>('answered_at');
  set answeredAt(DateTime? value) => setField<DateTime>('answered_at', value);

  DateTime? get endsAt => getField<DateTime>('ends_at');
  set endsAt(DateTime? value) => setField<DateTime>('ends_at', value);

  bool? get viaLink => getField<bool>('via_link');
  set viaLink(bool? value) => setField<bool>('via_link', value);

  DateTime? get aloneSince => getField<DateTime>('alone_since');
  set aloneSince(DateTime? value) => setField<DateTime>('alone_since', value);

  List<String> get invitedUserIds => getListField<String>('invited_user_ids');
  set invitedUserIds(List<String>? value) =>
      setListField<String>('invited_user_ids', value);

  String? get agoraChannelName => getField<String>('agora_channel_name');
  set agoraChannelName(String? value) =>
      setField<String>('agora_channel_name', value);
}
