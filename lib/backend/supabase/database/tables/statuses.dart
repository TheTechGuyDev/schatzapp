import '../database.dart';

class StatusesTable extends SupabaseTable<StatusesRow> {
  @override
  String get tableName => 'statuses';

  @override
  StatusesRow createRow(Map<String, dynamic> data) => StatusesRow(data);
}

class StatusesRow extends SupabaseDataRow {
  StatusesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StatusesTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String? get mediaType => getField<String>('media_type');
  set mediaType(String? value) => setField<String>('media_type', value);

  String? get mediaUrl => getField<String>('media_url');
  set mediaUrl(String? value) => setField<String>('media_url', value);

  String? get quality => getField<String>('quality');
  set quality(String? value) => setField<String>('quality', value);

  String? get caption => getField<String>('caption');
  set caption(String? value) => setField<String>('caption', value);

  String? get backgroundColor => getField<String>('background_color');
  set backgroundColor(String? value) =>
      setField<String>('background_color', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get expiresAt => getField<DateTime>('expires_at');
  set expiresAt(DateTime? value) => setField<DateTime>('expires_at', value);

  int? get textFontIndex => getField<int>('text_font_index');
  set textFontIndex(int? value) => setField<int>('text_font_index', value);

  String? get batchId => getField<String>('batch_id');
  set batchId(String? value) => setField<String>('batch_id', value);

  bool? get commentsEnabled => getField<bool>('comments_enabled');
  set commentsEnabled(bool? value) => setField<bool>('comments_enabled', value);
}
