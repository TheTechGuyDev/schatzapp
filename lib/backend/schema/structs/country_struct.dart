// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CountryStruct extends BaseStruct {
  CountryStruct({
    String? name,
    String? dialCode,
    String? isoCode,
    String? flagUrl,
  })  : _name = name,
        _dialCode = dialCode,
        _isoCode = isoCode,
        _flagUrl = flagUrl;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  // "dialCode" field.
  String? _dialCode;
  String get dialCode => _dialCode ?? '';
  set dialCode(String? val) => _dialCode = val;

  bool hasDialCode() => _dialCode != null;

  // "isoCode" field.
  String? _isoCode;
  String get isoCode => _isoCode ?? '';
  set isoCode(String? val) => _isoCode = val;

  bool hasIsoCode() => _isoCode != null;

  // "flagUrl" field.
  String? _flagUrl;
  String get flagUrl => _flagUrl ?? '';
  set flagUrl(String? val) => _flagUrl = val;

  bool hasFlagUrl() => _flagUrl != null;

  static CountryStruct fromMap(Map<String, dynamic> data) => CountryStruct(
        name: data['name'] as String?,
        dialCode: data['dialCode'] as String?,
        isoCode: data['isoCode'] as String?,
        flagUrl: data['flagUrl'] as String?,
      );

  static CountryStruct? maybeFromMap(dynamic data) =>
      data is Map ? CountryStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'name': _name,
        'dialCode': _dialCode,
        'isoCode': _isoCode,
        'flagUrl': _flagUrl,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'dialCode': serializeParam(
          _dialCode,
          ParamType.String,
        ),
        'isoCode': serializeParam(
          _isoCode,
          ParamType.String,
        ),
        'flagUrl': serializeParam(
          _flagUrl,
          ParamType.String,
        ),
      }.withoutNulls;

  static CountryStruct fromSerializableMap(Map<String, dynamic> data) =>
      CountryStruct(
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        dialCode: deserializeParam(
          data['dialCode'],
          ParamType.String,
          false,
        ),
        isoCode: deserializeParam(
          data['isoCode'],
          ParamType.String,
          false,
        ),
        flagUrl: deserializeParam(
          data['flagUrl'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'CountryStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is CountryStruct &&
        name == other.name &&
        dialCode == other.dialCode &&
        isoCode == other.isoCode &&
        flagUrl == other.flagUrl;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([name, dialCode, isoCode, flagUrl]);
}

CountryStruct createCountryStruct({
  String? name,
  String? dialCode,
  String? isoCode,
  String? flagUrl,
}) =>
    CountryStruct(
      name: name,
      dialCode: dialCode,
      isoCode: isoCode,
      flagUrl: flagUrl,
    );
