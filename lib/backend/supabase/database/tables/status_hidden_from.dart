import '../database.dart';

class StatusHiddenFromTable extends SupabaseTable<StatusHiddenFromRow> {
  @override
  String get tableName => 'status_hidden_from';

  @override
  StatusHiddenFromRow createRow(Map<String, dynamic> data) =>
      StatusHiddenFromRow(data);
}

class StatusHiddenFromRow extends SupabaseDataRow {
  StatusHiddenFromRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StatusHiddenFromTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get ownerId => getField<String>('owner_id')!;
  set ownerId(String value) => setField<String>('owner_id', value);

  String get hiddenUserId => getField<String>('hidden_user_id')!;
  set hiddenUserId(String value) => setField<String>('hidden_user_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
