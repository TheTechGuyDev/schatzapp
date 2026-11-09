import '../database.dart';

class StatusViewsTable extends SupabaseTable<StatusViewsRow> {
  @override
  String get tableName => 'status_views';

  @override
  StatusViewsRow createRow(Map<String, dynamic> data) => StatusViewsRow(data);
}

class StatusViewsRow extends SupabaseDataRow {
  StatusViewsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StatusViewsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get statusId => getField<String>('status_id')!;
  set statusId(String value) => setField<String>('status_id', value);

  String get viewerId => getField<String>('viewer_id')!;
  set viewerId(String value) => setField<String>('viewer_id', value);

  DateTime? get viewedAt => getField<DateTime>('viewed_at');
  set viewedAt(DateTime? value) => setField<DateTime>('viewed_at', value);
}
