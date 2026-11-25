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

/// WhatsApp chat order for rows from chat_list_view:
/// 1. Pinned chats first, newest pin on top (pinned_at DESC). A new message
///    never moves a pinned chat.
/// 2. Then unpinned chats by last_message_at DESC.
///
/// chat_list_view has no pinned_at, so it is read from
/// conversation_participants (set by a DB trigger, never by the app) and
/// copied into each row as 'pinned_at'. If that fetch fails, any pinned_at
/// already on the rows (e.g. from cache) is kept.
Future<List<Map<String, dynamic>>> sortChatRowsWhatsApp(
  List<Map<String, dynamic>> rows,
) async {
  final uid = SupaFlow.client.auth.currentUser?.id;
  if (uid != null && rows.any((r) => r['is_pinned'] == true)) {
    try {
      final data = await SupaFlow.client
          .from('conversation_participants')
          .select('conversation_id, pinned_at')
          .eq('user_id', uid)
          .eq('is_pinned', true);
      final pinnedAt = <String, String?>{
        for (final p in data)
          '${p['conversation_id']}': p['pinned_at'] as String?,
      };
      for (final r in rows) {
        final id = '${r['conversation_id']}';
        r['pinned_at'] = r['is_pinned'] == true ? pinnedAt[id] : null;
      }
    } catch (_) {
      // Keep whatever pinned_at the rows already carry.
    }
  }
  return sortChatRowsLocal(rows);
}

/// Same order as [sortChatRowsWhatsApp] using the 'pinned_at' already on the
/// rows (no network). Use after local changes to a list.
List<Map<String, dynamic>> sortChatRowsLocal(List<Map<String, dynamic>> rows) {
  DateTime? at(Map<String, dynamic> r, String key) =>
      DateTime.tryParse('${r[key] ?? ''}');

  int desc(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1; // nulls last
    if (b == null) return -1;
    return b.compareTo(a);
  }

  final sorted = List<Map<String, dynamic>>.from(rows);
  sorted.sort((a, b) {
    final ap = a['is_pinned'] == true;
    final bp = b['is_pinned'] == true;
    if (ap != bp) return ap ? -1 : 1;

    var c = ap
        ? desc(at(a, 'pinned_at'), at(b, 'pinned_at'))
        : desc(at(a, 'last_message_at'), at(b, 'last_message_at'));
    // Pinned chats with no pinned_at yet (older pins): fall back to the
    // last message, then the id, so the order is stable.
    if (c == 0 && ap) {
      c = desc(at(a, 'last_message_at'), at(b, 'last_message_at'));
    }
    if (c == 0) {
      c = '${a['conversation_id']}'.compareTo('${b['conversation_id']}');
    }
    return c;
  });
  return sorted;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
