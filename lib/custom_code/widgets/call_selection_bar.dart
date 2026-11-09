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

import '/app_state.dart';
import '/custom_code/actions/index.dart';

class CallSelectionBar extends StatelessWidget {
  const CallSelectionBar({
    super.key,
    this.width,
    this.height,
    required this.allCallIds,
    required this.onChanged,
  });

  final double? width;
  final double? height;
  final List<String> allCallIds;
  final Future Function() onChanged;

  static const Color _purple = Color(0xFF935CCC);
  static const Color _red = Color(0xFFDF1609);

  Future<void> _selectAll() async {
    FFAppState().update(() {
      FFAppState().selectedCallIds = List<String>.from(allCallIds);
    });
  }

  void _cancel() {
    FFAppState().update(() {
      FFAppState().callSelectionMode = false;
      FFAppState().selectedCallIds = [];
    });
  }

  Future<void> _delete() async {
    final ids = List<String>.from(FFAppState().selectedCallIds);
    if (ids.isEmpty) return;
    await deleteCalls(ids);
    FFAppState().update(() {
      FFAppState().callSelectionMode = false;
      FFAppState().selectedCallIds = [];
    });
    await onChanged();
  }

  Widget _button(IconData icon, String label, VoidCallback? onTap,
      {Color color = _purple}) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        height: 45,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            Text(label,
                maxLines: 1,
                style: TextStyle(
                    color: color, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FFAppState(),
      builder: (context, _) {
        final app = FFAppState();
        if (!app.callSelectionMode) return const SizedBox.shrink();

        final selected = app.selectedCallIds.length;
        final hasHistory = allCallIds.isNotEmpty;
        final showDelete = hasHistory && selected >= 1;
        final showGroupCall = hasHistory && selected >= 2;

        return SizedBox(
          width: width,
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _button(Icons.check_circle_outline_rounded, 'Select all',
                  hasHistory ? _selectAll : null),
              if (showGroupCall)
                _button(Icons.group_add_outlined, 'Group call', () {}),
              if (showDelete)
                _button(Icons.delete_outlined, 'Delete', _delete, color: _red),
              _button(Icons.close, 'Cancel', _cancel, color: Colors.black54),
            ],
          ),
        );
      },
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
