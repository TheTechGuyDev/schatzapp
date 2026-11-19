import '../database.dart';

class AppConfigTable extends SupabaseTable<AppConfigRow> {
  @override
  String get tableName => 'app_config';

  @override
  AppConfigRow createRow(Map<String, dynamic> data) => AppConfigRow(data);
}

class AppConfigRow extends SupabaseDataRow {
  AppConfigRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AppConfigTable();

  String get key => getField<String>('key')!;
  set key(String value) => setField<String>('key', value);

  String? get value => getField<String>('value');
  set value(String? value) => setField<String>('value', value);
}
