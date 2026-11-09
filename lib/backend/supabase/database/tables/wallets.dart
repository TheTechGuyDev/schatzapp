import '../database.dart';

class WalletsTable extends SupabaseTable<WalletsRow> {
  @override
  String get tableName => 'wallets';

  @override
  WalletsRow createRow(Map<String, dynamic> data) => WalletsRow(data);
}

class WalletsRow extends SupabaseDataRow {
  WalletsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => WalletsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  double? get balance => getField<double>('balance');
  set balance(double? value) => setField<double>('balance', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  double? get schatzBalance => getField<double>('schatz_balance');
  set schatzBalance(double? value) => setField<double>('schatz_balance', value);

  String? get kycStatus => getField<String>('kyc_status');
  set kycStatus(String? value) => setField<String>('kyc_status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get walletCountryCode => getField<String>('wallet_country_code');
  set walletCountryCode(String? value) =>
      setField<String>('wallet_country_code', value);

  String? get walletPhoneNumber => getField<String>('wallet_phone_number');
  set walletPhoneNumber(String? value) =>
      setField<String>('wallet_phone_number', value);

  String? get walletStatus => getField<String>('wallet_status');
  set walletStatus(String? value) => setField<String>('wallet_status', value);

  String? get schatzAccountNumber => getField<String>('schatz_account_number');
  set schatzAccountNumber(String? value) =>
      setField<String>('schatz_account_number', value);

  String? get socialTopupAccountNumber =>
      getField<String>('social_topup_account_number');
  set socialTopupAccountNumber(String? value) =>
      setField<String>('social_topup_account_number', value);

  String? get cryptoTopupAccountNumber =>
      getField<String>('crypto_topup_account_number');
  set cryptoTopupAccountNumber(String? value) =>
      setField<String>('crypto_topup_account_number', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get pinHash => getField<String>('pin_hash');
  set pinHash(String? value) => setField<String>('pin_hash', value);

  int? get resetAttemptCount => getField<int>('reset_attempt_count');
  set resetAttemptCount(int? value) =>
      setField<int>('reset_attempt_count', value);

  DateTime? get resetBlockedUntil => getField<DateTime>('reset_blocked_until');
  set resetBlockedUntil(DateTime? value) =>
      setField<DateTime>('reset_blocked_until', value);

  String? get resetToken => getField<String>('reset_token');
  set resetToken(String? value) => setField<String>('reset_token', value);

  DateTime? get resetTokenExpiresAt =>
      getField<DateTime>('reset_token_expires_at');
  set resetTokenExpiresAt(DateTime? value) =>
      setField<DateTime>('reset_token_expires_at', value);

  DateTime? get pinVerifiedUntil => getField<DateTime>('pin_verified_until');
  set pinVerifiedUntil(DateTime? value) =>
      setField<DateTime>('pin_verified_until', value);

  int? get pinAttemptCount => getField<int>('pin_attempt_count');
  set pinAttemptCount(int? value) => setField<int>('pin_attempt_count', value);

  DateTime? get pinBlockedUntil => getField<DateTime>('pin_blocked_until');
  set pinBlockedUntil(DateTime? value) =>
      setField<DateTime>('pin_blocked_until', value);
}
