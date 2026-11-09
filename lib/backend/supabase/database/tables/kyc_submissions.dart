import '../database.dart';

class KycSubmissionsTable extends SupabaseTable<KycSubmissionsRow> {
  @override
  String get tableName => 'kyc_submissions';

  @override
  KycSubmissionsRow createRow(Map<String, dynamic> data) =>
      KycSubmissionsRow(data);
}

class KycSubmissionsRow extends SupabaseDataRow {
  KycSubmissionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => KycSubmissionsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String? get walletId => getField<String>('wallet_id');
  set walletId(String? value) => setField<String>('wallet_id', value);

  String? get dateOfBirth => getField<String>('date_of_birth');
  set dateOfBirth(String? value) => setField<String>('date_of_birth', value);

  String? get firstName => getField<String>('first_name');
  set firstName(String? value) => setField<String>('first_name', value);

  String? get lastName => getField<String>('last_name');
  set lastName(String? value) => setField<String>('last_name', value);

  String? get gender => getField<String>('gender');
  set gender(String? value) => setField<String>('gender', value);

  String? get streetAddress => getField<String>('street_address');
  set streetAddress(String? value) => setField<String>('street_address', value);

  String? get city => getField<String>('city');
  set city(String? value) => setField<String>('city', value);

  String? get state => getField<String>('state');
  set state(String? value) => setField<String>('state', value);

  String? get postcode => getField<String>('postcode');
  set postcode(String? value) => setField<String>('postcode', value);

  String? get country => getField<String>('country');
  set country(String? value) => setField<String>('country', value);

  String? get idType => getField<String>('id_type');
  set idType(String? value) => setField<String>('id_type', value);

  String? get idFrontUrl => getField<String>('id_front_url');
  set idFrontUrl(String? value) => setField<String>('id_front_url', value);

  String? get idBackUrl => getField<String>('id_back_url');
  set idBackUrl(String? value) => setField<String>('id_back_url', value);

  String? get selfieUrl => getField<String>('selfie_url');
  set selfieUrl(String? value) => setField<String>('selfie_url', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get rejectionReason => getField<String>('rejection_reason');
  set rejectionReason(String? value) =>
      setField<String>('rejection_reason', value);

  DateTime? get submittedAt => getField<DateTime>('submitted_at');
  set submittedAt(DateTime? value) => setField<DateTime>('submitted_at', value);

  DateTime? get reviewedAt => getField<DateTime>('reviewed_at');
  set reviewedAt(DateTime? value) => setField<DateTime>('reviewed_at', value);

  String? get reviewedBy => getField<String>('reviewed_by');
  set reviewedBy(String? value) => setField<String>('reviewed_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  List<String> get rejectionReasons =>
      getListField<String>('rejection_reasons');
  set rejectionReasons(List<String>? value) =>
      setListField<String>('rejection_reasons', value);
}
