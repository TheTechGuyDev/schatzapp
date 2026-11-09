// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SavedContactResultStructStruct extends BaseStruct {
  SavedContactResultStructStruct({
    bool? success,
    String? errorMessage,
    String? savedName,
    String? phoneOrUsername,
    String? contactUserId,
    String? matchedAvatarUrl,
    String? matchedFullName,
  })  : _success = success,
        _errorMessage = errorMessage,
        _savedName = savedName,
        _phoneOrUsername = phoneOrUsername,
        _contactUserId = contactUserId,
        _matchedAvatarUrl = matchedAvatarUrl,
        _matchedFullName = matchedFullName;

  // "success" field.
  bool? _success;
  bool get success => _success ?? false;
  set success(bool? val) => _success = val;

  bool hasSuccess() => _success != null;

  // "errorMessage" field.
  String? _errorMessage;
  String get errorMessage => _errorMessage ?? '';
  set errorMessage(String? val) => _errorMessage = val;

  bool hasErrorMessage() => _errorMessage != null;

  // "savedName" field.
  String? _savedName;
  String get savedName => _savedName ?? '';
  set savedName(String? val) => _savedName = val;

  bool hasSavedName() => _savedName != null;

  // "phoneOrUsername" field.
  String? _phoneOrUsername;
  String get phoneOrUsername => _phoneOrUsername ?? '';
  set phoneOrUsername(String? val) => _phoneOrUsername = val;

  bool hasPhoneOrUsername() => _phoneOrUsername != null;

  // "contactUserId" field.
  String? _contactUserId;
  String get contactUserId => _contactUserId ?? '';
  set contactUserId(String? val) => _contactUserId = val;

  bool hasContactUserId() => _contactUserId != null;

  // "matchedAvatarUrl" field.
  String? _matchedAvatarUrl;
  String get matchedAvatarUrl => _matchedAvatarUrl ?? '';
  set matchedAvatarUrl(String? val) => _matchedAvatarUrl = val;

  bool hasMatchedAvatarUrl() => _matchedAvatarUrl != null;

  // "matchedFullName" field.
  String? _matchedFullName;
  String get matchedFullName => _matchedFullName ?? '';
  set matchedFullName(String? val) => _matchedFullName = val;

  bool hasMatchedFullName() => _matchedFullName != null;

  static SavedContactResultStructStruct fromMap(Map<String, dynamic> data) =>
      SavedContactResultStructStruct(
        success: data['success'] as bool?,
        errorMessage: data['errorMessage'] as String?,
        savedName: data['savedName'] as String?,
        phoneOrUsername: data['phoneOrUsername'] as String?,
        contactUserId: data['contactUserId'] as String?,
        matchedAvatarUrl: data['matchedAvatarUrl'] as String?,
        matchedFullName: data['matchedFullName'] as String?,
      );

  static SavedContactResultStructStruct? maybeFromMap(dynamic data) =>
      data is Map
          ? SavedContactResultStructStruct.fromMap(data.cast<String, dynamic>())
          : null;

  Map<String, dynamic> toMap() => {
        'success': _success,
        'errorMessage': _errorMessage,
        'savedName': _savedName,
        'phoneOrUsername': _phoneOrUsername,
        'contactUserId': _contactUserId,
        'matchedAvatarUrl': _matchedAvatarUrl,
        'matchedFullName': _matchedFullName,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'success': serializeParam(
          _success,
          ParamType.bool,
        ),
        'errorMessage': serializeParam(
          _errorMessage,
          ParamType.String,
        ),
        'savedName': serializeParam(
          _savedName,
          ParamType.String,
        ),
        'phoneOrUsername': serializeParam(
          _phoneOrUsername,
          ParamType.String,
        ),
        'contactUserId': serializeParam(
          _contactUserId,
          ParamType.String,
        ),
        'matchedAvatarUrl': serializeParam(
          _matchedAvatarUrl,
          ParamType.String,
        ),
        'matchedFullName': serializeParam(
          _matchedFullName,
          ParamType.String,
        ),
      }.withoutNulls;

  static SavedContactResultStructStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      SavedContactResultStructStruct(
        success: deserializeParam(
          data['success'],
          ParamType.bool,
          false,
        ),
        errorMessage: deserializeParam(
          data['errorMessage'],
          ParamType.String,
          false,
        ),
        savedName: deserializeParam(
          data['savedName'],
          ParamType.String,
          false,
        ),
        phoneOrUsername: deserializeParam(
          data['phoneOrUsername'],
          ParamType.String,
          false,
        ),
        contactUserId: deserializeParam(
          data['contactUserId'],
          ParamType.String,
          false,
        ),
        matchedAvatarUrl: deserializeParam(
          data['matchedAvatarUrl'],
          ParamType.String,
          false,
        ),
        matchedFullName: deserializeParam(
          data['matchedFullName'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'SavedContactResultStructStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is SavedContactResultStructStruct &&
        success == other.success &&
        errorMessage == other.errorMessage &&
        savedName == other.savedName &&
        phoneOrUsername == other.phoneOrUsername &&
        contactUserId == other.contactUserId &&
        matchedAvatarUrl == other.matchedAvatarUrl &&
        matchedFullName == other.matchedFullName;
  }

  @override
  int get hashCode => const ListEquality().hash([
        success,
        errorMessage,
        savedName,
        phoneOrUsername,
        contactUserId,
        matchedAvatarUrl,
        matchedFullName
      ]);
}

SavedContactResultStructStruct createSavedContactResultStructStruct({
  bool? success,
  String? errorMessage,
  String? savedName,
  String? phoneOrUsername,
  String? contactUserId,
  String? matchedAvatarUrl,
  String? matchedFullName,
}) =>
    SavedContactResultStructStruct(
      success: success,
      errorMessage: errorMessage,
      savedName: savedName,
      phoneOrUsername: phoneOrUsername,
      contactUserId: contactUserId,
      matchedAvatarUrl: matchedAvatarUrl,
      matchedFullName: matchedFullName,
    );
