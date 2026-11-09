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

Future<List<CallHistoryEntryStruct>> getCallHistory(
  String currentUserId,
) async {
  final callRows = await SupaFlow.client
      .from('calls')
      .select()
      .or('caller_id.eq.$currentUserId,callee_id.eq.$currentUserId')
      .order('started_at', ascending: false)
      .limit(50);

  if (callRows.isEmpty) {
    return [];
  }

  // Batch-fetch profile info for every call where I was the CALLER, since
  // the calls table only stores the caller's name/avatar (for the
  // callee's incoming-call bubble) — when I'm the caller, I need to look
  // the other party's profile up myself.
  final outgoingCalleeIds = callRows
      .where((row) => row['caller_id'] == currentUserId)
      .map((row) => row['callee_id'] as String?)
      .whereType<String>()
      .toSet()
      .toList();

  final Map<String, Map<String, dynamic>> profilesById = {};
  if (outgoingCalleeIds.isNotEmpty) {
    final profileRows = await SupaFlow.client
        .from('profiles')
        .select('id, full_name, avatar_url')
        .inFilter('id', outgoingCalleeIds);
    for (final profile in profileRows) {
      profilesById[profile['id'] as String] = profile;
    }
  }

  return callRows.map((row) {
    final callerId = row['caller_id'] as String;
    final calleeId = row['callee_id'] as String?;
    final isOutgoing = callerId == currentUserId;
    final otherPartyId = isOutgoing ? (calleeId ?? '') : callerId;

    String otherPartyName;
    String otherPartyAvatar;
    if (isOutgoing) {
      final profile = profilesById[otherPartyId];
      otherPartyName = (profile?['full_name'] as String?) ?? '';
      otherPartyAvatar = (profile?['avatar_url'] as String?) ?? '';
    } else {
      otherPartyName = (row['caller_name'] as String?) ?? '';
      otherPartyAvatar = (row['caller_avatar'] as String?) ?? '';
    }

    final durationSeconds = row['duration_seconds'] as int?;
    final status = row['status'] as String?;

    String direction;
    if (isOutgoing) {
      direction = 'Outgoing';
    } else if (status == 'declined') {
      direction = 'Declined';
    } else if (durationSeconds != null && durationSeconds > 0) {
      direction = 'Incoming';
    } else {
      direction = 'Missed';
    }

    return CallHistoryEntryStruct(
      id: row['id'] as String,
      conversationId: row['conversation_id'] as String? ?? '',
      otherPartyId: otherPartyId,
      otherPartyName: otherPartyName,
      otherPartyAvatar: otherPartyAvatar,
      direction: direction,
      callType: (row['call_type'] as String?) ?? 'voice',
      startedAt: row['started_at'] != null
          ? DateTime.parse(row['started_at'] as String)
          : null,
      durationSeconds: durationSeconds,
    );
  }).toList();
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
