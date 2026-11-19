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
import '/custom_code/actions/index.dart';
import '/app_state.dart';

class BlockStatusBar extends StatefulWidget {
  const BlockStatusBar({
    super.key,
    this.width,
    this.height,
    required this.otherUserId,
    required this.showBanner,
  });

  final double? width;
  final double? height;
  final String otherUserId;
  final bool showBanner;

  @override
  State<BlockStatusBar> createState() => _BlockStatusBarState();
}

class _BlockStatusBarState extends State<BlockStatusBar> {
  static const Color _purple = Color(0xFF935CCC);

  String _status = 'none';
  Timer? _timer;
  bool _busy = false;

  bool get _dark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _refresh());
  }

  @override
  void didUpdateWidget(covariant BlockStatusBar old) {
    super.didUpdateWidget(old);
    if (old.otherUserId != widget.otherUserId) _refresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (!widget.showBanner) {
      Future.microtask(() {
        if (FFAppState().chatBlocked) {
          FFAppState().update(() => FFAppState().chatBlocked = false);
        }
      });
    }
    super.dispose();
  }

  Future<void> _refresh() async {
    if (widget.otherUserId.isEmpty) return;
    try {
      final res = await SupaFlow.client
          .rpc('block_status', params: {'p_other': widget.otherUserId});
      final s = (res ?? 'none').toString();
      if (!mounted) return;
      if (s != _status) setState(() => _status = s);
      if (!widget.showBanner) {
        final blocked = s != 'none';
        if (FFAppState().chatBlocked != blocked) {
          FFAppState().update(() => FFAppState().chatBlocked = blocked);
        }
      }
    } catch (_) {}
  }

  Future<void> _unblock() async {
    if (_busy) return;
    final me = SupaFlow.client.auth.currentUser?.id;
    if (me == null) return;
    _busy = true;
    try {
      final done = await unblockUser(context, me, widget.otherUserId);
      if (done) await _refresh();
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showBanner || _status == 'none') {
      return SizedBox(width: widget.width, height: widget.height);
    }
    final mine = _status == 'i_blocked';
    return Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _dark ? const Color(0xFF2A1F3F) : const Color(0xFFF2EEF8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.block, color: _purple, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mine
                  ? 'You blocked this contact.'
                  : 'You have been blocked by this contact.',
              style: TextStyle(
                color: _dark ? Colors.white : const Color(0xFF1B1230),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (mine)
            TextButton(
              onPressed: _unblock,
              child: const Text(
                'Unblock',
                style: TextStyle(
                    color: _purple, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
