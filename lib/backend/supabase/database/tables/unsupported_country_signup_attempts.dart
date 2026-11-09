import '../database.dart';

class UnsupportedCountrySignupAttemptsTable
    extends SupabaseTable<UnsupportedCountrySignupAttemptsRow> {
  @override
  String get tableName => 'unsupported_country_signup_attempts';

  @override
  UnsupportedCountrySignupAttemptsRow createRow(Map<String, dynamic> data) =>
      UnsupportedCountrySignupAttemptsRow(data);
}

class UnsupportedCountrySignupAttemptsRow extends SupabaseDataRow {
  UnsupportedCountrySignupAttemptsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UnsupportedCountrySignupAttemptsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get attemptedDialCode => getField<String>('attempted_dial_code');
  set attemptedDialCode(String? value) =>
      setField<String>('attempted_dial_code', value);

  String? get attemptedPhoneNumber =>
      getField<String>('attempted_phone_number');
  set attemptedPhoneNumber(String? value) =>
      setField<String>('attempted_phone_number', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
