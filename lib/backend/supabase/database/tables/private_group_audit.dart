import '../database.dart';

class PrivateGroupAuditTable extends SupabaseTable<PrivateGroupAuditRow> {
  @override
  String get tableName => 'private_group_audit';

  @override
  PrivateGroupAuditRow createRow(Map<String, dynamic> data) =>
      PrivateGroupAuditRow(data);
}

class PrivateGroupAuditRow extends SupabaseDataRow {
  PrivateGroupAuditRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PrivateGroupAuditTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get conversationId => getField<String>('conversation_id');
  set conversationId(String? value) =>
      setField<String>('conversation_id', value);

  String? get actorId => getField<String>('actor_id');
  set actorId(String? value) => setField<String>('actor_id', value);

  String get action => getField<String>('action')!;
  set action(String value) => setField<String>('action', value);

  String? get origin => getField<String>('origin');
  set origin(String? value) => setField<String>('origin', value);

  int? get deletedMessages => getField<int>('deleted_messages');
  set deletedMessages(int? value) => setField<int>('deleted_messages', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
