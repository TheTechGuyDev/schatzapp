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

import '/flutter_flow/nav/nav.dart';

Future<void> confirmRemovePrivateGroup(String conversationId) async {
  final ctx = appNavigatorKey.currentContext;
  if (ctx == null) return;

  bool isConverted = false;
  try {
    final row = await SupaFlow.client
        .from('conversations')
        .select('private_origin')
        .eq('id', conversationId)
        .maybeSingle();
    isConverted = row?['private_origin'] == 'converted';
  } catch (_) {}

  final message = isConverted
      ? 'Removing this group from Private Chat Lock will permanently delete all messages exchanged while the group was in Private Chat Lock. This action cannot be undone.'
      : 'Removing this group from Private Chat Lock will permanently delete the group and its messages. This action cannot be undone.';

  final confirmed = await showDialog<bool>(
        context: ctx,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Remove from Private Chat Lock'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Remove'),
              ),
            ],
          );
        },
      ) ??
      false;

  if (confirmed) {
    final removed = await removePrivateGroup(conversationId);
    final after = appNavigatorKey.currentContext;
    if (after == null) return;
    if (removed) {
      after.goNamed('HomePage');
      return;
    }
    ScaffoldMessenger.of(after).showSnackBar(
      const SnackBar(content: Text('Could not remove the group')),
    );
  }

  // Cancelled or failed: reload the page so the switch matches the database.
  final reload = appNavigatorKey.currentContext;
  if (reload == null) return;
  reload.goNamed(
    'Group_profile_Details_page',
    queryParameters: {'groupConversationId': conversationId},
  );
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
