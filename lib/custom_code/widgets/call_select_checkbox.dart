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

class CallSelectCheckbox extends StatelessWidget {
  const CallSelectCheckbox({
    super.key,
    this.width,
    this.height,
    required this.callId,
  });

  final double? width;
  final double? height;
  final String callId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FFAppState(),
      builder: (context, _) {
        final app = FFAppState();
        if (!app.callSelectionMode) return const SizedBox.shrink();
        final isSelected = app.selectedCallIds.contains(callId);
        return InkWell(
          onTap: () {
            app.update(() {
              final updated = List<String>.from(app.selectedCallIds);
              if (isSelected) {
                updated.remove(callId);
              } else {
                updated.add(callId);
              }
              app.selectedCallIds = updated;
            });
          },
          child: SizedBox(
            width: width ?? 30,
            height: height ?? 30,
            child: Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF935CCC) : Colors.black26,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
