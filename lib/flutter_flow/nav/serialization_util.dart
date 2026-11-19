import 'dart:convert';

import 'package:flutter/material.dart';

import '/backend/schema/structs/index.dart';

import '/backend/supabase/supabase.dart';

import '../../flutter_flow/place.dart';
import '../../flutter_flow/uploaded_file.dart';

/// SERIALIZATION HELPERS

String dateTimeToString(DateTime dateTime) =>
    '${dateTime.isUtc ? 'u' : 'l'}${dateTime.millisecondsSinceEpoch}';

String dateTimeRangeToString(DateTimeRange dateTimeRange) {
  final start = dateTimeRange.start;
  final end = dateTimeRange.end;
  final startStr = '${start.isUtc ? 'u' : 'l'}${start.millisecondsSinceEpoch}';
  final endStr = '${end.isUtc ? 'u' : 'l'}${end.millisecondsSinceEpoch}';
  return '$startStr|$endStr';
}

String placeToString(FFPlace place) => jsonEncode({
      'latLng': place.latLng.serialize(),
      'name': place.name,
      'address': place.address,
      'city': place.city,
      'state': place.state,
      'country': place.country,
      'zipCode': place.zipCode,
    });

String uploadedFileToString(FFUploadedFile uploadedFile) =>
    uploadedFile.serialize();

String? serializeParam(
  dynamic param,
  ParamType paramType, {
  bool isList = false,
}) {
  try {
    if (param == null) {
      return null;
    }
    if (isList) {
      final serializedValues = (param as Iterable)
          .map((p) => serializeParam(p, paramType, isList: false))
          .where((p) => p != null)
          .map((p) => p!)
          .toList();
      return json.encode(serializedValues);
    }
    String? data;
    switch (paramType) {
      case ParamType.int:
        data = param.toString();
      case ParamType.double:
        data = param.toString();
      case ParamType.String:
        data = param;
      case ParamType.bool:
        data = param ? 'true' : 'false';
      case ParamType.DateTime:
        data = dateTimeToString(param as DateTime);
      case ParamType.DateTimeRange:
        data = dateTimeRangeToString(param as DateTimeRange);
      case ParamType.LatLng:
        data = (param as LatLng).serialize();
      case ParamType.Color:
        data = (param as Color).toCssString();
      case ParamType.FFPlace:
        data = placeToString(param as FFPlace);
      case ParamType.FFUploadedFile:
        data = uploadedFileToString(param as FFUploadedFile);
      case ParamType.JSON:
        data = json.encode(param);

      case ParamType.DataStruct:
        data = param is BaseStruct ? param.serialize() : null;

      case ParamType.SupabaseRow:
        return json.encode((param as SupabaseDataRow).data);

      default:
        data = null;
    }
    return data;
  } catch (e) {
    print('Error serializing parameter: $e');
    return null;
  }
}

/// END SERIALIZATION HELPERS

/// DESERIALIZATION HELPERS

DateTime? dateTimeFromString(String? dateTimeStr) {
  if (dateTimeStr == null || dateTimeStr.isEmpty) {
    return null;
  }
  final hasPrefix = dateTimeStr.startsWith('u') || dateTimeStr.startsWith('l');
  final milliseconds = int.tryParse(
    hasPrefix ? dateTimeStr.substring(1) : dateTimeStr,
  );
  return milliseconds != null
      ? DateTime.fromMillisecondsSinceEpoch(
          milliseconds,
          isUtc: hasPrefix ? dateTimeStr.startsWith('u') : false,
        )
      : null;
}

