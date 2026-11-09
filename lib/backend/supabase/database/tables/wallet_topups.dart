import '../database.dart';

class WalletTopupsTable extends SupabaseTable<WalletTopupsRow> {
  @override
  String get tableName => 'wallet_topups';

  @override
  WalletTopupsRow createRow(Map<String, dynamic> data) => WalletTopupsRow(data);
}

class WalletTopupsRow extends SupabaseDataRow {
  WalletTopupsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => WalletTopupsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  double get amountSchatz => getField<double>('amount_schatz')!;
  set amountSchatz(double value) => setField<double>('amount_schatz', value);

  String? get method => getField<String>('method');
  set method(String? value) => setField<String>('method', value);

  String get referenceField => getField<String>('reference')!;
  set referenceField(String value) => setField<String>('reference', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
