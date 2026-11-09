// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StoryUploadResultStruct extends BaseStruct {
  StoryUploadResultStruct({
    String? mediaUrl,
    String? mediaType,
  })  : _mediaUrl = mediaUrl,
        _mediaType = mediaType;

  // "mediaUrl" field.
  String? _mediaUrl;
  String get mediaUrl => _mediaUrl ?? '';
  set mediaUrl(String? val) => _mediaUrl = val;

  bool hasMediaUrl() => _mediaUrl != null;

  // "mediaType" field.
  String? _mediaType;
  String get mediaType => _mediaType ?? '';
  set mediaType(String? val) => _mediaType = val;

  bool hasMediaType() => _mediaType != null;

  static StoryUploadResultStruct fromMap(Map<String, dynamic> data) =>
      StoryUploadResultStruct(
        mediaUrl: data['mediaUrl'] as String?,
        mediaType: data['mediaType'] as String?,
      );

  static StoryUploadResultStruct? maybeFromMap(dynamic data) => data is Map
      ? StoryUploadResultStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'mediaUrl': _mediaUrl,
        'mediaType': _mediaType,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'mediaUrl': serializeParam(
          _mediaUrl,
          ParamType.String,
        ),
        'mediaType': serializeParam(
          _mediaType,
          ParamType.String,
        ),
      }.withoutNulls;

  static StoryUploadResultStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      StoryUploadResultStruct(
        mediaUrl: deserializeParam(
          data['mediaUrl'],
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
  String toString() => 'StoryUploadResultStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is StoryUploadResultStruct &&
        mediaUrl == other.mediaUrl &&
        mediaType == other.mediaType;
  }

  @override
  int get hashCode => const ListEquality().hash([mediaUrl, mediaType]);
}

StoryUploadResultStruct createStoryUploadResultStruct({
  String? mediaUrl,
  String? mediaType,
}) =>
    StoryUploadResultStruct(
      mediaUrl: mediaUrl,
      mediaType: mediaType,
    );
