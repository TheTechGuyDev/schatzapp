import '../database.dart';

class AccountNumberSequencesTable
    extends SupabaseTable<AccountNumberSequencesRow> {
  @override
  String get tableName => 'account_number_sequences';

  @override
  AccountNumberSequencesRow createRow(Map<String, dynamic> data) =>
      AccountNumberSequencesRow(data);
}

class AccountNumberSequencesRow extends SupabaseDataRow {
  AccountNumberSequencesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AccountNumberSequencesTable();

  String get prefix => getField<String>('prefix')!;
  set prefix(String value) => setField<String>('prefix', value);

  int? get nextSuffix => getField<int>('next_suffix');
  set nextSuffix(int? value) => setField<int>('next_suffix', value);
}
