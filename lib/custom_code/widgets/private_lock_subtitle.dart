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

class PrivateLockSubtitle extends StatefulWidget {
  const PrivateLockSubtitle({
    Key? key,
    this.width,
    this.height,
    required this.conversationId,
    this.isGroup = false,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String conversationId;
  final bool isGroup;

  @override
  State<PrivateLockSubtitle> createState() => _PrivateLockSubtitleState();
}

class _PrivateLockSubtitleState extends State<PrivateLockSubtitle> {
  bool _locked = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant PrivateLockSubtitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversationId != widget.conversationId ||
        oldWidget.isGroup != widget.isGroup) {
      _load();
    }
  }

  // Reads this user's own lock state, so each person sees the text that
  // matches what they have done.
  Future<void> _load() async {
    final id = widget.conversationId;
    if (id.isEmpty) return;
    final value =
        widget.isGroup ? await isGroupPrivate(id) : await isMyPrivateLock(id);
    if (!mounted || id != widget.conversationId) return;
    setState(() {
      _locked = value;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = !_loaded
        ? ''
        : _locked
            ? 'Unlock and unhide this chat on this device.'
            : 'Lock and hide this chat on this device.';
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                color: FlutterFlowTheme.of(context).secondaryText,
                fontSize: 13.0,
                letterSpacing: 0.0,
              ),
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
