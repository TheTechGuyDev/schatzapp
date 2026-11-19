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

Future<List<StoryGroupStruct>> getFriendsStories(
  String currentUserId,
  bool? privateMode,
) async {
  final addedByMeRows = await SupaFlow.client
      .from('contacts')
      .select('contact_user_id')
      .eq('owner_id', currentUserId)
      .not('contact_user_id', 'is', null);

  final addedMeRows = await SupaFlow.client
      .from('contacts')
      .select('owner_id')
      .eq('contact_user_id', currentUserId)
      .not('owner_id', 'is', null);

  final friendIds = {
    ...addedByMeRows
        .map((row) => row['contact_user_id'] as String?)
        .whereType<String>(),
    ...addedMeRows.map((row) => row['owner_id'] as String?).whereType<String>(),
  }.toList();

  // Locked chats: the people this viewer has put in Private Chat.
  final lockedIds = <String>{};
  try {
    final lockedRows = await SupaFlow.client
        .from('chat_list_view')
        .select('other_user_id')
        .eq('is_locked', true)
        .neq('type', 'group');
    for (final r in lockedRows) {
      final id = r['other_user_id'] as String?;
      if (id != null) lockedIds.add(id);
    }
  } catch (_) {}

  var showLockedInNormal = false;
  try {
    final me = await SupaFlow.client
        .from('profiles')
        .select('show_locked_stories_in_normal')
        .eq('id', currentUserId)
        .maybeSingle();
    showLockedInNormal =
        (me?['show_locked_stories_in_normal'] as bool?) ?? false;
  } catch (_) {}

  if (privateMode == true) {
    // Inside Private Chat: only the locked contacts.
    friendIds.retainWhere(lockedIds.contains);
  } else if (!showLockedInNormal) {
    // Normal Stories: locked contacts stay hidden unless the toggle is on.
    friendIds.removeWhere(lockedIds.contains);
  }

  if (friendIds.isEmpty) return [];

  final nowIso = DateTime.now().toUtc().toIso8601String();

  final statusRows = await SupaFlow.client
      .from('statuses')
      .select()
      .inFilter('user_id', friendIds)
      .gt('expires_at', nowIso)
      .order('created_at', ascending: true);

  if (statusRows.isEmpty) return [];

  final activeUserIds =
      statusRows.map((row) => row['user_id'] as String).toSet().toList();

  final privacyRows = await SupaFlow.client
      .from('privacy_settings')
      .select('user_id, status_visibility')
      .inFilter('user_id', activeUserIds);
  final hiddenUserIds = privacyRows
      .where((row) => row['status_visibility'] == 'nobody')
      .map((row) => row['user_id'] as String)
      .toSet();
  final contactsOnlyUserIds = privacyRows
      .where((row) => row['status_visibility'] == 'contacts')
      .map((row) => row['user_id'] as String)
      .toSet();

  // 'contacts' visibility: show if the poster has the viewer saved as a
  // contact, OR if a conversation already exists between them.
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

  // Posters who have specifically hidden their status from the current
  // viewer, regardless of their general privacy setting.
  final hiddenFromMeRows = await SupaFlow.client
      .from('status_hidden_from')
      .select('owner_id')
      .eq('hidden_user_id', currentUserId)
      .inFilter('owner_id', activeUserIds);
  final hiddenFromMeUserIds =
      hiddenFromMeRows.map((row) => row['owner_id'] as String).toSet();

  // Story-specific visibility mode per poster ('everyone' / 'phone_number' /
  // 'custom'). Posters with no row default to 'everyone'.
  final storySettingsRows = await SupaFlow.client
      .from('story_settings')
      .select('user_id, view_visibility')
      .inFilter('user_id', activeUserIds);
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

  // For 'phone_number' posters: the poster must also have the viewer saved
  // in their own contacts (a mutual save), not just the other way around.
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

  // For 'custom' posters: the viewer must be in that poster's explicit
  // allow-list.
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
      .inFilter('id', activeUserIds);
  final profilesById = {
    for (final p in profileRows) p['id'] as String: p,
  };

  // Same naming rule as the chats: saved name, then username, then full name.
  final savedNameRows = await SupaFlow.client
      .from('contacts')
      .select('contact_user_id, saved_name')
      .eq('owner_id', currentUserId)
      .inFilter('contact_user_id', activeUserIds);
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

  final viewedRows = await SupaFlow.client
      .from('status_views')
      .select('status_id')
      .eq('viewer_id', currentUserId)
      .inFilter('status_id', statusRows.map((r) => r['id'] as String).toList());
  final viewedStatusIds =
      viewedRows.map((row) => row['status_id'] as String).toSet();

  final Map<String, List<StoryItemStruct>> itemsByUser = {};
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
    itemsByUser.putIfAbsent(userId, () => []).add(
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
            commentsEnabled: (row['comments_enabled'] as bool?) ?? true,
          ),
        );
  }

  return itemsByUser.entries.map((entry) {
    final profile = profilesById[entry.key];
    final hasUnviewed =
        entry.value.any((item) => !viewedStatusIds.contains(item.id));
    return StoryGroupStruct(
      userId: entry.key,
      fullName: nameFor(entry.key, profile),
      avatarUrl: (profile?['avatar_url'] as String?) ?? '',
      hasUnviewed: hasUnviewed,
      items: entry.value,
    );
  }).toList();
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
