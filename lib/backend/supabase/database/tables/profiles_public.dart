import '../database.dart';

class ProfilesPublicTable extends SupabaseTable<ProfilesPublicRow> {
  @override
  String get tableName => 'profiles_public';

  @override
  ProfilesPublicRow createRow(Map<String, dynamic> data) =>
      ProfilesPublicRow(data);
}

class ProfilesPublicRow extends SupabaseDataRow {
  ProfilesPublicRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ProfilesPublicTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  String? get username => getField<String>('username');
  set username(String? value) => setField<String>('username', value);

  String? get avatarUrl => getField<String>('avatar_url');
  set avatarUrl(String? value) => setField<String>('avatar_url', value);

  String? get phoneNumber => getField<String>('phone_number');
  set phoneNumber(String? value) => setField<String>('phone_number', value);
}
