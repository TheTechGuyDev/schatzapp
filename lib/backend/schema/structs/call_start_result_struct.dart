// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CallStartResultStruct extends BaseStruct {
  CallStartResultStruct({
    String? callId,
    String? agoraToken,
    String? agoraChannelName,
    int? agoraUid,
  })  : _callId = callId,
        _agoraToken = agoraToken,
        _agoraChannelName = agoraChannelName,
        _agoraUid = agoraUid;

  // "callId" field.
  String? _callId;
  String get callId => _callId ?? '';
  set callId(String? val) => _callId = val;

  bool hasCallId() => _callId != null;

  // "agoraToken" field.
  String? _agoraToken;
  String get agoraToken => _agoraToken ?? '';
  set agoraToken(String? val) => _agoraToken = val;

  bool hasAgoraToken() => _agoraToken != null;

  // "agoraChannelName" field.
  String? _agoraChannelName;
  String get agoraChannelName => _agoraChannelName ?? '';
  set agoraChannelName(String? val) => _agoraChannelName = val;

  bool hasAgoraChannelName() => _agoraChannelName != null;

  // "agoraUid" field.
  int? _agoraUid;
  int get agoraUid => _agoraUid ?? 0;
  set agoraUid(int? val) => _agoraUid = val;

  void incrementAgoraUid(int amount) => agoraUid = agoraUid + amount;

  bool hasAgoraUid() => _agoraUid != null;

  static CallStartResultStruct fromMap(Map<String, dynamic> data) =>
      CallStartResultStruct(
        callId: data['callId'] as String?,
        agoraToken: data['agoraToken'] as String?,
        agoraChannelName: data['agoraChannelName'] as String?,
        agoraUid: castToType<int>(data['agoraUid']),
      );

  static CallStartResultStruct? maybeFromMap(dynamic data) => data is Map
      ? CallStartResultStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'callId': _callId,
        'agoraToken': _agoraToken,
        'agoraChannelName': _agoraChannelName,
        'agoraUid': _agoraUid,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'callId': serializeParam(
          _callId,
          ParamType.String,
        ),
        'agoraToken': serializeParam(
          _agoraToken,
          ParamType.String,
        ),
        'agoraChannelName': serializeParam(
          _agoraChannelName,
          ParamType.String,
        ),
        'agoraUid': serializeParam(
          _agoraUid,
          ParamType.int,
        ),
      }.withoutNulls;

  static CallStartResultStruct fromSerializableMap(Map<String, dynamic> data) =>
      CallStartResultStruct(
        callId: deserializeParam(
          data['callId'],
          ParamType.String,
          false,
        ),
        agoraToken: deserializeParam(
          data['agoraToken'],
          ParamType.String,
          false,
        ),
        agoraChannelName: deserializeParam(
          data['agoraChannelName'],
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
  String toString() => 'CallStartResultStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is CallStartResultStruct &&
        callId == other.callId &&
        agoraToken == other.agoraToken &&
        agoraChannelName == other.agoraChannelName &&
        agoraUid == other.agoraUid;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([callId, agoraToken, agoraChannelName, agoraUid]);
}

CallStartResultStruct createCallStartResultStruct({
  String? callId,
  String? agoraToken,
  String? agoraChannelName,
  int? agoraUid,
}) =>
    CallStartResultStruct(
      callId: callId,
      agoraToken: agoraToken,
      agoraChannelName: agoraChannelName,
      agoraUid: agoraUid,
    );
