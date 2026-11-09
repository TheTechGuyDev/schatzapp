import '../database.dart';

class StorySettingsTable extends SupabaseTable<StorySettingsRow> {
  @override
  String get tableName => 'story_settings';

  @override
  StorySettingsRow createRow(Map<String, dynamic> data) =>
      StorySettingsRow(data);
}

class StorySettingsRow extends SupabaseDataRow {
  StorySettingsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StorySettingsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  int? get durationHours => getField<int>('duration_hours');
  set durationHours(int? value) => setField<int>('duration_hours', value);

  String? get sortOrder => getField<String>('sort_order');
  set sortOrder(String? value) => setField<String>('sort_order', value);

  String? get viewVisibility => getField<String>('view_visibility');
  set viewVisibility(String? value) =>
      setField<String>('view_visibility', value);

  bool? get allowDownload => getField<bool>('allow_download');
  set allowDownload(bool? value) => setField<bool>('allow_download', value);

  bool? get allowReplies => getField<bool>('allow_replies');
  set allowReplies(bool? value) => setField<bool>('allow_replies', value);

  bool? get showLocation => getField<bool>('show_location');
  set showLocation(bool? value) => setField<bool>('show_location', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
