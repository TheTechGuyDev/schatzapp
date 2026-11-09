import '../database.dart';

class StatusReactionsTable extends SupabaseTable<StatusReactionsRow> {
  @override
  String get tableName => 'status_reactions';

  @override
  StatusReactionsRow createRow(Map<String, dynamic> data) =>
      StatusReactionsRow(data);
}

class StatusReactionsRow extends SupabaseDataRow {
  StatusReactionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StatusReactionsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get statusId => getField<String>('status_id')!;
  set statusId(String value) => setField<String>('status_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get reactionType => getField<String>('reaction_type')!;
  set reactionType(String value) => setField<String>('reaction_type', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
