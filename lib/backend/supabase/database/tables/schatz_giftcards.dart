import '../database.dart';

class SchatzGiftcardsTable extends SupabaseTable<SchatzGiftcardsRow> {
  @override
  String get tableName => 'schatz_giftcards';

  @override
  SchatzGiftcardsRow createRow(Map<String, dynamic> data) =>
      SchatzGiftcardsRow(data);
}

class SchatzGiftcardsRow extends SupabaseDataRow {
  SchatzGiftcardsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SchatzGiftcardsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get code => getField<String>('code')!;
  set code(String value) => setField<String>('code', value);

  String get transactionId => getField<String>('transaction_id')!;
  set transactionId(String value) => setField<String>('transaction_id', value);

  String get purchasedByUserId => getField<String>('purchased_by_user_id')!;
  set purchasedByUserId(String value) =>
      setField<String>('purchased_by_user_id', value);

  double get value => getField<double>('value')!;
  set value(double value) => setField<double>('value', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get redeemedByUserId => getField<String>('redeemed_by_user_id');
  set redeemedByUserId(String? value) =>
      setField<String>('redeemed_by_user_id', value);

  DateTime? get redeemedAt => getField<DateTime>('redeemed_at');
  set redeemedAt(DateTime? value) => setField<DateTime>('redeemed_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get deliveryMethod => getField<String>('delivery_method');
  set deliveryMethod(String? value) =>
      setField<String>('delivery_method', value);

  String? get recipientEmail => getField<String>('recipient_email');
  set recipientEmail(String? value) =>
      setField<String>('recipient_email', value);

  String? get recipientUserId => getField<String>('recipient_user_id');
  set recipientUserId(String? value) =>
      setField<String>('recipient_user_id', value);
}
