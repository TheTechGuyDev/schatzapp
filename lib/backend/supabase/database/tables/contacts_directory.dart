import '../database.dart';

class ContactsDirectoryTable extends SupabaseTable<ContactsDirectoryRow> {
  @override
  String get tableName => 'contacts_directory';

  @override
  ContactsDirectoryRow createRow(Map<String, dynamic> data) =>
      ContactsDirectoryRow(data);
}

class ContactsDirectoryRow extends SupabaseDataRow {
  ContactsDirectoryRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ContactsDirectoryTable();

  String? get contactId => getField<String>('contact_id');
  set contactId(String? value) => setField<String>('contact_id', value);

  String? get ownerId => getField<String>('owner_id');
  set ownerId(String? value) => setField<String>('owner_id', value);

  String? get contactUserId => getField<String>('contact_user_id');
  set contactUserId(String? value) =>
      setField<String>('contact_user_id', value);

  String? get savedName => getField<String>('saved_name');
  set savedName(String? value) => setField<String>('saved_name', value);

  String? get phoneNumber => getField<String>('phone_number');
  set phoneNumber(String? value) => setField<String>('phone_number', value);

  String? get avatarUrl => getField<String>('avatar_url');
  set avatarUrl(String? value) => setField<String>('avatar_url', value);

  bool? get isOnline => getField<bool>('is_online');
  set isOnline(bool? value) => setField<bool>('is_online', value);

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  bool? get isFavorite => getField<bool>('is_favorite');
  set isFavorite(bool? value) => setField<bool>('is_favorite', value);
}
