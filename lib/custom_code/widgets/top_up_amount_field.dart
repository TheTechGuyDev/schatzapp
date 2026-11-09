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

import 'package:google_fonts/google_fonts.dart';
import '/app_state.dart';

class TopUpAmountField extends StatefulWidget {
  const TopUpAmountField({
    super.key,
    this.width,
    this.height,
    required this.onAmountChanged,
  });

  final double? width;
  final double? height;
  final Future Function() onAmountChanged;

  @override
  State<TopUpAmountField> createState() => _TopUpAmountFieldState();
}

class _TopUpAmountFieldState extends State<TopUpAmountField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    FFAppState().topUpTypedAmount = 0.0;
    FFAppState().addListener(_syncFromAppState);
  }

  // Preset buttons (50 / 100 / 150) set App State without notifying
  // listeners, but they rebuild the page, so sync on every rebuild too.
  @override
  void didUpdateWidget(covariant TopUpAmountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncFromAppState();
  }

  @override
  void dispose() {
    FFAppState().removeListener(_syncFromAppState);
    _controller.dispose();
    super.dispose();
  }

  // When a preset button (50 / 100 / 150) changes the amount, show it here.
  void _syncFromAppState() {
    final amount = FFAppState().topUpTypedAmount;
    if (parseAmountInput(_controller.text) == amount) return;
    final text = amount == 0
        ? ''
        : (amount == amount.roundToDouble()
            ? amount.toStringAsFixed(0)
            : amount.toString());
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Center(
        child: TextFormField(
          controller: _controller,
          textAlignVertical: TextAlignVertical.center,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (text) {
            final value = parseAmountInput(text);
            FFAppState().update(() {
              FFAppState().topUpTypedAmount = value;
            });
            widget.onAmountChanged();
          },
          style: theme.bodyMedium.override(
            font: GoogleFonts.plusJakartaSans(),
            fontSize: 16.0,
            letterSpacing: 0.0,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Enter Amount',
            hintStyle: theme.labelMedium.override(
              font: GoogleFonts.plusJakartaSans(),
              letterSpacing: 0.0,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
