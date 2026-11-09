import '../database.dart';

class BankTransferSettingsTable extends SupabaseTable<BankTransferSettingsRow> {
  @override
  String get tableName => 'bank_transfer_settings';

  @override
  BankTransferSettingsRow createRow(Map<String, dynamic> data) =>
      BankTransferSettingsRow(data);
}

class BankTransferSettingsRow extends SupabaseDataRow {
  BankTransferSettingsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BankTransferSettingsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get accountName => getField<String>('account_name')!;
  set accountName(String value) => setField<String>('account_name', value);

  String get bankName => getField<String>('bank_name')!;
  set bankName(String value) => setField<String>('bank_name', value);

  String get iban => getField<String>('iban')!;
  set iban(String value) => setField<String>('iban', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
