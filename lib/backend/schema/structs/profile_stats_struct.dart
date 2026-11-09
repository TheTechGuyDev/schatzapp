// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ProfileStatsStruct extends BaseStruct {
  ProfileStatsStruct({
    int? mediaCount,
    int? linksCount,
    int? filesCount,
    int? groupsInCommonCount,
    int? mutualContactsCount,
    String? conversationId,
  })  : _mediaCount = mediaCount,
        _linksCount = linksCount,
        _filesCount = filesCount,
        _groupsInCommonCount = groupsInCommonCount,
        _mutualContactsCount = mutualContactsCount,
        _conversationId = conversationId;

  // "mediaCount" field.
  int? _mediaCount;
  int get mediaCount => _mediaCount ?? 0;
  set mediaCount(int? val) => _mediaCount = val;

  void incrementMediaCount(int amount) => mediaCount = mediaCount + amount;

  bool hasMediaCount() => _mediaCount != null;

  // "linksCount" field.
  int? _linksCount;
  int get linksCount => _linksCount ?? 0;
  set linksCount(int? val) => _linksCount = val;

  void incrementLinksCount(int amount) => linksCount = linksCount + amount;

  bool hasLinksCount() => _linksCount != null;

  // "filesCount" field.
  int? _filesCount;
  int get filesCount => _filesCount ?? 0;
  set filesCount(int? val) => _filesCount = val;

  void incrementFilesCount(int amount) => filesCount = filesCount + amount;

  bool hasFilesCount() => _filesCount != null;

  // "groupsInCommonCount" field.
  int? _groupsInCommonCount;
  int get groupsInCommonCount => _groupsInCommonCount ?? 0;
  set groupsInCommonCount(int? val) => _groupsInCommonCount = val;

  void incrementGroupsInCommonCount(int amount) =>
      groupsInCommonCount = groupsInCommonCount + amount;

  bool hasGroupsInCommonCount() => _groupsInCommonCount != null;

  // "mutualContactsCount" field.
  int? _mutualContactsCount;
  int get mutualContactsCount => _mutualContactsCount ?? 0;
  set mutualContactsCount(int? val) => _mutualContactsCount = val;

  void incrementMutualContactsCount(int amount) =>
      mutualContactsCount = mutualContactsCount + amount;

  bool hasMutualContactsCount() => _mutualContactsCount != null;

  // "conversationId" field.
  String? _conversationId;
  String get conversationId => _conversationId ?? '';
  set conversationId(String? val) => _conversationId = val;

  bool hasConversationId() => _conversationId != null;

  static ProfileStatsStruct fromMap(Map<String, dynamic> data) =>
      ProfileStatsStruct(
        mediaCount: castToType<int>(data['mediaCount']),
        linksCount: castToType<int>(data['linksCount']),
        filesCount: castToType<int>(data['filesCount']),
        groupsInCommonCount: castToType<int>(data['groupsInCommonCount']),
        mutualContactsCount: castToType<int>(data['mutualContactsCount']),
        conversationId: data['conversationId'] as String?,
      );

  static ProfileStatsStruct? maybeFromMap(dynamic data) => data is Map
      ? ProfileStatsStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'mediaCount': _mediaCount,
        'linksCount': _linksCount,
        'filesCount': _filesCount,
        'groupsInCommonCount': _groupsInCommonCount,
        'mutualContactsCount': _mutualContactsCount,
        'conversationId': _conversationId,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'mediaCount': serializeParam(
          _mediaCount,
          ParamType.int,
        ),
        'linksCount': serializeParam(
          _linksCount,
          ParamType.int,
        ),
        'filesCount': serializeParam(
          _filesCount,
          ParamType.int,
        ),
        'groupsInCommonCount': serializeParam(
          _groupsInCommonCount,
          ParamType.int,
        ),
        'mutualContactsCount': serializeParam(
          _mutualContactsCount,
          ParamType.int,
        ),
        'conversationId': serializeParam(
          _conversationId,
          ParamType.String,
        ),
      }.withoutNulls;

  static ProfileStatsStruct fromSerializableMap(Map<String, dynamic> data) =>
      ProfileStatsStruct(
        mediaCount: deserializeParam(
          data['mediaCount'],
          ParamType.int,
          false,
        ),
        linksCount: deserializeParam(
          data['linksCount'],
          ParamType.int,
          false,
        ),
        filesCount: deserializeParam(
          data['filesCount'],
          ParamType.int,
          false,
        ),
        groupsInCommonCount: deserializeParam(
          data['groupsInCommonCount'],
          ParamType.int,
          false,
        ),
        mutualContactsCount: deserializeParam(
          data['mutualContactsCount'],
          ParamType.int,
          false,
        ),
        conversationId: deserializeParam(
          data['conversationId'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'ProfileStatsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ProfileStatsStruct &&
        mediaCount == other.mediaCount &&
        linksCount == other.linksCount &&
        filesCount == other.filesCount &&
        groupsInCommonCount == other.groupsInCommonCount &&
        mutualContactsCount == other.mutualContactsCount &&
        conversationId == other.conversationId;
  }

  @override
  int get hashCode => const ListEquality().hash([
        mediaCount,
        linksCount,
        filesCount,
        groupsInCommonCount,
        mutualContactsCount,
        conversationId
      ]);
}

ProfileStatsStruct createProfileStatsStruct({
  int? mediaCount,
  int? linksCount,
  int? filesCount,
  int? groupsInCommonCount,
  int? mutualContactsCount,
  String? conversationId,
}) =>
    ProfileStatsStruct(
      mediaCount: mediaCount,
      linksCount: linksCount,
      filesCount: filesCount,
      groupsInCommonCount: groupsInCommonCount,
      mutualContactsCount: mutualContactsCount,
      conversationId: conversationId,
    );
