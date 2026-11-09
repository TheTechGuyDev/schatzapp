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

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

String _key(String phone) {
  final d = phone.replaceAll(RegExp(r'[^0-9]'), '');
  return d.length > 10 ? d.substring(d.length - 10) : d;
}

Future<int> syncDeviceContacts(
  String currentUserId,
  String currentUserPhoneNumber,
) async {
  if (kIsWeb) return 0;

  final permission = await FlutterContacts.permissions.request(
    PermissionType.readWrite,
  );
  if (permission != PermissionStatus.granted) {
    return 0;
  }

  final deviceContacts = await FlutterContacts.getAll(
    properties: {ContactProperty.name, ContactProperty.phone},
  );

  IsoCode? callerIsoCode;
  try {
    final normalizedCaller = currentUserPhoneNumber.startsWith('+')
        ? currentUserPhoneNumber
        : '+$currentUserPhoneNumber';
    callerIsoCode = PhoneNumber.parse(normalizedCaller).isoCode;
  } catch (_) {
    callerIsoCode = null;
  }

  // One entry per number (last 10 digits), so the same person is never
  // added twice.
  final deviceByKey = <String, MapEntry<String, String>>{};
  final myKey = _key(currentUserPhoneNumber);
  for (final contact in deviceContacts) {
    final name = contact.displayName ?? '';
    if (name.isEmpty || contact.phones.isEmpty) continue;

    for (final phone in contact.phones) {
      final raw = phone.number;
      if (raw.trim().isEmpty) continue;

      String normalized;
      try {
        final parsed = callerIsoCode != null
            ? PhoneNumber.parse(raw, callerCountry: callerIsoCode)
            : PhoneNumber.parse(raw.startsWith('+') ? raw : '+$raw');
        if (!parsed.isValid()) continue;
        normalized = parsed.international.replaceFirst('+', '');
      } catch (_) {
        continue;
      }

      final k = _key(normalized);
      if (k == myKey) continue;
      deviceByKey.putIfAbsent(k, () => MapEntry(normalized, name));
    }
  }

  // What this user already has saved.
  final existingRows = await SupaFlow.client
      .from('contacts')
      .select('id, phone_number, contact_user_id, source')
      .eq('owner_id', currentUserId);

  final rowByKey = <String, Map<String, dynamic>>{};
  final rowByUser = <String, Map<String, dynamic>>{};
  for (final r in existingRows) {
    final p = (r['phone_number'] as String?) ?? '';
    if (p.isNotEmpty) rowByKey[_key(p)] = r;
    final u = r['contact_user_id'] as String?;
    if (u != null) rowByUser[u] = r;
  }

  // Registered users among the device numbers.
  final phoneList = deviceByKey.values.map((e) => e.key).toList();
  final profileByKey = <String, String>{};
  if (phoneList.isNotEmpty) {
    final matchedProfiles = await SupaFlow.client
        .from('profiles')
        .select('id, phone_number')
        .inFilter('phone_number', phoneList);
    for (final row in matchedProfiles) {
      final p = (row['phone_number'] as String?) ?? '';
      if (p.isNotEmpty) profileByKey[_key(p)] = row['id'] as String;
    }
  }

  final toInsert = <Map<String, dynamic>>[];
  for (final entry in deviceByKey.entries) {
    final k = entry.key;
    final phone = entry.value.key;
    final name = entry.value.value;
    final userId = profileByKey[k];

    final byPhone = rowByKey[k];
    final byUser = userId != null ? rowByUser[userId] : null;
    final existing = byPhone ?? byUser;

    if (existing != null) {
      // Never change the name the user already saved. Only fill gaps.
      final patch = <String, dynamic>{};
      if (existing['contact_user_id'] == null && userId != null) {
        patch['contact_user_id'] = userId;
      }
      if (((existing['phone_number'] as String?) ?? '').isEmpty) {
        patch['phone_number'] = phone;
      }
      if (patch.isNotEmpty) {
        await SupaFlow.client
            .from('contacts')
            .update(patch)
            .eq('id', existing['id']);
      }
      continue;
    }

    toInsert.add({
      'owner_id': currentUserId,
      'contact_user_id': userId,
      'saved_name': name,
      'phone_number': phone,
      'source': 'device',
    });
  }

  if (toInsert.isNotEmpty) {
    await SupaFlow.client.from('contacts').insert(toInsert);
  }

  // Remove contacts that came from the phone and are no longer on it.
  // Contacts added inside the app are never removed here.
  final staleIds = <dynamic>[];
  for (final r in existingRows) {
    final p = (r['phone_number'] as String?) ?? '';
    if (p.isEmpty) continue;
    if (r['source'] != 'device') continue;
    if (!deviceByKey.containsKey(_key(p))) staleIds.add(r['id']);
  }
  if (staleIds.isNotEmpty) {
    await SupaFlow.client.from('contacts').delete().inFilter('id', staleIds);
  }

  return deviceByKey.length;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
