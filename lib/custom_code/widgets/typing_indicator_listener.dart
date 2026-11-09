// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class TypingIndicatorListener extends StatefulWidget {
  const TypingIndicatorListener({
    Key? key,
    this.width,
    this.height,
    required this.conversationId,
    required this.otherUserId,
    required this.onTypingChanged,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String conversationId;
  final String otherUserId;
  final Future Function(bool isTyping) onTypingChanged;

  @override
  State<TypingIndicatorListener> createState() =>
      _TypingIndicatorListenerState();
}

class _TypingIndicatorListenerState extends State<TypingIndicatorListener> {
  RealtimeChannel? _channel;
  Timer? _staleTimer;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    _channel = SupaFlow.client
        .channel('typing-${widget.conversationId}')
        .onBroadcast(
          event: 'typing',
          callback: (payload) {
            final userId = payload['userId'] as String?;
            final isTyping = payload['isTyping'] as bool? ?? false;
            if (userId != widget.otherUserId) return;
            _staleTimer?.cancel();
            widget.onTypingChanged(isTyping);
            if (isTyping) {
              _staleTimer = Timer(const Duration(seconds: 6), () {
                if (!_disposed) widget.onTypingChanged(false);
              });
            }
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _disposed = true;
    _staleTimer?.cancel();
    if (_channel != null) {
      SupaFlow.client.removeChannel(_channel!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
