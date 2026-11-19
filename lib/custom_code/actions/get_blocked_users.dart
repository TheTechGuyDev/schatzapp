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

Future<List<BlockedUserStructStruct>> getBlockedUsers(
  String currentUserId,
) async {
  final blockedRows = await SupaFlow.client
      .from('blocked_users')
      .select('id, blocked_id, created_at')
      .eq('blocker_id', currentUserId)
      .order('created_at', ascending: false);

  if (blockedRows.isEmpty) return [];

  final blockedIds = blockedRows.map((r) => r['blocked_id'] as String).toList();

  final profileRows = await SupaFlow.client
      .from('profiles_public')
      .select('id, full_name, username, phone_number, avatar_url')
      .inFilter('id', blockedIds);

  final profileById = {
    for (final p in profileRows) p['id'] as String: p,
  };

  // Same name order as the chat list: saved contact name, then username,
  // then full name, then phone number.
  final savedNameById = <String, String>{};
  try {
    final contactRows = await SupaFlow.client
        .from('contacts')
        .select('contact_user_id, saved_name')
        .eq('owner_id', currentUserId)
        .inFilter('contact_user_id', blockedIds);
    for (final c in contactRows) {
      final id = c['contact_user_id'] as String?;
      final name = c['saved_name'] as String?;
      if (id != null && name != null && name.trim().isNotEmpty) {
        savedNameById[id] = name;
      }
    }
  } catch (_) {}

  String clean(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

  return blockedRows.map((r) {
    final id = r['blocked_id'] as String;
    final profile = profileById[id];
    final username = clean((profile?['username'] as String?) ?? '');
    final fullName = clean((profile?['full_name'] as String?) ?? '');
    final phone = (profile?['phone_number'] as String?) ?? '';
    String name = clean(savedNameById[id] ?? '');
    if (name.isEmpty) name = username;
    if (name.isEmpty) name = fullName;
    if (name.isEmpty) name = phone.isNotEmpty ? phone : 'Unknown';
    return BlockedUserStructStruct(
      blockedUserId: id,
      fullName: name,
      phoneNumber: phone,
      avatarUrl: (profile?['avatar_url'] as String?) ?? '',
    );
  }).toList();
}
