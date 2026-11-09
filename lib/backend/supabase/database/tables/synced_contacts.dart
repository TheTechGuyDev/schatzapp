import '../database.dart';

class SyncedContactsTable extends SupabaseTable<SyncedContactsRow> {
  @override
  String get tableName => 'synced_contacts';

  @override
  SyncedContactsRow createRow(Map<String, dynamic> data) =>
      SyncedContactsRow(data);
}

class SyncedContactsRow extends SupabaseDataRow {
  SyncedContactsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SyncedContactsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get ownerId => getField<String>('owner_id')!;
  set ownerId(String value) => setField<String>('owner_id', value);

  String get contactName => getField<String>('contact_name')!;
  set contactName(String value) => setField<String>('contact_name', value);

  String get phoneNumber => getField<String>('phone_number')!;
  set phoneNumber(String value) => setField<String>('phone_number', value);

  String? get matchedUserId => getField<String>('matched_user_id');
  set matchedUserId(String? value) =>
      setField<String>('matched_user_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
