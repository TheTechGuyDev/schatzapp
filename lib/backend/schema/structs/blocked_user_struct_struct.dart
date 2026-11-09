// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BlockedUserStructStruct extends BaseStruct {
  BlockedUserStructStruct({
    String? blockedUserId,
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
  })  : _blockedUserId = blockedUserId,
        _fullName = fullName,
        _phoneNumber = phoneNumber,
        _avatarUrl = avatarUrl;

  // "blockedUserId" field.
  String? _blockedUserId;
  String get blockedUserId => _blockedUserId ?? '';
  set blockedUserId(String? val) => _blockedUserId = val;

  bool hasBlockedUserId() => _blockedUserId != null;

  // "fullName" field.
  String? _fullName;
  String get fullName => _fullName ?? '';
  set fullName(String? val) => _fullName = val;

  bool hasFullName() => _fullName != null;

  // "phoneNumber" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  set phoneNumber(String? val) => _phoneNumber = val;

  bool hasPhoneNumber() => _phoneNumber != null;

  // "avatarUrl" field.
  String? _avatarUrl;
  String get avatarUrl => _avatarUrl ?? '';
  set avatarUrl(String? val) => _avatarUrl = val;

  bool hasAvatarUrl() => _avatarUrl != null;

  static BlockedUserStructStruct fromMap(Map<String, dynamic> data) =>
      BlockedUserStructStruct(
        blockedUserId: data['blockedUserId'] as String?,
        fullName: data['fullName'] as String?,
        phoneNumber: data['phoneNumber'] as String?,
        avatarUrl: data['avatarUrl'] as String?,
      );

  static BlockedUserStructStruct? maybeFromMap(dynamic data) => data is Map
      ? BlockedUserStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'blockedUserId': _blockedUserId,
        'fullName': _fullName,
        'phoneNumber': _phoneNumber,
        'avatarUrl': _avatarUrl,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'blockedUserId': serializeParam(
          _blockedUserId,
          ParamType.String,
        ),
        'fullName': serializeParam(
          _fullName,
          ParamType.String,
        ),
        'phoneNumber': serializeParam(
          _phoneNumber,
          ParamType.String,
        ),
        'avatarUrl': serializeParam(
          _avatarUrl,
          ParamType.String,
        ),
      }.withoutNulls;

  static BlockedUserStructStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      BlockedUserStructStruct(
        blockedUserId: deserializeParam(
          data['blockedUserId'],
          ParamType.String,
          false,
        ),
        fullName: deserializeParam(
          data['fullName'],
          ParamType.String,
          false,
        ),
        phoneNumber: deserializeParam(
          data['phoneNumber'],
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
  String toString() => 'BlockedUserStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is BlockedUserStructStruct &&
        blockedUserId == other.blockedUserId &&
        fullName == other.fullName &&
        phoneNumber == other.phoneNumber &&
        avatarUrl == other.avatarUrl;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([blockedUserId, fullName, phoneNumber, avatarUrl]);
}

BlockedUserStructStruct createBlockedUserStructStruct({
  String? blockedUserId,
  String? fullName,
  String? phoneNumber,
  String? avatarUrl,
}) =>
    BlockedUserStructStruct(
      blockedUserId: blockedUserId,
      fullName: fullName,
      phoneNumber: phoneNumber,
      avatarUrl: avatarUrl,
    );
