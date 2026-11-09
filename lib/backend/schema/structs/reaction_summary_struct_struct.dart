// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ReactionSummaryStructStruct extends BaseStruct {
  ReactionSummaryStructStruct({
    int? favoriteCount,
    int? peaceCount,
    int? thumbsCount,
    bool? favoriteActive,
    bool? peaceActive,
    bool? thumbsActive,
  })  : _favoriteCount = favoriteCount,
        _peaceCount = peaceCount,
        _thumbsCount = thumbsCount,
        _favoriteActive = favoriteActive,
        _peaceActive = peaceActive,
        _thumbsActive = thumbsActive;

  // "favoriteCount" field.
  int? _favoriteCount;
  int get favoriteCount => _favoriteCount ?? 0;
  set favoriteCount(int? val) => _favoriteCount = val;

  void incrementFavoriteCount(int amount) =>
      favoriteCount = favoriteCount + amount;

  bool hasFavoriteCount() => _favoriteCount != null;

  // "peaceCount" field.
  int? _peaceCount;
  int get peaceCount => _peaceCount ?? 0;
  set peaceCount(int? val) => _peaceCount = val;

  void incrementPeaceCount(int amount) => peaceCount = peaceCount + amount;

  bool hasPeaceCount() => _peaceCount != null;

  // "thumbsCount" field.
  int? _thumbsCount;
  int get thumbsCount => _thumbsCount ?? 0;
  set thumbsCount(int? val) => _thumbsCount = val;

  void incrementThumbsCount(int amount) => thumbsCount = thumbsCount + amount;

  bool hasThumbsCount() => _thumbsCount != null;

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

  // "thumbsActive" field.
  bool? _thumbsActive;
  bool get thumbsActive => _thumbsActive ?? false;
  set thumbsActive(bool? val) => _thumbsActive = val;

  bool hasThumbsActive() => _thumbsActive != null;

  static ReactionSummaryStructStruct fromMap(Map<String, dynamic> data) =>
      ReactionSummaryStructStruct(
        favoriteCount: castToType<int>(data['favoriteCount']),
        peaceCount: castToType<int>(data['peaceCount']),
        thumbsCount: castToType<int>(data['thumbsCount']),
        favoriteActive: data['favoriteActive'] as bool?,
        peaceActive: data['peaceActive'] as bool?,
        thumbsActive: data['thumbsActive'] as bool?,
      );

  static ReactionSummaryStructStruct? maybeFromMap(dynamic data) => data is Map
      ? ReactionSummaryStructStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'favoriteCount': _favoriteCount,
        'peaceCount': _peaceCount,
        'thumbsCount': _thumbsCount,
        'favoriteActive': _favoriteActive,
        'peaceActive': _peaceActive,
        'thumbsActive': _thumbsActive,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'favoriteCount': serializeParam(
          _favoriteCount,
          ParamType.int,
        ),
        'peaceCount': serializeParam(
          _peaceCount,
          ParamType.int,
        ),
        'thumbsCount': serializeParam(
          _thumbsCount,
          ParamType.int,
        ),
        'favoriteActive': serializeParam(
          _favoriteActive,
          ParamType.bool,
        ),
        'peaceActive': serializeParam(
          _peaceActive,
          ParamType.bool,
        ),
        'thumbsActive': serializeParam(
          _thumbsActive,
          ParamType.bool,
        ),
      }.withoutNulls;

  static ReactionSummaryStructStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ReactionSummaryStructStruct(
        favoriteCount: deserializeParam(
          data['favoriteCount'],
          ParamType.int,
          false,
        ),
        peaceCount: deserializeParam(
          data['peaceCount'],
          ParamType.int,
          false,
        ),
        thumbsCount: deserializeParam(
          data['thumbsCount'],
          ParamType.int,
          false,
        ),
        favoriteActive: deserializeParam(
          data['favoriteActive'],
          ParamType.bool,
          false,
        ),
        peaceActive: deserializeParam(
          data['peaceActive'],
          ParamType.bool,
          false,
        ),
        thumbsActive: deserializeParam(
          data['thumbsActive'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'ReactionSummaryStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ReactionSummaryStructStruct &&
        favoriteCount == other.favoriteCount &&
        peaceCount == other.peaceCount &&
        thumbsCount == other.thumbsCount &&
        favoriteActive == other.favoriteActive &&
        peaceActive == other.peaceActive &&
        thumbsActive == other.thumbsActive;
  }

  @override
  int get hashCode => const ListEquality().hash([
        favoriteCount,
        peaceCount,
        thumbsCount,
        favoriteActive,
        peaceActive,
        thumbsActive
      ]);
}

ReactionSummaryStructStruct createReactionSummaryStructStruct({
  int? favoriteCount,
  int? peaceCount,
  int? thumbsCount,
  bool? favoriteActive,
  bool? peaceActive,
  bool? thumbsActive,
}) =>
    ReactionSummaryStructStruct(
      favoriteCount: favoriteCount,
      peaceCount: peaceCount,
      thumbsCount: thumbsCount,
      favoriteActive: favoriteActive,
      peaceActive: peaceActive,
      thumbsActive: thumbsActive,
    );
