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

import 'dart:math';

Future<List<StoryGroupStruct>> getForYouFeed(String currentUserId) async {
  final nowIso = DateTime.now().toUtc().toIso8601String();

  final statusRows = await SupaFlow.client
      .from('statuses')
      .select()
      .neq('user_id', currentUserId)
      .gt('expires_at', nowIso)
      .order('created_at', ascending: true);

  if (statusRows.isEmpty) return [];

  final posterIds =
      statusRows.map((row) => row['user_id'] as String).toSet().toList();

  final privacyRows = await SupaFlow.client
      .from('privacy_settings')
      .select('user_id, status_visibility')
      .inFilter('user_id', posterIds);
  final hiddenUserIds = privacyRows
      .where((row) => row['status_visibility'] == 'nobody')
      .map((row) => row['user_id'] as String)
      .toSet();
  final contactsOnlyUserIds = privacyRows
      .where((row) => row['status_visibility'] == 'contacts')
      .map((row) => row['user_id'] as String)
      .toSet();

  Set<String> contactsTierAllowedIds = {};
  if (contactsOnlyUserIds.isNotEmpty) {
    final contactRows = await SupaFlow.client
        .from('contacts')
        .select('owner_id')
        .inFilter('owner_id', contactsOnlyUserIds.toList())
        .eq('contact_user_id', currentUserId);
    contactsTierAllowedIds =
        contactRows.map((row) => row['owner_id'] as String).toSet();

    final convRows = await SupaFlow.client
        .from('conversations')
        .select('user_a_id, user_b_id')
        .or('user_a_id.eq.$currentUserId,user_b_id.eq.$currentUserId');
    for (final row in convRows) {
      final a = row['user_a_id'] as String?;
      final b = row['user_b_id'] as String?;
      final otherId = a == currentUserId ? b : a;
      if (otherId != null && contactsOnlyUserIds.contains(otherId)) {
        contactsTierAllowedIds.add(otherId);
      }
    }
  }

  final hiddenFromMeRows = await SupaFlow.client
      .from('status_hidden_from')
      .select('owner_id')
      .eq('hidden_user_id', currentUserId)
      .inFilter('owner_id', posterIds);
  final hiddenFromMeUserIds =
      hiddenFromMeRows.map((row) => row['owner_id'] as String).toSet();

  final storySettingsRows = await SupaFlow.client
      .from('story_settings')
      .select('user_id, view_visibility')
      .inFilter('user_id', posterIds);
  final visibilityByUser = {
    for (final row in storySettingsRows)
      row['user_id'] as String:
          (row['view_visibility'] as String?) ?? 'everyone',
  };

  final phoneNumberUserIds = visibilityByUser.entries
      .where((e) => e.value == 'phone_number')
      .map((e) => e.key)
      .toSet();
  final customUserIds = visibilityByUser.entries
      .where((e) => e.value == 'custom')
      .map((e) => e.key)
      .toSet();

  Set<String> mutualPosterIds = {};
  if (phoneNumberUserIds.isNotEmpty) {
    final mutualRows = await SupaFlow.client
        .from('contacts')
        .select('owner_id')
        .inFilter('owner_id', phoneNumberUserIds.toList())
        .eq('contact_user_id', currentUserId);
    mutualPosterIds =
        mutualRows.map((row) => row['owner_id'] as String).toSet();
  }

  Set<String> allowedCustomPosterIds = {};
  if (customUserIds.isNotEmpty) {
    final allowRows = await SupaFlow.client
        .from('story_custom_viewers')
        .select('owner_id')
        .inFilter('owner_id', customUserIds.toList())
        .eq('viewer_id', currentUserId);
    allowedCustomPosterIds =
        allowRows.map((row) => row['owner_id'] as String).toSet();
  }

  final profileRows = await SupaFlow.client
      .from('profiles')
      .select('id, full_name, username, avatar_url')
      .inFilter('id', posterIds);
  final profilesById = {
    for (final p in profileRows) p['id'] as String: p,
  };

  // Same naming rule as the chats: saved name, then username, then full name.
  final savedNameRows = await SupaFlow.client
      .from('contacts')
      .select('contact_user_id, saved_name')
      .eq('owner_id', currentUserId)
      .inFilter('contact_user_id', posterIds);
  final savedNameById = <String, String>{};
  for (final r in savedNameRows) {
    final n = ((r['saved_name'] as String?) ?? '').trim();
    final id = r['contact_user_id'] as String?;
    if (id != null && n.isNotEmpty) savedNameById[id] = n;
  }
  String nameFor(String id, Map<String, dynamic>? profile) {
    final saved = savedNameById[id];
    if (saved != null && saved.isNotEmpty) return saved;
    final uname = ((profile?['username'] as String?) ?? '').trim();
    if (uname.isNotEmpty) return uname;
    return ((profile?['full_name'] as String?) ?? '').trim();
  }

  // Group by batch_id when one is present (checked images from one posting
  // session), otherwise each status stands alone as its own card.
  final Map<String, List<StoryItemStruct>> itemsByGroup = {};
  final Map<String, String> posterIdByGroup = {};
  for (final row in statusRows) {
    final userId = row['user_id'] as String;
    if (hiddenUserIds.contains(userId)) continue;
    if (hiddenFromMeUserIds.contains(userId)) continue;
    if (contactsOnlyUserIds.contains(userId) &&
        !contactsTierAllowedIds.contains(userId)) continue;
    if (phoneNumberUserIds.contains(userId) &&
        !mutualPosterIds.contains(userId)) continue;
    if (customUserIds.contains(userId) &&
        !allowedCustomPosterIds.contains(userId)) continue;

    final batchId = row['batch_id'] as String?;
    final groupKey = (batchId != null && batchId.isNotEmpty)
        ? 'batch:$userId:$batchId'
        : 'solo:${row['id']}';

    posterIdByGroup[groupKey] = userId;
    itemsByGroup.putIfAbsent(groupKey, () => []).add(
          StoryItemStruct(
            id: row['id'] as String,
            mediaUrl: (row['media_url'] as String?) ?? '',
            mediaType: (row['media_type'] as String?) ?? 'image',
            caption: (row['caption'] as String?) ?? '',
            backgroundColor: (row['background_color'] as String?) ?? '',
            createdAt: row['created_at'] != null
                ? DateTime.parse(row['created_at'] as String)
                : null,
            fontIndex: (row['text_font_index'] as int?) ?? 0,
          ),
        );
  }

  if (itemsByGroup.isEmpty) return [];

  final List<StoryGroupStruct> flattened = itemsByGroup.entries.map((entry) {
    final posterId = posterIdByGroup[entry.key]!;
    final profile = profilesById[posterId];
    return StoryGroupStruct(
      userId: posterId,
      fullName: nameFor(posterId, profile),
      avatarUrl: (profile?['avatar_url'] as String?) ?? '',
      hasUnviewed: true,
      items: entry.value,
    );
  }).toList();

  final eligiblePosterIds = flattened.map((g) => g.userId).toSet().toList();
  final viewHistory = await SupaFlow.client
      .from('status_views')
      .select('status_id, statuses!inner(user_id)')
      .eq('viewer_id', currentUserId)
      .inFilter('statuses.user_id', eligiblePosterIds);

  final Map<String, int> affinityByPoster = {};
  for (final row in viewHistory) {
    final statusData = row['statuses'];
    final posterId =
        statusData is Map ? statusData['user_id'] as String? : null;
    if (posterId == null) continue;
    affinityByPoster[posterId] = (affinityByPoster[posterId] ?? 0) + 1;
  }

  // Weighted random shuffle without replacement, weight = affinity + 1.
  // Every poster now appears exactly once in the pool (their stories are
  // merged into a single group), so no "avoid same poster twice" check is
  // needed any more.
  final random = Random();
  final pool = List<StoryGroupStruct>.from(flattened);
  final List<StoryGroupStruct> result = [];

  while (pool.isNotEmpty) {
    final weights =
        pool.map((g) => (affinityByPoster[g.userId] ?? 0) + 1).toList();
    final totalWeight = weights.fold<int>(0, (a, b) => a + b);
    var roll = random.nextInt(totalWeight);

    int pickIndex = 0;
    for (var i = 0; i < pool.length; i++) {
      roll -= weights[i];
      if (roll < 0) {
        pickIndex = i;
        break;
      }
    }

    result.add(pool.removeAt(pickIndex));
  }

  return result;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
