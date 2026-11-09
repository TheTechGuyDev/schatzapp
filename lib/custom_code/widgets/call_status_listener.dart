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

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class CallStatusListener extends StatefulWidget {
  const CallStatusListener({
    Key? key,
    this.width,
    this.height,
    required this.callId,
    required this.onAnswered,
    required this.onEnded,
    required this.onCallTypeChanged,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String callId;
  final Future Function() onAnswered;
  final Future Function() onEnded;
  final Future Function(String newCallType) onCallTypeChanged;

  @override
  State<CallStatusListener> createState() => _CallStatusListenerState();
}

class _CallStatusListenerState extends State<CallStatusListener> {
  RealtimeChannel? _channel;
  Timer? _pollTimer;
  bool _answeredHandled = false;
  bool _endedHandled = false;
  bool _videoUpgradeHandled = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _subscribe();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
  }

  void _subscribe() {
    debugPrint('CallStatusListener: subscribing for callId=${widget.callId}');
    _channel = SupaFlow.client
        .channel('call-status-${widget.callId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'calls',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: widget.callId,
          ),
          callback: (payload) async {
            final status = payload.newRecord['status'] as String?;
            final callType = payload.newRecord['call_type'] as String?;
            debugPrint(
                'CallStatusListener: received status="$status" call_type="$callType" for callId=${widget.callId}');
            await _applyStatus(status, callType);
          },
        )
        .subscribe((status, error) {
      debugPrint(
          'CallStatusListener: channel status=$status error=$error for callId=${widget.callId}');
    });
  }

  Future<void> _poll() async {
    if (_disposed) return;
    if (_answeredHandled && _endedHandled && _videoUpgradeHandled) {
      _pollTimer?.cancel();
      return;
    }
    try {
      final row = await SupaFlow.client
          .from('calls')
          .select('status, call_type')
          .eq('id', widget.callId)
          .maybeSingle()
          .timeout(const Duration(seconds: 5));
      if (row == null) return;
      final status = row['status'] as String?;
      final callType = row['call_type'] as String?;
      await _applyStatus(status, callType);
    } catch (e) {
      debugPrint(
          'CallStatusListener: poll failed for callId=${widget.callId}: $e');
    }
  }

  Future<void> _applyStatus(String? status, String? callType) async {
    if (_disposed) return;

    if (status == 'answered' && !_answeredHandled) {
      _answeredHandled = true;
      await widget.onAnswered();
    } else if ((status == 'declined' || status == 'ended') && !_endedHandled) {
      _endedHandled = true;
      await widget.onEnded();
    }

    if (callType == 'video' && !_videoUpgradeHandled) {
      _videoUpgradeHandled = true;
      await widget.onCallTypeChanged(callType!);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    debugPrint('CallStatusListener: disposing for callId=${widget.callId}');
    _pollTimer?.cancel();
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
