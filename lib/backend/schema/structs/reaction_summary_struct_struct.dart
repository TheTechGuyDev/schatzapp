// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Reaction totals for one status post, plus which ones the viewer picked.
/// Types: favorite (heart), peace, laugh (old 'thumbs' rows count here),
/// sad, angry.
class ReactionSummaryStructStruct extends BaseStruct {
  ReactionSummaryStructStruct({
    int? favoriteCount,
    int? peaceCount,
    int? laughCount,
    int? sadCount,
    int? angryCount,
    bool? favoriteActive,
    bool? peaceActive,
    bool? laughActive,
    bool? sadActive,
    bool? angryActive,
  })  : _favoriteCount = favoriteCount,
        _peaceCount = peaceCount,
        _laughCount = laughCount,
        _sadCount = sadCount,
        _angryCount = angryCount,
        _favoriteActive = favoriteActive,
        _peaceActive = peaceActive,
        _laughActive = laughActive,
        _sadActive = sadActive,
        _angryActive = angryActive;

  // "favoriteCount" field.
  int? _favoriteCount;
  int get favoriteCount => _favoriteCount ?? 0;
  set favoriteCount(int? val) => _favoriteCount = val;

  void incrementFavoriteCount(int amount) => favoriteCount = favoriteCount + amount;

  bool hasFavoriteCount() => _favoriteCount != null;

  // "peaceCount" field.
  int? _peaceCount;
  int get peaceCount => _peaceCount ?? 0;
  set peaceCount(int? val) => _peaceCount = val;

  void incrementPeaceCount(int amount) => peaceCount = peaceCount + amount;

  bool hasPeaceCount() => _peaceCount != null;

  // "laughCount" field.
  int? _laughCount;
  int get laughCount => _laughCount ?? 0;
  set laughCount(int? val) => _laughCount = val;

  void incrementLaughCount(int amount) => laughCount = laughCount + amount;

  bool hasLaughCount() => _laughCount != null;

  // "sadCount" field.
  int? _sadCount;
  int get sadCount => _sadCount ?? 0;
  set sadCount(int? val) => _sadCount = val;

  void incrementSadCount(int amount) => sadCount = sadCount + amount;

  bool hasSadCount() => _sadCount != null;

  // "angryCount" field.
  int? _angryCount;
  int get angryCount => _angryCount ?? 0;
  set angryCount(int? val) => _angryCount = val;

  void incrementAngryCount(int amount) => angryCount = angryCount + amount;

  bool hasAngryCount() => _angryCount != null;

  // "favoriteActive" field.
  bool? _favoriteActive;
  bool get favoriteActive => _favoriteActive ?? false;
  set favoriteActive(bool? val) => _favoriteActive = val;

  bool hasFavoriteActive() => _favoriteActive != null;

  // "peaceActive" field.
  bool? _peaceActive;
  bool get peaceActive => _peaceActive ?? false;
  set peaceActive(bool? val) => _peaceActive = val;

  bool hasPeaceActive() => _peaceActive != null;

  // "laughActive" field.
  bool? _laughActive;
  bool get laughActive => _laughActive ?? false;
  set laughActive(bool? val) => _laughActive = val;

  bool hasLaughActive() => _laughActive != null;

  // "sadActive" field.
  bool? _sadActive;
  bool get sadActive => _sadActive ?? false;
  set sadActive(bool? val) => _sadActive = val;

  bool hasSadActive() => _sadActive != null;

  // "angryActive" field.
  bool? _angryActive;
  bool get angryActive => _angryActive ?? false;
  set angryActive(bool? val) => _angryActive = val;

  bool hasAngryActive() => _angryActive != null;

  static ReactionSummaryStructStruct fromMap(Map<String, dynamic> data) =>
      ReactionSummaryStructStruct(
        favoriteCount: castToType<int>(data['favoriteCount']),
        peaceCount: castToType<int>(data['peaceCount']),
        laughCount: castToType<int>(data['laughCount']),
        sadCount: castToType<int>(data['sadCount']),
        angryCount: castToType<int>(data['angryCount']),
        favoriteActive: data['favoriteActive'] as bool?,
        peaceActive: data['peaceActive'] as bool?,
        laughActive: data['laughActive'] as bool?,
        sadActive: data['sadActive'] as bool?,
        angryActive: data['angryActive'] as bool?,
      );

