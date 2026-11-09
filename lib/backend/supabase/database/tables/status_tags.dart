import '../database.dart';

class StatusTagsTable extends SupabaseTable<StatusTagsRow> {
  @override
  String get tableName => 'status_tags';

  @override
  StatusTagsRow createRow(Map<String, dynamic> data) => StatusTagsRow(data);
}

class StatusTagsRow extends SupabaseDataRow {
  StatusTagsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StatusTagsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get statusId => getField<String>('status_id')!;
  set statusId(String value) => setField<String>('status_id', value);

  String get taggedUserId => getField<String>('tagged_user_id')!;
  set taggedUserId(String value) => setField<String>('tagged_user_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
