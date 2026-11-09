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

Future<ProfileStatsStruct> getProfileStats(
  String currentUserId,
  String otherUserId,
) async {
  // Find the existing direct (1:1) conversation between these two users,
  // without creating one. Read-only, just for counting.
  final myConvRows = await SupaFlow.client
      .from('conversation_participants')
      .select('conversation_id')
      .eq('user_id', currentUserId);
  final myConvIds =
      myConvRows.map((r) => r['conversation_id'] as String).toList();

  String? directConversationId;
  int groupsInCommonCount = 0;
  if (myConvIds.isNotEmpty) {
    final theirRows = await SupaFlow.client
        .from('conversation_participants')
        .select('conversation_id')
        .eq('user_id', otherUserId)
        .inFilter('conversation_id', myConvIds);
    if (theirRows.isNotEmpty) {
      final sharedIds =
          theirRows.map((r) => r['conversation_id'] as String).toSet().toList();
      final convRows = await SupaFlow.client
          .from('conversations')
          .select('id, type')
          .inFilter('id', sharedIds);
      for (final c in convRows) {
        if (c['type'] == 'direct' && directConversationId == null) {
          directConversationId = c['id'] as String;
        }
        if (c['type'] == 'group') groupsInCommonCount++;
      }
    }
  }

  int mediaCount = 0;
  int linksCount = 0;
  int filesCount = 0;
  if (directConversationId != null) {
    // Same rules as the Media, Links and Files page, so the numbers match.
    final rows = await SupaFlow.client
        .from('messages')
        .select(
            'message_type, content, media_url, media_urls, deleted_for_user_ids')
        .eq('conversation_id', directConversationId)
        .not('is_deleted', 'eq', true);
    final urlPattern =
        RegExp(r'((https?:\/\/)|(www\.))[^\s]+', caseSensitive: false);
    for (final m in rows) {
      final hidden =
          (m['deleted_for_user_ids'] as List?)?.contains(currentUserId) == true;
      if (hidden) continue;
      final type = (m['message_type'] as String?) ?? '';
      final single = (m['media_url'] as String?) ?? '';
      final list = (m['media_urls'] as List?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ??
          <String>[];
      if (type == 'image' || type == 'image_group') {
        mediaCount +=
            list.isNotEmpty ? list.length : (single.isNotEmpty ? 1 : 0);
      } else if (type == 'video') {
        if (single.isNotEmpty) mediaCount++;
      } else if (type == 'document') {
        if (single.isNotEmpty) filesCount++;
      } else if (type == 'text') {
        final content = (m['content'] as String?) ?? '';
        linksCount += urlPattern.allMatches(content).length;
      }
    }
  }

  // Mutual contacts: people both users have saved.
  final myContactRows = await SupaFlow.client
      .from('contacts')
      .select('contact_user_id')
      .eq('owner_id', currentUserId)
      .not('contact_user_id', 'is', null);
  final myContactIds = myContactRows
      .map((r) => r['contact_user_id'] as String?)
      .whereType<String>()
      .toSet();

  int mutualContactsCount = 0;
  if (myContactIds.isNotEmpty) {
    final theirContactRows = await SupaFlow.client
        .from('contacts')
        .select('contact_user_id')
        .eq('owner_id', otherUserId)
        .not('contact_user_id', 'is', null);
    final theirContactIds = theirContactRows
        .map((r) => r['contact_user_id'] as String?)
        .whereType<String>()
        .toSet();
    mutualContactsCount = myContactIds.intersection(theirContactIds).length;
  }

  return ProfileStatsStruct(
    mediaCount: mediaCount,
    linksCount: linksCount,
    filesCount: filesCount,
    groupsInCommonCount: groupsInCommonCount,
    mutualContactsCount: mutualContactsCount,
    conversationId: directConversationId ?? '',
  );
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
