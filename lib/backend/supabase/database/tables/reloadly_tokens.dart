import '../database.dart';

class ReloadlyTokensTable extends SupabaseTable<ReloadlyTokensRow> {
  @override
  String get tableName => 'reloadly_tokens';

  @override
  ReloadlyTokensRow createRow(Map<String, dynamic> data) =>
      ReloadlyTokensRow(data);
}

class ReloadlyTokensRow extends SupabaseDataRow {
  ReloadlyTokensRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ReloadlyTokensTable();

  String get service => getField<String>('service')!;
  set service(String value) => setField<String>('service', value);

  String get accessToken => getField<String>('access_token')!;
  set accessToken(String value) => setField<String>('access_token', value);

  DateTime get expiresAt => getField<DateTime>('expires_at')!;
  set expiresAt(DateTime value) => setField<DateTime>('expires_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