  static ReactionSummaryStructStruct? maybeFromMap(dynamic data) => data is Map
      ? ReactionSummaryStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'favoriteCount': _favoriteCount,
        'peaceCount': _peaceCount,
        'laughCount': _laughCount,
        'sadCount': _sadCount,
        'angryCount': _angryCount,
        'favoriteActive': _favoriteActive,
        'peaceActive': _peaceActive,
        'laughActive': _laughActive,
        'sadActive': _sadActive,
        'angryActive': _angryActive,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'favoriteCount': serializeParam(_favoriteCount, ParamType.int),
        'peaceCount': serializeParam(_peaceCount, ParamType.int),
        'laughCount': serializeParam(_laughCount, ParamType.int),
        'sadCount': serializeParam(_sadCount, ParamType.int),
        'angryCount': serializeParam(_angryCount, ParamType.int),
        'favoriteActive': serializeParam(_favoriteActive, ParamType.bool),
        'peaceActive': serializeParam(_peaceActive, ParamType.bool),
        'laughActive': serializeParam(_laughActive, ParamType.bool),
        'sadActive': serializeParam(_sadActive, ParamType.bool),
        'angryActive': serializeParam(_angryActive, ParamType.bool),
      }.withoutNulls;

  static ReactionSummaryStructStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ReactionSummaryStructStruct(
        favoriteCount: deserializeParam(data['favoriteCount'], ParamType.int, false),
        peaceCount: deserializeParam(data['peaceCount'], ParamType.int, false),
        laughCount: deserializeParam(data['laughCount'], ParamType.int, false),
        sadCount: deserializeParam(data['sadCount'], ParamType.int, false),
        angryCount: deserializeParam(data['angryCount'], ParamType.int, false),
        favoriteActive: deserializeParam(data['favoriteActive'], ParamType.bool, false),
        peaceActive: deserializeParam(data['peaceActive'], ParamType.bool, false),
        laughActive: deserializeParam(data['laughActive'], ParamType.bool, false),
        sadActive: deserializeParam(data['sadActive'], ParamType.bool, false),
        angryActive: deserializeParam(data['angryActive'], ParamType.bool, false),
      );

  @override
  String toString() => 'ReactionSummaryStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ReactionSummaryStructStruct &&
        favoriteCount == other.favoriteCount &&
        peaceCount == other.peaceCount &&
        laughCount == other.laughCount &&
        sadCount == other.sadCount &&
        angryCount == other.angryCount &&
        favoriteActive == other.favoriteActive &&
        peaceActive == other.peaceActive &&
        laughActive == other.laughActive &&
        sadActive == other.sadActive &&
        angryActive == other.angryActive;
  }

  @override
  int get hashCode => const ListEquality().hash([
        favoriteCount,
        peaceCount,
        laughCount,
        sadCount,
        angryCount,
        favoriteActive,
        peaceActive,
        laughActive,
        sadActive,
        angryActive
      ]);
}

ReactionSummaryStructStruct createReactionSummaryStructStruct({
  int? favoriteCount,
  int? peaceCount,
  int? laughCount,
  int? sadCount,
  int? angryCount,
  bool? favoriteActive,
  bool? peaceActive,
  bool? laughActive,
  bool? sadActive,
  bool? angryActive,
}) =>
    ReactionSummaryStructStruct(
      favoriteCount: favoriteCount,
      peaceCount: peaceCount,
      laughCount: laughCount,
      sadCount: sadCount,
      angryCount: angryCount,
      favoriteActive: favoriteActive,
      peaceActive: peaceActive,
      laughActive: laughActive,
      sadActive: sadActive,
      angryActive: angryActive,
    );
