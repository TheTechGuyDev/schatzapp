// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AcceptCallResultStruct extends BaseStruct {
  AcceptCallResultStruct({
    String? agoraToken,
    int? agoraUid,
  })  : _agoraToken = agoraToken,
        _agoraUid = agoraUid;

  // "agoraToken" field.
  String? _agoraToken;
  String get agoraToken => _agoraToken ?? '';
  set agoraToken(String? val) => _agoraToken = val;

  bool hasAgoraToken() => _agoraToken != null;

  // "agoraUid" field.
  int? _agoraUid;
  int get agoraUid => _agoraUid ?? 0;
  set agoraUid(int? val) => _agoraUid = val;

  void incrementAgoraUid(int amount) => agoraUid = agoraUid + amount;

  bool hasAgoraUid() => _agoraUid != null;

  static AcceptCallResultStruct fromMap(Map<String, dynamic> data) =>
      AcceptCallResultStruct(
        agoraToken: data['agoraToken'] as String?,
        agoraUid: castToType<int>(data['agoraUid']),
      );

  static AcceptCallResultStruct? maybeFromMap(dynamic data) => data is Map
      ? AcceptCallResultStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'agoraToken': _agoraToken,
        'agoraUid': _agoraUid,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'agoraToken': serializeParam(
          _agoraToken,
          ParamType.String,
        ),
        'agoraUid': serializeParam(
          _agoraUid,
          ParamType.int,
        ),
      }.withoutNulls;

  static AcceptCallResultStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      AcceptCallResultStruct(
        agoraToken: deserializeParam(
          data['agoraToken'],
          ParamType.String,
          false,
        ),
        agoraUid: deserializeParam(
          data['agoraUid'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'AcceptCallResultStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is AcceptCallResultStruct &&
        agoraToken == other.agoraToken &&
        agoraUid == other.agoraUid;
  }

  @override
  int get hashCode => const ListEquality().hash([agoraToken, agoraUid]);
}

AcceptCallResultStruct createAcceptCallResultStruct({
  String? agoraToken,
  int? agoraUid,
}) =>
    AcceptCallResultStruct(
      agoraToken: agoraToken,
      agoraUid: agoraUid,
    );
