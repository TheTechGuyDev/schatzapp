// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class GroupMemberStructStruct extends BaseStruct {
  GroupMemberStructStruct({
    String? memberId,
    String? memberName,
    String? memberAvatar,
  })  : _memberId = memberId,
        _memberName = memberName,
        _memberAvatar = memberAvatar;

  // "memberId" field.
  String? _memberId;
  String get memberId => _memberId ?? '';
  set memberId(String? val) => _memberId = val;

  bool hasMemberId() => _memberId != null;

  // "memberName" field.
  String? _memberName;
  String get memberName => _memberName ?? '';
  set memberName(String? val) => _memberName = val;

  bool hasMemberName() => _memberName != null;

  // "memberAvatar" field.
  String? _memberAvatar;
  String get memberAvatar => _memberAvatar ?? '';
  set memberAvatar(String? val) => _memberAvatar = val;

  bool hasMemberAvatar() => _memberAvatar != null;

  static GroupMemberStructStruct fromMap(Map<String, dynamic> data) =>
      GroupMemberStructStruct(
        memberId: data['memberId'] as String?,
        memberName: data['memberName'] as String?,
        memberAvatar: data['memberAvatar'] as String?,
      );

  static GroupMemberStructStruct? maybeFromMap(dynamic data) => data is Map
      ? GroupMemberStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'memberId': _memberId,
        'memberName': _memberName,
        'memberAvatar': _memberAvatar,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'memberId': serializeParam(
          _memberId,
          ParamType.String,
        ),
        'memberName': serializeParam(
          _memberName,
          ParamType.String,
        ),
        'memberAvatar': serializeParam(
          _memberAvatar,
          ParamType.String,
        ),
      }.withoutNulls;

  static GroupMemberStructStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      GroupMemberStructStruct(
        memberId: deserializeParam(
          data['memberId'],
          ParamType.String,
          false,
        ),
        memberName: deserializeParam(
          data['memberName'],
          ParamType.String,
          false,
        ),
        memberAvatar: deserializeParam(
          data['memberAvatar'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'GroupMemberStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is GroupMemberStructStruct &&
        memberId == other.memberId &&
        memberName == other.memberName &&
        memberAvatar == other.memberAvatar;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([memberId, memberName, memberAvatar]);
}

GroupMemberStructStruct createGroupMemberStructStruct({
  String? memberId,
  String? memberName,
  String? memberAvatar,
}) =>
    GroupMemberStructStruct(
      memberId: memberId,
      memberName: memberName,
      memberAvatar: memberAvatar,
    );
