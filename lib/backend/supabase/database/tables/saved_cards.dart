import '../database.dart';

class SavedCardsTable extends SupabaseTable<SavedCardsRow> {
  @override
  String get tableName => 'saved_cards';

  @override
  SavedCardsRow createRow(Map<String, dynamic> data) => SavedCardsRow(data);
}

class SavedCardsRow extends SupabaseDataRow {
  SavedCardsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SavedCardsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get cardLastFour => getField<String>('card_last_four')!;
  set cardLastFour(String value) => setField<String>('card_last_four', value);

  String get cardBrand => getField<String>('card_brand')!;
  set cardBrand(String value) => setField<String>('card_brand', value);

  String? get billingFirstName => getField<String>('billing_first_name');
  set billingFirstName(String? value) =>
      setField<String>('billing_first_name', value);

  String? get billingLastName => getField<String>('billing_last_name');
  set billingLastName(String? value) =>
      setField<String>('billing_last_name', value);

  String? get billingAddress => getField<String>('billing_address');
  set billingAddress(String? value) =>
      setField<String>('billing_address', value);

  String? get billingCity => getField<String>('billing_city');
  set billingCity(String? value) => setField<String>('billing_city', value);

  String? get billingState => getField<String>('billing_state');
  set billingState(String? value) => setField<String>('billing_state', value);

  String? get billingPostcode => getField<String>('billing_postcode');
  set billingPostcode(String? value) =>
      setField<String>('billing_postcode', value);

  String? get billingCountry => getField<String>('billing_country');
  set billingCountry(String? value) =>
      setField<String>('billing_country', value);

  bool? get isDefault => getField<bool>('is_default');
  set isDefault(bool? value) => setField<bool>('is_default', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
