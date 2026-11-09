// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PendingWebImageStruct extends BaseStruct {
  PendingWebImageStruct({
    String? base64Data,
    String? mediaType,
  })  : _base64Data = base64Data,
        _mediaType = mediaType;

  // "base64Data" field.
  String? _base64Data;
  String get base64Data => _base64Data ?? '';
  set base64Data(String? val) => _base64Data = val;

  bool hasBase64Data() => _base64Data != null;

  // "mediaType" field.
  String? _mediaType;
  String get mediaType => _mediaType ?? '';
  set mediaType(String? val) => _mediaType = val;

  bool hasMediaType() => _mediaType != null;

  static PendingWebImageStruct fromMap(Map<String, dynamic> data) =>
      PendingWebImageStruct(
        base64Data: data['base64Data'] as String?,
        mediaType: data['mediaType'] as String?,
      );

  static PendingWebImageStruct? maybeFromMap(dynamic data) => data is Map
      ? PendingWebImageStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'base64Data': _base64Data,
        'mediaType': _mediaType,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'base64Data': serializeParam(
          _base64Data,
          ParamType.String,
        ),
        'mediaType': serializeParam(
          _mediaType,
          ParamType.String,
        ),
      }.withoutNulls;

  static PendingWebImageStruct fromSerializableMap(Map<String, dynamic> data) =>
      PendingWebImageStruct(
        base64Data: deserializeParam(
          data['base64Data'],
          ParamType.String,
          false,
        ),
        mediaType: deserializeParam(
          data['mediaType'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'PendingWebImageStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is PendingWebImageStruct &&
        base64Data == other.base64Data &&
        mediaType == other.mediaType;
  }

  @override
  int get hashCode => const ListEquality().hash([base64Data, mediaType]);
}

PendingWebImageStruct createPendingWebImageStruct({
  String? base64Data,
  String? mediaType,
}) =>
    PendingWebImageStruct(
      base64Data: base64Data,
      mediaType: mediaType,
    );
