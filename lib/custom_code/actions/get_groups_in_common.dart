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

Future<List<GroupInCommonStructStruct>> getGroupsInCommon(
  String currentUserId,
  String otherUserId,
) async {
  final myConvRows = await SupaFlow.client
      .from('conversation_participants')
      .select('conversation_id')
      .eq('user_id', currentUserId);
  final myConvIds =
      myConvRows.map((r) => r['conversation_id'] as String).toList();

  if (myConvIds.isEmpty) return [];

  final theirConvRows = await SupaFlow.client
      .from('conversation_participants')
      .select('conversation_id')
      .eq('user_id', otherUserId)
      .inFilter('conversation_id', myConvIds);

  final sharedIds =
      theirConvRows.map((r) => r['conversation_id'] as String).toSet();
  if (sharedIds.isEmpty) return [];

  final groupRows = await SupaFlow.client
      .from('conversations')
      .select('id, name, avatar_url')
      .eq('type', 'group')
      .inFilter('id', sharedIds.toList());

  if (groupRows.isEmpty) return [];

  final groupIds = groupRows.map((g) => g['id'] as String).toList();

  final memberRows = await SupaFlow.client
      .from('conversation_participants')
      .select('conversation_id')
      .inFilter('conversation_id', groupIds);

  final memberCounts = <String, int>{};
  for (final row in memberRows) {
    final id = row['conversation_id'] as String;
    memberCounts[id] = (memberCounts[id] ?? 0) + 1;
  }

  return groupRows.map((g) {
    final id = g['id'] as String;
    return GroupInCommonStructStruct(
      groupId: id,
      groupName: (g['name'] as String?) ?? 'Group',
      groupAvatarUrl: (g['avatar_url'] as String?) ?? '',
      memberCount: memberCounts[id] ?? 0,
    );
  }).toList();
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
