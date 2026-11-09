// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CallHistoryEntryStruct extends BaseStruct {
  CallHistoryEntryStruct({
    String? id,
    String? conversationId,
    String? otherPartyId,
    String? otherPartyName,
    String? otherPartyAvatar,
    String? direction,
    String? callType,
    DateTime? startedAt,
    int? durationSeconds,
  })  : _id = id,
        _conversationId = conversationId,
        _otherPartyId = otherPartyId,
        _otherPartyName = otherPartyName,
        _otherPartyAvatar = otherPartyAvatar,
        _direction = direction,
        _callType = callType,
        _startedAt = startedAt,
        _durationSeconds = durationSeconds;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "conversationId" field.
  String? _conversationId;
  String get conversationId => _conversationId ?? '';
  set conversationId(String? val) => _conversationId = val;

  bool hasConversationId() => _conversationId != null;

  // "otherPartyId" field.
  String? _otherPartyId;
  String get otherPartyId => _otherPartyId ?? '';
  set otherPartyId(String? val) => _otherPartyId = val;

  bool hasOtherPartyId() => _otherPartyId != null;

  // "otherPartyName" field.
  String? _otherPartyName;
  String get otherPartyName => _otherPartyName ?? '';
  set otherPartyName(String? val) => _otherPartyName = val;

  bool hasOtherPartyName() => _otherPartyName != null;

  // "otherPartyAvatar" field.
  String? _otherPartyAvatar;
  String get otherPartyAvatar => _otherPartyAvatar ?? '';
  set otherPartyAvatar(String? val) => _otherPartyAvatar = val;

  bool hasOtherPartyAvatar() => _otherPartyAvatar != null;

  // "direction" field.
  String? _direction;
  String get direction => _direction ?? '';
  set direction(String? val) => _direction = val;

  bool hasDirection() => _direction != null;

  // "callType" field.
  String? _callType;
  String get callType => _callType ?? '';
  set callType(String? val) => _callType = val;

  bool hasCallType() => _callType != null;

  // "startedAt" field.
  DateTime? _startedAt;
  DateTime? get startedAt => _startedAt;
  set startedAt(DateTime? val) => _startedAt = val;

  bool hasStartedAt() => _startedAt != null;

  // "durationSeconds" field.
  int? _durationSeconds;
  int get durationSeconds => _durationSeconds ?? 0;
  set durationSeconds(int? val) => _durationSeconds = val;

  void incrementDurationSeconds(int amount) =>
      durationSeconds = durationSeconds + amount;

  bool hasDurationSeconds() => _durationSeconds != null;

  static CallHistoryEntryStruct fromMap(Map<String, dynamic> data) =>
      CallHistoryEntryStruct(
        id: data['id'] as String?,
        conversationId: data['conversationId'] as String?,
        otherPartyId: data['otherPartyId'] as String?,
        otherPartyName: data['otherPartyName'] as String?,
        otherPartyAvatar: data['otherPartyAvatar'] as String?,
        direction: data['direction'] as String?,
        callType: data['callType'] as String?,
        startedAt: data['startedAt'] as DateTime?,
        durationSeconds: castToType<int>(data['durationSeconds']),
      );

  static CallHistoryEntryStruct? maybeFromMap(dynamic data) => data is Map
      ? CallHistoryEntryStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'conversationId': _conversationId,
        'otherPartyId': _otherPartyId,
        'otherPartyName': _otherPartyName,
        'otherPartyAvatar': _otherPartyAvatar,
        'direction': _direction,
        'callType': _callType,
        'startedAt': _startedAt,
        'durationSeconds': _durationSeconds,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
        'conversationId': serializeParam(
          _conversationId,
          ParamType.String,
        ),
        'otherPartyId': serializeParam(
          _otherPartyId,
          ParamType.String,
        ),
        'otherPartyName': serializeParam(
          _otherPartyName,
          ParamType.String,
        ),
        'otherPartyAvatar': serializeParam(
          _otherPartyAvatar,
          ParamType.String,
        ),
        'direction': serializeParam(
          _direction,
          ParamType.String,
        ),
        'callType': serializeParam(
          _callType,
          ParamType.String,
        ),
        'startedAt': serializeParam(
          _startedAt,
          ParamType.DateTime,
        ),
        'durationSeconds': serializeParam(
          _durationSeconds,
          ParamType.int,
        ),
      }.withoutNulls;

  static CallHistoryEntryStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      CallHistoryEntryStruct(
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
        conversationId: deserializeParam(
          data['conversationId'],
          ParamType.String,
          false,
        ),
        otherPartyId: deserializeParam(
          data['otherPartyId'],
          ParamType.String,
          false,
        ),
        otherPartyName: deserializeParam(
          data['otherPartyName'],
          ParamType.String,
          false,
        ),
        otherPartyAvatar: deserializeParam(
          data['otherPartyAvatar'],
          ParamType.String,
          false,
        ),
        direction: deserializeParam(
          data['direction'],
          ParamType.String,
          false,
        ),
        callType: deserializeParam(
          data['callType'],
          ParamType.String,
          false,
        ),
        startedAt: deserializeParam(
          data['startedAt'],
          ParamType.DateTime,
          false,
        ),
        durationSeconds: deserializeParam(
          data['durationSeconds'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'CallHistoryEntryStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is CallHistoryEntryStruct &&
        id == other.id &&
        conversationId == other.conversationId &&
        otherPartyId == other.otherPartyId &&
        otherPartyName == other.otherPartyName &&
        otherPartyAvatar == other.otherPartyAvatar &&
        direction == other.direction &&
        callType == other.callType &&
        startedAt == other.startedAt &&
        durationSeconds == other.durationSeconds;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        conversationId,
        otherPartyId,
        otherPartyName,
        otherPartyAvatar,
        direction,
        callType,
        startedAt,
        durationSeconds
      ]);
}

CallHistoryEntryStruct createCallHistoryEntryStruct({
  String? id,
  String? conversationId,
  String? otherPartyId,
  String? otherPartyName,
  String? otherPartyAvatar,
  String? direction,
  String? callType,
  DateTime? startedAt,
  int? durationSeconds,
}) =>
    CallHistoryEntryStruct(
      id: id,
      conversationId: conversationId,
      otherPartyId: otherPartyId,
      otherPartyName: otherPartyName,
      otherPartyAvatar: otherPartyAvatar,
      direction: direction,
      callType: callType,
      startedAt: startedAt,
      durationSeconds: durationSeconds,
    );
