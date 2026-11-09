import '../database.dart';

class PrivacySettingsTable extends SupabaseTable<PrivacySettingsRow> {
  @override
  String get tableName => 'privacy_settings';

  @override
  PrivacySettingsRow createRow(Map<String, dynamic> data) =>
      PrivacySettingsRow(data);
}

class PrivacySettingsRow extends SupabaseDataRow {
  PrivacySettingsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PrivacySettingsTable();

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String? get lastSeenVisibility => getField<String>('last_seen_visibility');
  set lastSeenVisibility(String? value) =>
      setField<String>('last_seen_visibility', value);

  String? get profilePhotoVisibility =>
      getField<String>('profile_photo_visibility');
  set profilePhotoVisibility(String? value) =>
      setField<String>('profile_photo_visibility', value);

  String? get aboutVisibility => getField<String>('about_visibility');
  set aboutVisibility(String? value) =>
      setField<String>('about_visibility', value);

  String? get statusVisibility => getField<String>('status_visibility');
  set statusVisibility(String? value) =>
      setField<String>('status_visibility', value);

  bool? get readReceiptsEnabled => getField<bool>('read_receipts_enabled');
  set readReceiptsEnabled(bool? value) =>
      setField<bool>('read_receipts_enabled', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
