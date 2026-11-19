// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<SavedContactResultStructStruct> lookupContactPreview(
  String ownerId,
  String query,
  String mode,
  String? dialCode,
) async {
  SavedContactResultStructStruct none() => SavedContactResultStructStruct(
        success: false,
        errorMessage: '',
        savedName: '',
        phoneOrUsername: query,
        contactUserId: '',
        matchedAvatarUrl: '',
        matchedFullName: '',
      );

  try {
    Map<String, dynamic>? found;

    if (mode == 'username') {
      final u = query.trim().replaceFirst(RegExp(r'^@+'), '').toLowerCase();
      if (u.length < 2) return none();
      final pattern = u.replaceAllMapped(RegExp(r'[\\%_]'), (m) => '\\${m[0]}');
      final rows = await SupaFlow.client
          .from('profiles')
          .select('id, full_name, avatar_url')
          .ilike('username', pattern)
          .limit(1);
      if (rows.isNotEmpty) found = Map<String, dynamic>.from(rows.first);
    } else {
      final dial = (dialCode ?? '').replaceAll(RegExp(r'[^0-9]'), '');
      var digits = query.replaceAll(RegExp(r'[^0-9]'), '');
      String key;
      String national;
      if (dial.isEmpty) {
        key =
            digits.length > 10 ? digits.substring(digits.length - 10) : digits;
        national = key;
      } else {
        if (query.trim().startsWith('+') && digits.startsWith(dial)) {
          digits = digits.substring(dial.length);
        }
        national = digits.replaceFirst(RegExp(r'^0+'), '');
        key = dial + national;
      }
      if (national.length < 7) return none();
      final tail = national.length > 9
          ? national.substring(national.length - 9)
          : national;

      final rows = await SupaFlow.client
          .from('profiles')
          .select('id, full_name, avatar_url, phone_number')
          .ilike('phone_number', '%$tail')
          .limit(25);
      for (final r in (rows as List)) {
        final cd = ((r['phone_number'] ?? '') as String)
            .replaceAll(RegExp(r'[^0-9]'), '');
        final ok = cd.endsWith(key) ||
            (dial == '234' &&
                national.length >= 10 &&
                cd.endsWith(national.substring(national.length - 10)));
        if (ok) {
          found = Map<String, dynamic>.from(r as Map);
          break;
        }
      }
    }

    if (found == null) return none();
    final id = (found['id'] as String?) ?? '';
    if (id == ownerId) return none();
    return SavedContactResultStructStruct(
      success: true,
      errorMessage: '',
      savedName: '',
      phoneOrUsername: query,
      contactUserId: id,
      matchedAvatarUrl: (found['avatar_url'] as String?) ?? '',
      matchedFullName: (found['full_name'] as String?) ?? '',
    );
  } catch (e) {
    return none();
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
