// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class HiddenPersonStruct extends BaseStruct {
  HiddenPersonStruct({
    String? id,
    String? fullName,
    String? avatarUrl,
  })  : _id = id,
        _fullName = fullName,
        _avatarUrl = avatarUrl;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

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

  static HiddenPersonStruct fromMap(Map<String, dynamic> data) =>
      HiddenPersonStruct(
        id: data['id'] as String?,
        fullName: data['fullName'] as String?,
        avatarUrl: data['avatarUrl'] as String?,
      );

  static HiddenPersonStruct? maybeFromMap(dynamic data) => data is Map
      ? HiddenPersonStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'fullName': _fullName,
        'avatarUrl': _avatarUrl,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
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
      }.withoutNulls;

  static HiddenPersonStruct fromSerializableMap(Map<String, dynamic> data) =>
      HiddenPersonStruct(
        id: deserializeParam(
          data['id'],
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
      );

  @override
  String toString() => 'HiddenPersonStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is HiddenPersonStruct &&
        id == other.id &&
        fullName == other.fullName &&
        avatarUrl == other.avatarUrl;
  }

  @override
  int get hashCode => const ListEquality().hash([id, fullName, avatarUrl]);
}

HiddenPersonStruct createHiddenPersonStruct({
  String? id,
  String? fullName,
  String? avatarUrl,
}) =>
    HiddenPersonStruct(
      id: id,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
