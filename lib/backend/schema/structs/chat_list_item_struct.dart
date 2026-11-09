// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ChatListItemStruct extends BaseStruct {
  ChatListItemStruct({
    String? conversationId,
    String? type,
    String? displayName,
    String? displayAvatar,
    bool? isOnline,
    String? lastMessageContent,
    DateTime? lastMessageAt,
    bool? isMuted,
    int? unreadCount,
    bool? isArchived,
  })  : _conversationId = conversationId,
        _type = type,
        _displayName = displayName,
        _displayAvatar = displayAvatar,
        _isOnline = isOnline,
        _lastMessageContent = lastMessageContent,
        _lastMessageAt = lastMessageAt,
        _isMuted = isMuted,
        _unreadCount = unreadCount,
        _isArchived = isArchived;

  // "conversationId" field.
  String? _conversationId;
  String get conversationId => _conversationId ?? '';
  set conversationId(String? val) => _conversationId = val;

  bool hasConversationId() => _conversationId != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  set type(String? val) => _type = val;

  bool hasType() => _type != null;

  // "displayName" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  set displayName(String? val) => _displayName = val;

  bool hasDisplayName() => _displayName != null;

  // "displayAvatar" field.
  String? _displayAvatar;
  String get displayAvatar => _displayAvatar ?? '';
  set displayAvatar(String? val) => _displayAvatar = val;

  bool hasDisplayAvatar() => _displayAvatar != null;

  // "isOnline" field.
  bool? _isOnline;
  bool get isOnline => _isOnline ?? false;
  set isOnline(bool? val) => _isOnline = val;

  bool hasIsOnline() => _isOnline != null;

  // "lastMessageContent" field.
  String? _lastMessageContent;
  String get lastMessageContent => _lastMessageContent ?? '';
  set lastMessageContent(String? val) => _lastMessageContent = val;

  bool hasLastMessageContent() => _lastMessageContent != null;

  // "lastMessageAt" field.
  DateTime? _lastMessageAt;
  DateTime? get lastMessageAt => _lastMessageAt;
  set lastMessageAt(DateTime? val) => _lastMessageAt = val;

  bool hasLastMessageAt() => _lastMessageAt != null;

  // "isMuted" field.
  bool? _isMuted;
  bool get isMuted => _isMuted ?? false;
  set isMuted(bool? val) => _isMuted = val;

  bool hasIsMuted() => _isMuted != null;

  // "unreadCount" field.
  int? _unreadCount;
  int get unreadCount => _unreadCount ?? 0;
  set unreadCount(int? val) => _unreadCount = val;

  void incrementUnreadCount(int amount) => unreadCount = unreadCount + amount;

  bool hasUnreadCount() => _unreadCount != null;

  // "isArchived" field.
  bool? _isArchived;
  bool get isArchived => _isArchived ?? false;
  set isArchived(bool? val) => _isArchived = val;

  bool hasIsArchived() => _isArchived != null;

  static ChatListItemStruct fromMap(Map<String, dynamic> data) =>
      ChatListItemStruct(
        conversationId: data['conversationId'] as String?,
        type: data['type'] as String?,
        displayName: data['displayName'] as String?,
        displayAvatar: data['displayAvatar'] as String?,
        isOnline: data['isOnline'] as bool?,
        lastMessageContent: data['lastMessageContent'] as String?,
        lastMessageAt: data['lastMessageAt'] as DateTime?,
        isMuted: data['isMuted'] as bool?,
        unreadCount: castToType<int>(data['unreadCount']),
        isArchived: data['isArchived'] as bool?,
      );

  static ChatListItemStruct? maybeFromMap(dynamic data) => data is Map
      ? ChatListItemStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'conversationId': _conversationId,
        'type': _type,
        'displayName': _displayName,
        'displayAvatar': _displayAvatar,
        'isOnline': _isOnline,
        'lastMessageContent': _lastMessageContent,
        'lastMessageAt': _lastMessageAt,
        'isMuted': _isMuted,
        'unreadCount': _unreadCount,
        'isArchived': _isArchived,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'conversationId': serializeParam(
          _conversationId,
          ParamType.String,
        ),
        'type': serializeParam(
          _type,
          ParamType.String,
        ),
        'displayName': serializeParam(
          _displayName,
          ParamType.String,
        ),
        'displayAvatar': serializeParam(
          _displayAvatar,
          ParamType.String,
        ),
        'isOnline': serializeParam(
          _isOnline,
          ParamType.bool,
        ),
        'lastMessageContent': serializeParam(
          _lastMessageContent,
          ParamType.String,
        ),
        'lastMessageAt': serializeParam(
          _lastMessageAt,
          ParamType.DateTime,
        ),
        'isMuted': serializeParam(
          _isMuted,
          ParamType.bool,
        ),
        'unreadCount': serializeParam(
          _unreadCount,
          ParamType.int,
        ),
        'isArchived': serializeParam(
          _isArchived,
          ParamType.bool,
        ),
      }.withoutNulls;

  static ChatListItemStruct fromSerializableMap(Map<String, dynamic> data) =>
      ChatListItemStruct(
        conversationId: deserializeParam(
          data['conversationId'],
          ParamType.String,
          false,
        ),
        type: deserializeParam(
          data['type'],
          ParamType.String,
          false,
        ),
        displayName: deserializeParam(
          data['displayName'],
          ParamType.String,
          false,
        ),
        displayAvatar: deserializeParam(
          data['displayAvatar'],
          ParamType.String,
          false,
        ),
        isOnline: deserializeParam(
          data['isOnline'],
          ParamType.bool,
          false,
        ),
        lastMessageContent: deserializeParam(
          data['lastMessageContent'],
          ParamType.String,
          false,
        ),
        lastMessageAt: deserializeParam(
          data['lastMessageAt'],
          ParamType.DateTime,
          false,
        ),
        isMuted: deserializeParam(
          data['isMuted'],
          ParamType.bool,
          false,
        ),
        unreadCount: deserializeParam(
          data['unreadCount'],
          ParamType.int,
          false,
        ),
        isArchived: deserializeParam(
          data['isArchived'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'ChatListItemStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ChatListItemStruct &&
        conversationId == other.conversationId &&
        type == other.type &&
        displayName == other.displayName &&
        displayAvatar == other.displayAvatar &&
        isOnline == other.isOnline &&
        lastMessageContent == other.lastMessageContent &&
        lastMessageAt == other.lastMessageAt &&
        isMuted == other.isMuted &&
        unreadCount == other.unreadCount &&
        isArchived == other.isArchived;
  }

  @override
  int get hashCode => const ListEquality().hash([
        conversationId,
        type,
        displayName,
        displayAvatar,
        isOnline,
        lastMessageContent,
        lastMessageAt,
        isMuted,
        unreadCount,
        isArchived
      ]);
}

ChatListItemStruct createChatListItemStruct({
  String? conversationId,
  String? type,
  String? displayName,
  String? displayAvatar,
  bool? isOnline,
  String? lastMessageContent,
  DateTime? lastMessageAt,
  bool? isMuted,
  int? unreadCount,
  bool? isArchived,
}) =>
    ChatListItemStruct(
      conversationId: conversationId,
      type: type,
      displayName: displayName,
      displayAvatar: displayAvatar,
      isOnline: isOnline,
      lastMessageContent: lastMessageContent,
      lastMessageAt: lastMessageAt,
      isMuted: isMuted,
      unreadCount: unreadCount,
      isArchived: isArchived,
    );
