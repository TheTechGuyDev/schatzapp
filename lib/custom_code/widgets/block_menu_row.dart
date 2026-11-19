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

import '/custom_code/actions/index.dart';

class BlockMenuRow extends StatefulWidget {
  const BlockMenuRow({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
    required this.otherUserId,
  });

  final double? width;
  final double? height;
  final String currentUserId;
  final String otherUserId;

  @override
  State<BlockMenuRow> createState() => _BlockMenuRowState();
}

class _BlockMenuRowState extends State<BlockMenuRow> {
  static const Color _red = Color(0xFFE91414);
  static const Color _purple = Color(0xFF935CCC);

  bool _iBlocked = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await SupaFlow.client
          .rpc('block_status', params: {'p_other': widget.otherUserId});
      if (!mounted) return;
      setState(() => _iBlocked = (res ?? '').toString() == 'i_blocked');
    } catch (_) {}
  }

  Future<void> _tap() async {
    if (_busy) return;
    _busy = true;
    try {
      if (_iBlocked) {
        final done = await unblockUser(
            context, widget.currentUserId, widget.otherUserId);
        if (!done) return;
      } else {
        await blockUser(context, widget.currentUserId, widget.otherUserId);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _iBlocked ? _purple : _red;
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: _tap,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Row(
          children: [
            Icon(
              _iBlocked ? Icons.lock_open_rounded : Icons.block_sharp,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 15),
            Text(
              _iBlocked ? 'Unblock' : 'Block',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    color: color,
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
