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

import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletPinKeypad extends StatefulWidget {
  const WalletPinKeypad({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  State<WalletPinKeypad> createState() => _WalletPinKeypadState();
}

class _WalletPinKeypadState extends State<WalletPinKeypad> {
  bool _isVerifying = false;

  Future<void> _onDigitTap(String digit) async {
    if (_isVerifying) return;
    var buffer = FFAppState().walletPinBuffer;
    if (buffer.length >= 6) return;
    buffer += digit;
    FFAppState().update(() {
      FFAppState().walletPinBuffer = buffer;
    });
    setState(() {});
    if (buffer.length == 6) {
      setState(() {
        _isVerifying = true;
      });
      final result = await actions.verifyWalletPin(buffer);
      if (!mounted) return;
      if (result == true) {
        FFAppState().update(() {
          FFAppState().walletPinResult = true;
        });
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Incorrect PIN, please try again',
              style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
            ),
            duration: const Duration(milliseconds: 4000),
            backgroundColor: FlutterFlowTheme.of(context).secondary,
          ),
        );
        FFAppState().update(() {
          FFAppState().walletPinBuffer = '';
        });
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  void _onBackspace() {
    if (_isVerifying) return;
    var buffer = FFAppState().walletPinBuffer;
    if (buffer.isEmpty) return;
    buffer = buffer.substring(0, buffer.length - 1);
    FFAppState().update(() {
      FFAppState().walletPinBuffer = buffer;
    });
    setState(() {});
  }

  Widget _dots(String buffer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        final filled = index < buffer.length;
        return Container(
          width: 44.0,
          height: 50.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: filled
                  ? FlutterFlowTheme.of(context).primary
                  : FlutterFlowTheme.of(context).primary.withOpacity(0.3),
              width: 2.0,
            ),
          ),
          child: Text(
            filled ? buffer[index] : '',
            style: FlutterFlowTheme.of(context).bodyLarge.override(
                  font: GoogleFonts.plusJakartaSans(),
                  letterSpacing: 0.0,
                ),
          ),
        );
      }),
    );
  }

  Widget _key({String? label, VoidCallback? onTap, Widget? child}) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 55.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Align(
          alignment: Alignment.center,
          child: child ??
              Text(
                label ?? '',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800),
                      fontSize: 22.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w800,
                    ),
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const digits = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
    final buffer = FFAppState().walletPinBuffer;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dots(buffer),
          const SizedBox(height: 20.0),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              mainAxisExtent: 55.0,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              if (index < 9) {
                final d = digits[index];
                return _key(label: d, onTap: () => _onDigitTap(d));
              } else if (index == 9) {
                return const SizedBox.shrink();
              } else if (index == 10) {
                return _key(label: '0', onTap: () => _onDigitTap('0'));
              } else {
                return InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: _onBackspace,
                  child: Container(
                    width: double.infinity,
                    height: 55.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Icon(
                      Icons.close_sharp,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 24.0,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
