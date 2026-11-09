import '../database.dart';

class SupportedCountriesTable extends SupabaseTable<SupportedCountriesRow> {
  @override
  String get tableName => 'supported_countries';

  @override
  SupportedCountriesRow createRow(Map<String, dynamic> data) =>
      SupportedCountriesRow(data);
}

class SupportedCountriesRow extends SupabaseDataRow {
  SupportedCountriesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SupportedCountriesTable();

  String get isoCode => getField<String>('iso_code')!;
  set isoCode(String value) => setField<String>('iso_code', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String get dialCode => getField<String>('dial_code')!;
  set dialCode(String value) => setField<String>('dial_code', value);

  String get currencyCode => getField<String>('currency_code')!;
  set currencyCode(String value) => setField<String>('currency_code', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
