// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StatusViewerStruct extends BaseStruct {
  StatusViewerStruct({
    String? viewerId,
    String? fullName,
    String? avatarUrl,
    DateTime? viewedAt,
  })  : _viewerId = viewerId,
        _fullName = fullName,
        _avatarUrl = avatarUrl,
        _viewedAt = viewedAt;

  // "viewerId" field.
  String? _viewerId;
  String get viewerId => _viewerId ?? '';
  set viewerId(String? val) => _viewerId = val;

  bool hasViewerId() => _viewerId != null;

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

  // "viewedAt" field.
  DateTime? _viewedAt;
  DateTime? get viewedAt => _viewedAt;
  set viewedAt(DateTime? val) => _viewedAt = val;

  bool hasViewedAt() => _viewedAt != null;

  static StatusViewerStruct fromMap(Map<String, dynamic> data) =>
      StatusViewerStruct(
        viewerId: data['viewerId'] as String?,
        fullName: data['fullName'] as String?,
        avatarUrl: data['avatarUrl'] as String?,
        viewedAt: data['viewedAt'] as DateTime?,
      );

  static StatusViewerStruct? maybeFromMap(dynamic data) => data is Map
      ? StatusViewerStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'viewerId': _viewerId,
        'fullName': _fullName,
        'avatarUrl': _avatarUrl,
        'viewedAt': _viewedAt,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'viewerId': serializeParam(
          _viewerId,
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
        'viewedAt': serializeParam(
          _viewedAt,
          ParamType.DateTime,
        ),
      }.withoutNulls;

  static StatusViewerStruct fromSerializableMap(Map<String, dynamic> data) =>
      StatusViewerStruct(
        viewerId: deserializeParam(
          data['viewerId'],
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
        viewedAt: deserializeParam(
          data['viewedAt'],
          ParamType.DateTime,
          false,
        ),
      );

  @override
  String toString() => 'StatusViewerStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is StatusViewerStruct &&
        viewerId == other.viewerId &&
        fullName == other.fullName &&
        avatarUrl == other.avatarUrl &&
        viewedAt == other.viewedAt;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([viewerId, fullName, avatarUrl, viewedAt]);
}

StatusViewerStruct createStatusViewerStruct({
  String? viewerId,
  String? fullName,
  String? avatarUrl,
  DateTime? viewedAt,
}) =>
    StatusViewerStruct(
      viewerId: viewerId,
      fullName: fullName,
      avatarUrl: avatarUrl,
      viewedAt: viewedAt,
    );
