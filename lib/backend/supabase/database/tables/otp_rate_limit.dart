import '../database.dart';

class OtpRateLimitTable extends SupabaseTable<OtpRateLimitRow> {
  @override
  String get tableName => 'otp_rate_limit';

  @override
  OtpRateLimitRow createRow(Map<String, dynamic> data) => OtpRateLimitRow(data);
}

class OtpRateLimitRow extends SupabaseDataRow {
  OtpRateLimitRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => OtpRateLimitTable();

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  DateTime get lastSentAt => getField<DateTime>('last_sent_at')!;
  set lastSentAt(DateTime value) => setField<DateTime>('last_sent_at', value);
}
