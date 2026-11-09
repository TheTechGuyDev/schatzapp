// ignore_for_file: unnecessary_getters_setters


import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StoryGroupStruct extends BaseStruct {
  StoryGroupStruct({
    String? userId,
    String? fullName,
    String? avatarUrl,
    bool? hasUnviewed,
    List<StoryItemStruct>? items,
  })  : _userId = userId,
        _fullName = fullName,
        _avatarUrl = avatarUrl,
        _hasUnviewed = hasUnviewed,
        _items = items;

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  set userId(String? val) => _userId = val;

  bool hasUserId() => _userId != null;

  // "fullName" field.
  String? _fullName;
  String get fullName => _fullName ?? '';
  set fullName(String? val) => _fullName = val;

  bool hasFullName() => _fullName != null;

  // "avatarUrl" field.
  String? _avatarUrl;
  String get avatarUrl => _avatarUrl ?? '';
  set avatarUrl(String? val) => _avatarUrl = val;

  bool hasAvatarUrl() => _avatarUrl != null;

  // "hasUnviewed" field.
  bool? _hasUnviewed;
  bool get hasUnviewed => _hasUnviewed ?? false;
  set hasUnviewed(bool? val) => _hasUnviewed = val;

  bool hasHasUnviewed() => _hasUnviewed != null;

  // "items" field.
  List<StoryItemStruct>? _items;
  List<StoryItemStruct> get items => _items ?? const [];
  set items(List<StoryItemStruct>? val) => _items = val;

  void updateItems(Function(List<StoryItemStruct>) updateFn) {
    updateFn(_items ??= []);
  }

  bool hasItems() => _items != null;

  static StoryGroupStruct fromMap(Map<String, dynamic> data) =>
      StoryGroupStruct(
        userId: data['userId'] as String?,
        fullName: data['fullName'] as String?,
        avatarUrl: data['avatarUrl'] as String?,
        hasUnviewed: data['hasUnviewed'] as bool?,
        items: getStructList(
          data['items'],
          StoryItemStruct.fromMap,
        ),
      );

  static StoryGroupStruct? maybeFromMap(dynamic data) => data is Map
      ? StoryGroupStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'userId': _userId,
        'fullName': _fullName,
        'avatarUrl': _avatarUrl,
        'hasUnviewed': _hasUnviewed,
        'items': _items?.map((e) => e.toMap()).toList(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'userId': serializeParam(
          _userId,
          ParamType.String,
        ),
        'fullName': serializeParam(
          _fullName,
          ParamType.String,
        ),
        'avatarUrl': serializeParam(
          _avatarUrl,
          ParamType.String,
        ),
        'hasUnviewed': serializeParam(
          _hasUnviewed,
          ParamType.bool,
        ),
        'items': serializeParam(
          _items,
          ParamType.DataStruct,
          isList: true,
        ),
      }.withoutNulls;

  static StoryGroupStruct fromSerializableMap(Map<String, dynamic> data) =>
      StoryGroupStruct(
        userId: deserializeParam(
          data['userId'],
          ParamType.String,
          false,
        ),
        fullName: deserializeParam(
          data['fullName'],
          ParamType.String,
          false,
        ),
        avatarUrl: deserializeParam(
          data['avatarUrl'],
          ParamType.String,
          false,
        ),
        hasUnviewed: deserializeParam(
          data['hasUnviewed'],
          ParamType.bool,
          false,
        ),
        items: deserializeStructParam<StoryItemStruct>(
          data['items'],
          ParamType.DataStruct,
          true,
          structBuilder: StoryItemStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'StoryGroupStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is StoryGroupStruct &&
        userId == other.userId &&
        fullName == other.fullName &&
        avatarUrl == other.avatarUrl &&
        hasUnviewed == other.hasUnviewed &&
        listEquality.equals(items, other.items);
  }

  @override
  int get hashCode => const ListEquality().hash([
        userId,
        fullName,
        avatarUrl,
        hasUnviewed,
        const ListEquality().hash(items)
      ]);
}

StoryGroupStruct createStoryGroupStruct({
  String? userId,
  String? fullName,
  String? avatarUrl,
  bool? hasUnviewed,
}) =>
    StoryGroupStruct(
      userId: userId,
      fullName: fullName,
      avatarUrl: avatarUrl,
      hasUnviewed: hasUnviewed,
    );
