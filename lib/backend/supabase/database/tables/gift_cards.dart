import '../database.dart';

class GiftCardsTable extends SupabaseTable<GiftCardsRow> {
  @override
  String get tableName => 'gift_cards';

  @override
  GiftCardsRow createRow(Map<String, dynamic> data) => GiftCardsRow(data);
}

class GiftCardsRow extends SupabaseDataRow {
  GiftCardsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GiftCardsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get transactionId => getField<String>('transaction_id')!;
  set transactionId(String value) => setField<String>('transaction_id', value);

  String get purchasedByUserId => getField<String>('purchased_by_user_id')!;
  set purchasedByUserId(String value) =>
      setField<String>('purchased_by_user_id', value);

  String get ownerUserId => getField<String>('owner_user_id')!;
  set ownerUserId(String value) => setField<String>('owner_user_id', value);

  String? get reloadlyProductId => getField<String>('reloadly_product_id');
  set reloadlyProductId(String? value) =>
      setField<String>('reloadly_product_id', value);

  String? get reloadlyTransactionId =>
      getField<String>('reloadly_transaction_id');
  set reloadlyTransactionId(String? value) =>
      setField<String>('reloadly_transaction_id', value);

  String get brandName => getField<String>('brand_name')!;
  set brandName(String value) => setField<String>('brand_name', value);

  double get cardValue => getField<double>('card_value')!;
  set cardValue(double value) => setField<double>('card_value', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  String? get cardNumber => getField<String>('card_number');
  set cardNumber(String? value) => setField<String>('card_number', value);

  String? get pinCode => getField<String>('pin_code');
  set pinCode(String? value) => setField<String>('pin_code', value);

  String? get redeemInstructionsUrl =>
      getField<String>('redeem_instructions_url');
  set redeemInstructionsUrl(String? value) =>
      setField<String>('redeem_instructions_url', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get sentToUserId => getField<String>('sent_to_user_id');
  set sentToUserId(String? value) => setField<String>('sent_to_user_id', value);

  String? get sentViaMessageId => getField<String>('sent_via_message_id');
  set sentViaMessageId(String? value) =>
      setField<String>('sent_via_message_id', value);

  DateTime? get sentAt => getField<DateTime>('sent_at');
  set sentAt(DateTime? value) => setField<DateTime>('sent_at', value);

  DateTime? get redeemedAt => getField<DateTime>('redeemed_at');
  set redeemedAt(DateTime? value) => setField<DateTime>('redeemed_at', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
