// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StoryItemStruct extends BaseStruct {
  StoryItemStruct({
    String? id,
    String? mediaUrl,
    String? mediaType,
    String? caption,
    String? backgroundColor,
    DateTime? createdAt,
    int? viewCount,
    int? fontIndex,
  })  : _id = id,
        _mediaUrl = mediaUrl,
        _mediaType = mediaType,
        _caption = caption,
        _backgroundColor = backgroundColor,
        _createdAt = createdAt,
        _viewCount = viewCount,
        _fontIndex = fontIndex;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

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

  // "caption" field.
  String? _caption;
  String get caption => _caption ?? '';
  set caption(String? val) => _caption = val;

  bool hasCaption() => _caption != null;

  // "backgroundColor" field.
  String? _backgroundColor;
  String get backgroundColor => _backgroundColor ?? '';
  set backgroundColor(String? val) => _backgroundColor = val;

  bool hasBackgroundColor() => _backgroundColor != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  set createdAt(DateTime? val) => _createdAt = val;

  bool hasCreatedAt() => _createdAt != null;

  // "viewCount" field.
  int? _viewCount;
  int get viewCount => _viewCount ?? 0;
  set viewCount(int? val) => _viewCount = val;

  void incrementViewCount(int amount) => viewCount = viewCount + amount;

  bool hasViewCount() => _viewCount != null;

  // "fontIndex" field.
  int? _fontIndex;
  int get fontIndex => _fontIndex ?? 0;
  set fontIndex(int? val) => _fontIndex = val;

  void incrementFontIndex(int amount) => fontIndex = fontIndex + amount;

  bool hasFontIndex() => _fontIndex != null;

  static StoryItemStruct fromMap(Map<String, dynamic> data) => StoryItemStruct(
        id: data['id'] as String?,
        mediaUrl: data['mediaUrl'] as String?,
        mediaType: data['mediaType'] as String?,
        caption: data['caption'] as String?,
        backgroundColor: data['backgroundColor'] as String?,
        createdAt: data['createdAt'] as DateTime?,
        viewCount: castToType<int>(data['viewCount']),
        fontIndex: castToType<int>(data['fontIndex']),
      );

  static StoryItemStruct? maybeFromMap(dynamic data) => data is Map
      ? StoryItemStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'mediaUrl': _mediaUrl,
        'mediaType': _mediaType,
        'caption': _caption,
        'backgroundColor': _backgroundColor,
        'createdAt': _createdAt,
        'viewCount': _viewCount,
        'fontIndex': _fontIndex,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
        'mediaUrl': serializeParam(
          _mediaUrl,
          ParamType.String,
        ),
        'mediaType': serializeParam(
          _mediaType,
          ParamType.String,
        ),
        'caption': serializeParam(
          _caption,
          ParamType.String,
        ),
        'backgroundColor': serializeParam(
          _backgroundColor,
          ParamType.String,
        ),
        'createdAt': serializeParam(
          _createdAt,
          ParamType.DateTime,
        ),
        'viewCount': serializeParam(
          _viewCount,
          ParamType.int,
        ),
        'fontIndex': serializeParam(
          _fontIndex,
          ParamType.int,
        ),
      }.withoutNulls;

  static StoryItemStruct fromSerializableMap(Map<String, dynamic> data) =>
      StoryItemStruct(
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
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
        caption: deserializeParam(
          data['caption'],
          ParamType.String,
          false,
        ),
        backgroundColor: deserializeParam(
          data['backgroundColor'],
          ParamType.String,
          false,
        ),
        createdAt: deserializeParam(
          data['createdAt'],
          ParamType.DateTime,
          false,
        ),
        viewCount: deserializeParam(
          data['viewCount'],
          ParamType.int,
          false,
        ),
        fontIndex: deserializeParam(
          data['fontIndex'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'StoryItemStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is StoryItemStruct &&
        id == other.id &&
        mediaUrl == other.mediaUrl &&
        mediaType == other.mediaType &&
        caption == other.caption &&
        backgroundColor == other.backgroundColor &&
        createdAt == other.createdAt &&
        viewCount == other.viewCount &&
        fontIndex == other.fontIndex;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        mediaUrl,
        mediaType,
        caption,
        backgroundColor,
        createdAt,
        viewCount,
        fontIndex
      ]);
}

StoryItemStruct createStoryItemStruct({
  String? id,
  String? mediaUrl,
  String? mediaType,
  String? caption,
  String? backgroundColor,
  DateTime? createdAt,
  int? viewCount,
  int? fontIndex,
}) =>
    StoryItemStruct(
      id: id,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      caption: caption,
      backgroundColor: backgroundColor,
      createdAt: createdAt,
      viewCount: viewCount,
      fontIndex: fontIndex,
    );
