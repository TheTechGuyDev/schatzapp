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
      .from('profiles')
      .select('id, full_name, phone_number, avatar_url')
      .inFilter('id', blockedIds);

  final profileById = {
    for (final p in profileRows) p['id'] as String: p,
  };

  return blockedRows.map((r) {
    final id = r['blocked_id'] as String;
    final profile = profileById[id];
    return BlockedUserStructStruct(
      blockedUserId: id,
      fullName: (profile?['full_name'] as String?) ?? 'Unknown',
      phoneNumber: (profile?['phone_number'] as String?) ?? '',
      avatarUrl: (profile?['avatar_url'] as String?) ?? '',
    );
  }).toList();
}
