// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class GroupInCommonStructStruct extends BaseStruct {
  GroupInCommonStructStruct({
    String? groupId,
    String? groupName,
    String? groupAvatarUrl,
    int? memberCount,
  })  : _groupId = groupId,
        _groupName = groupName,
        _groupAvatarUrl = groupAvatarUrl,
        _memberCount = memberCount;

  // "groupId" field.
  String? _groupId;
  String get groupId => _groupId ?? '';
  set groupId(String? val) => _groupId = val;

  bool hasGroupId() => _groupId != null;

  // "groupName" field.
  String? _groupName;
  String get groupName => _groupName ?? '';
  set groupName(String? val) => _groupName = val;

  bool hasGroupName() => _groupName != null;

  // "groupAvatarUrl" field.
  String? _groupAvatarUrl;
  String get groupAvatarUrl => _groupAvatarUrl ?? '';
  set groupAvatarUrl(String? val) => _groupAvatarUrl = val;

  bool hasGroupAvatarUrl() => _groupAvatarUrl != null;

  // "memberCount" field.
  int? _memberCount;
  int get memberCount => _memberCount ?? 0;
  set memberCount(int? val) => _memberCount = val;

  void incrementMemberCount(int amount) => memberCount = memberCount + amount;

  bool hasMemberCount() => _memberCount != null;

  static GroupInCommonStructStruct fromMap(Map<String, dynamic> data) =>
      GroupInCommonStructStruct(
        groupId: data['groupId'] as String?,
        groupName: data['groupName'] as String?,
        groupAvatarUrl: data['groupAvatarUrl'] as String?,
        memberCount: castToType<int>(data['memberCount']),
      );

  static GroupInCommonStructStruct? maybeFromMap(dynamic data) => data is Map
      ? GroupInCommonStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'groupId': _groupId,
        'groupName': _groupName,
        'groupAvatarUrl': _groupAvatarUrl,
        'memberCount': _memberCount,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'groupId': serializeParam(
          _groupId,
          ParamType.String,
        ),
        'groupName': serializeParam(
          _groupName,
          ParamType.String,
        ),
        'groupAvatarUrl': serializeParam(
          _groupAvatarUrl,
          ParamType.String,
        ),
        'memberCount': serializeParam(
          _memberCount,
          ParamType.int,
        ),
      }.withoutNulls;

  static GroupInCommonStructStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      GroupInCommonStructStruct(
        groupId: deserializeParam(
          data['groupId'],
          ParamType.String,
          false,
        ),
        groupName: deserializeParam(
          data['groupName'],
          ParamType.String,
          false,
        ),
        groupAvatarUrl: deserializeParam(
          data['groupAvatarUrl'],
          ParamType.String,
          false,
        ),
        memberCount: deserializeParam(
          data['memberCount'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'GroupInCommonStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is GroupInCommonStructStruct &&
        groupId == other.groupId &&
        groupName == other.groupName &&
        groupAvatarUrl == other.groupAvatarUrl &&
        memberCount == other.memberCount;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([groupId, groupName, groupAvatarUrl, memberCount]);
}

GroupInCommonStructStruct createGroupInCommonStructStruct({
  String? groupId,
  String? groupName,
  String? groupAvatarUrl,
  int? memberCount,
}) =>
    GroupInCommonStructStruct(
      groupId: groupId,
      groupName: groupName,
      groupAvatarUrl: groupAvatarUrl,
      memberCount: memberCount,
    );
