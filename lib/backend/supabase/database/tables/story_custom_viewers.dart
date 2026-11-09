import '../database.dart';

class StoryCustomViewersTable extends SupabaseTable<StoryCustomViewersRow> {
  @override
  String get tableName => 'story_custom_viewers';

  @override
  StoryCustomViewersRow createRow(Map<String, dynamic> data) =>
      StoryCustomViewersRow(data);
}

class StoryCustomViewersRow extends SupabaseDataRow {
  StoryCustomViewersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StoryCustomViewersTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String get ownerId => getField<String>('owner_id')!;
  set ownerId(String value) => setField<String>('owner_id', value);

  String get viewerId => getField<String>('viewer_id')!;
  set viewerId(String value) => setField<String>('viewer_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
