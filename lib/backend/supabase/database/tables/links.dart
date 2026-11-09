import '../database.dart';

class LinksTable extends SupabaseTable<LinksRow> {
  @override
  String get tableName => 'links';

  @override
  LinksRow createRow(Map<String, dynamic> data) => LinksRow(data);
}

class LinksRow extends SupabaseDataRow {
  LinksRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LinksTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String get url => getField<String>('url')!;
  set url(String value) => setField<String>('url', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
