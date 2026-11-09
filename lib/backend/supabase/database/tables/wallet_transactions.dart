import '../database.dart';

class WalletTransactionsTable extends SupabaseTable<WalletTransactionsRow> {
  @override
  String get tableName => 'wallet_transactions';

  @override
  WalletTransactionsRow createRow(Map<String, dynamic> data) =>
      WalletTransactionsRow(data);
}

class WalletTransactionsRow extends SupabaseDataRow {
  WalletTransactionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => WalletTransactionsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get walletId => getField<String>('wallet_id')!;
  set walletId(String value) => setField<String>('wallet_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get type => getField<String>('type')!;
  set type(String value) => setField<String>('type', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  double get amount => getField<double>('amount')!;
  set amount(double value) => setField<double>('amount', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  double? get balanceAfter => getField<double>('balance_after');
  set balanceAfter(double? value) => setField<double>('balance_after', value);

  String? get provider => getField<String>('provider');
  set provider(String? value) => setField<String>('provider', value);

  String? get providerReference => getField<String>('provider_reference');
  set providerReference(String? value) =>
      setField<String>('provider_reference', value);

  String get referenceField => getField<String>('reference')!;
  set referenceField(String value) => setField<String>('reference', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);

  String? get relatedConversationId =>
      getField<String>('related_conversation_id');
  set relatedConversationId(String? value) =>
      setField<String>('related_conversation_id', value);

  String? get relatedMessageId => getField<String>('related_message_id');
  set relatedMessageId(String? value) =>
      setField<String>('related_message_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  double? get feeAmount => getField<double>('fee_amount');
  set feeAmount(double? value) => setField<double>('fee_amount', value);

  String? get idempotencyKey => getField<String>('idempotency_key');
  set idempotencyKey(String? value) =>
      setField<String>('idempotency_key', value);
}
