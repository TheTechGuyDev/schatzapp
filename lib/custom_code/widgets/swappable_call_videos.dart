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

class SwappableCallVideos extends StatefulWidget {
  const SwappableCallVideos({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  State<SwappableCallVideos> createState() => _SwappableCallVideosState();
}

class _SwappableCallVideosState extends State<SwappableCallVideos> {
  bool _isLocalFullScreen = false;

  void _swap() {
    setState(() {
      _isLocalFullScreen = !_isLocalFullScreen;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'SWAP TAPPED',
          style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
        ),
        duration: const Duration(milliseconds: 4000),
        backgroundColor: FlutterFlowTheme.of(context).secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget bigWidget = _isLocalFullScreen
        ? const LocalVideoRenderer(
            key: ValueKey('local-renderer'),
            width: double.infinity,
            height: double.infinity,
          )
        : const RemoteVideoRenderer(
            key: ValueKey('remote-renderer'),
            width: double.infinity,
            height: double.infinity,
          );

    final Widget smallWidget = _isLocalFullScreen
        ? const RemoteVideoRenderer(
            key: ValueKey('remote-renderer'),
            width: 150.0,
            height: 200.0,
          )
        : const LocalVideoRenderer(
            key: ValueKey('local-renderer'),
            width: 150.0,
            height: 200.0,
          );

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          Positioned.fill(child: bigWidget),
          Align(
            alignment: const AlignmentDirectional(0.88, -0.65),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                width: 150.0,
                height: 200.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: FlutterFlowTheme.of(context).primary,
                    width: 2.0,
                  ),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: smallWidget,
                    ),
                    // The video above is a native platform view (a real
                    // HTML element on web), which intercepts taps before
                    // Flutter's own GestureDetector can see them. Placing
                    // an invisible, opaque-to-hit-testing layer ON TOP
                    // (instead of wrapping the video) is what actually
                    // catches the tap reliably.
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _swap,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
