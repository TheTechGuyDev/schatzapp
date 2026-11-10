import '../database.dart';

class CamouflageProfilesTable extends SupabaseTable<CamouflageProfilesRow> {
  @override
  String get tableName => 'camouflage_profiles';

  @override
  CamouflageProfilesRow createRow(Map<String, dynamic> data) =>
      CamouflageProfilesRow(data);
}

class CamouflageProfilesRow extends SupabaseDataRow {
  CamouflageProfilesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CamouflageProfilesTable();

  String get ownerId => getField<String>('owner_id')!;
  set ownerId(String value) => setField<String>('owner_id', value);

  String get contactUserId => getField<String>('contact_user_id')!;
  set contactUserId(String value) => setField<String>('contact_user_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