DateTimeRange? dateTimeRangeFromString(String dateTimeRangeStr) {
  final pieces = dateTimeRangeStr.split('|');
  if (pieces.length != 2) {
    return null;
  }
  DateTime? parseDateTime(String value) {
    final hasPrefix = value.startsWith('u') || value.startsWith('l');
    final milliseconds = int.tryParse(hasPrefix ? value.substring(1) : value);
    return milliseconds != null
        ? DateTime.fromMillisecondsSinceEpoch(
            milliseconds,
            isUtc: hasPrefix ? value.startsWith('u') : false,
          )
        : null;
  }

  final start = parseDateTime(pieces.first);
  final end = parseDateTime(pieces.last);
  if (start == null || end == null) {
    return null;
  }
  return DateTimeRange(
    start: start,
    end: end,
  );
}

LatLng? latLngFromString(String? latLngStr) {
  final pieces = latLngStr?.split(',');
  if (pieces == null || pieces.length != 2) {
    return null;
  }
  return LatLng(
    double.parse(pieces.first.trim()),
    double.parse(pieces.last.trim()),
  );
}

FFPlace placeFromString(String placeStr) {
  final serializedData = jsonDecode(placeStr) as Map<String, dynamic>;
  final data = {
    'latLng': serializedData.containsKey('latLng')
        ? latLngFromString(serializedData['latLng'] as String)
        : const LatLng(0.0, 0.0),
    'name': serializedData['name'] ?? '',
    'address': serializedData['address'] ?? '',
    'city': serializedData['city'] ?? '',
    'state': serializedData['state'] ?? '',
    'country': serializedData['country'] ?? '',
    'zipCode': serializedData['zipCode'] ?? '',
  };
  return FFPlace(
    latLng: data['latLng'] as LatLng,
    name: data['name'] as String,
    address: data['address'] as String,
    city: data['city'] as String,
    state: data['state'] as String,
    country: data['country'] as String,
    zipCode: data['zipCode'] as String,
  );
}

FFUploadedFile uploadedFileFromString(String uploadedFileStr) =>
    FFUploadedFile.deserialize(uploadedFileStr);

enum ParamType {
  int,
  double,
  String,
  bool,
  DateTime,
  DateTimeRange,
  LatLng,
  Color,
  FFPlace,
  FFUploadedFile,
  JSON,

  DataStruct,
  SupabaseRow,
}

