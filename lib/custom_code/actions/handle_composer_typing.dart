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

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

final Map<String, RealtimeChannel> _composerTypingChannels = {};
final Map<String, Timer> _composerTypingTimers = {};

RealtimeChannel _composerTypingChannelFor(String conversationId) {
  return _composerTypingChannels.putIfAbsent(conversationId, () {
    final channel = SupaFlow.client.channel('typing-$conversationId');
    channel.subscribe();
    return channel;
  });
}

Future<void> handleComposerTyping(String conversationId, String userId) async {
  try {
    final channel = _composerTypingChannelFor(conversationId);
    await channel.sendBroadcastMessage(
      event: 'typing',
      payload: {'userId': userId, 'isTyping': true},
    );

    _composerTypingTimers[conversationId]?.cancel();
    _composerTypingTimers[conversationId] = Timer(
      const Duration(seconds: 4),
      () async {
        await channel.sendBroadcastMessage(
          event: 'typing',
          payload: {'userId': userId, 'isTyping': false},
        );
      },
    );
  } catch (e) {
    debugPrint('handleComposerTyping failed: $e');
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
