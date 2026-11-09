import '../database.dart';

class NameChangeRequestsTable extends SupabaseTable<NameChangeRequestsRow> {
  @override
  String get tableName => 'name_change_requests';

  @override
  NameChangeRequestsRow createRow(Map<String, dynamic> data) =>
      NameChangeRequestsRow(data);
}

class NameChangeRequestsRow extends SupabaseDataRow {
  NameChangeRequestsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => NameChangeRequestsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get currentName => getField<String>('current_name')!;
  set currentName(String value) => setField<String>('current_name', value);

  String get requestedName => getField<String>('requested_name')!;
  set requestedName(String value) => setField<String>('requested_name', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get adminNote => getField<String>('admin_note');
  set adminNote(String? value) => setField<String>('admin_note', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get reviewedAt => getField<DateTime>('reviewed_at');
  set reviewedAt(DateTime? value) => setField<DateTime>('reviewed_at', value);

  String? get reviewedBy => getField<String>('reviewed_by');
  set reviewedBy(String? value) => setField<String>('reviewed_by', value);
}