dynamic deserializeParam<T>(
  String? param,
  ParamType paramType,
  bool isList, {
  StructBuilder<T>? structBuilder,
}) {
  try {
    if (param == null) {
      return null;
    }
    if (isList) {
      final paramValues = json.decode(param);
      if (paramValues is! Iterable || paramValues.isEmpty) {
        return null;
      }
      return paramValues
          .where((p) => p is String)
          .map((p) => p as String)
          .map((p) => deserializeParam<T>(
                p,
                paramType,
                false,
                structBuilder: structBuilder,
              ))
          .where((p) => p != null)
          .map((p) => p! as T)
          .toList();
    }
    switch (paramType) {
      case ParamType.int:
        return int.tryParse(param);
      case ParamType.double:
        return double.tryParse(param);
      case ParamType.String:
        return param;
      case ParamType.bool:
        return param == 'true';
      case ParamType.DateTime:
        return dateTimeFromString(param);
      case ParamType.DateTimeRange:
        return dateTimeRangeFromString(param);
      case ParamType.LatLng:
        return latLngFromString(param);
      case ParamType.Color:
        return fromCssColor(param);
      case ParamType.FFPlace:
        return placeFromString(param);
      case ParamType.FFUploadedFile:
        return uploadedFileFromString(param);
      case ParamType.JSON:
        return json.decode(param);

      case ParamType.SupabaseRow:
        final data = json.decode(param) as Map<String, dynamic>;
        switch (T) {
          case AccountNumberSequencesRow:
            return AccountNumberSequencesRow(data);
          case ActiveIncomingCallsRow:
            return ActiveIncomingCallsRow(data);
          case AppConfigRow:
            return AppConfigRow(data);
          case BankTransferSettingsRow:
            return BankTransferSettingsRow(data);
          case BlockedUsersRow:
            return BlockedUsersRow(data);
          case CallJoinRequestsRow:
            return CallJoinRequestsRow(data);
          case CallLinksRow:
            return CallLinksRow(data);
          case CallParticipantsRow:
            return CallParticipantsRow(data);
          case CallsRow:
            return CallsRow(data);
          case CamouflageProfilesRow:
            return CamouflageProfilesRow(data);
          case ChatListViewRow:
            return ChatListViewRow(data);
          case ContactsRow:
            return ContactsRow(data);
          case ContactsDirectoryRow:
            return ContactsDirectoryRow(data);
          case ConversationParticipantsRow:
            return ConversationParticipantsRow(data);
          case ConversationParticipantsDirectoryRow:
            return ConversationParticipantsDirectoryRow(data);
          case ConversationsRow:
            return ConversationsRow(data);
          case GiftCardsRow:
            return GiftCardsRow(data);
          case IncomingCallsForUserRow:
            return IncomingCallsForUserRow(data);
          case KycSubmissionsRow:
            return KycSubmissionsRow(data);
          case LinksRow:
            return LinksRow(data);
          case MessageDeletionsRow:
            return MessageDeletionsRow(data);
          case MessageReactionsRow:
            return MessageReactionsRow(data);
          case MessageReportsRow:
            return MessageReportsRow(data);
          case MessageStarsRow:
            return MessageStarsRow(data);
          case MessageStatusRow:
            return MessageStatusRow(data);
          case MessagesRow:
            return MessagesRow(data);
          case MessagesWithReplyRow:
            return MessagesWithReplyRow(data);
          case NameChangeRequestsRow:
            return NameChangeRequestsRow(data);
          case NotificationsRow:
            return NotificationsRow(data);
          case OtpRateLimitRow:
            return OtpRateLimitRow(data);
          case PrivacySettingsRow:
            return PrivacySettingsRow(data);
          case PrivateGroupAuditRow:
            return PrivateGroupAuditRow(data);
          case PrivateStoryRingViewRow:
            return PrivateStoryRingViewRow(data);
          case ProfilesRow:
            return ProfilesRow(data);
          case ProfilesPublicRow:
            return ProfilesPublicRow(data);
          case ReloadlyTokensRow:
            return ReloadlyTokensRow(data);
          case SavedCardsRow:
            return SavedCardsRow(data);
          case SchatzGiftcardsRow:
            return SchatzGiftcardsRow(data);
          case ScheduledCallsRow:
            return ScheduledCallsRow(data);
          case StatusHiddenFromRow:
            return StatusHiddenFromRow(data);
          case StatusReactionsRow:
            return StatusReactionsRow(data);
          case StatusTagsRow:
            return StatusTagsRow(data);
          case StatusViewsRow:
            return StatusViewsRow(data);
          case StatusesRow:
            return StatusesRow(data);
          case StoryCustomViewersRow:
            return StoryCustomViewersRow(data);
          case StoryRingViewRow:
            return StoryRingViewRow(data);
          case StorySettingsRow:
            return StorySettingsRow(data);
          case SupportedCountriesRow:
            return SupportedCountriesRow(data);
          case SyncedContactsRow:
            return SyncedContactsRow(data);
          case UnsupportedCountrySignupAttemptsRow:
            return UnsupportedCountrySignupAttemptsRow(data);
          case UserDevicesRow:
            return UserDevicesRow(data);
          case WalletTopupsRow:
            return WalletTopupsRow(data);
          case WalletTransactionsRow:
            return WalletTransactionsRow(data);
          case WalletsRow:
            return WalletsRow(data);
          default:
            return null;
        }

      case ParamType.DataStruct:
        final data = json.decode(param) as Map<String, dynamic>? ?? {};
        return structBuilder != null ? structBuilder(data) : null;

      default:
        return null;
    }
  } catch (e) {
    print('Error deserializing parameter: $e');
    return null;
  }
}
