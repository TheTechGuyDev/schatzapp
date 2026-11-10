import '../database.dart';

class PrivateStoryRingViewTable extends SupabaseTable<PrivateStoryRingViewRow> {
  @override
  String get tableName => 'private_story_ring_view';

  @override
  PrivateStoryRingViewRow createRow(Map<String, dynamic> data) =>
      PrivateStoryRingViewRow(data);
}

class PrivateStoryRingViewRow extends SupabaseDataRow {
  PrivateStoryRingViewRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PrivateStoryRingViewTable();

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  String? get avatarUrl => getField<String>('avatar_url');
  set avatarUrl(String? value) => setField<String>('avatar_url', value);

  bool? get hasUnviewed => getField<bool>('has_unviewed');
  set hasUnviewed(bool? value) => setField<bool>('has_unviewed', value);

  bool? get isOnline => getField<bool>('is_online');
  set isOnline(bool? value) => setField<bool>('is_online', value);
}
