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
  static const double _smallW = 150.0;
  static const double _smallH = 200.0;
  static const double _margin = 8.0;

  final GlobalKey _localKey = GlobalKey();
  final GlobalKey _remoteKey = GlobalKey();
  bool _isLocalFullScreen = false;
  Offset? _pos;

  void _swap() {
    setState(() {
      _isLocalFullScreen = !_isLocalFullScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget bigWidget = _isLocalFullScreen
        ? LocalVideoRenderer(
            key: _localKey,
            width: double.infinity,
            height: double.infinity,
          )
        : RemoteVideoRenderer(
            key: _remoteKey,
            width: double.infinity,
            height: double.infinity,
          );

    final Widget smallWidget = _isLocalFullScreen
        ? RemoteVideoRenderer(
            key: _remoteKey,
            width: _smallW,
            height: _smallH,
          )
        : LocalVideoRenderer(
            key: _localKey,
            width: _smallW,
            height: _smallH,
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final h = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height;
        final maxX = (w - _smallW - _margin).clamp(_margin, double.infinity);
        final maxY = (h - _smallH - _margin).clamp(_margin, double.infinity);

        _pos ??= Offset(maxX, ((h - _smallH) * 0.175).clamp(_margin, maxY));
        final pos = Offset(
          _pos!.dx.clamp(_margin, maxX),
          _pos!.dy.clamp(_margin, maxY),
        );

        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            children: [
              Positioned.fill(child: bigWidget),
              Positioned(
                left: pos.dx,
                top: pos.dy,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.0),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    width: _smallW,
                    height: _smallH,
                    child: Stack(
                      children: [
                        Positioned.fill(child: smallWidget),
                        // The video is a native platform view that steals
                        // touches, so an invisible layer on top catches the
                        // tap (swap) and the drag (move).
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _swap,
                            onPanUpdate: (d) {
                              setState(() {
                                final n = (_pos ?? pos) + d.delta;
                                _pos = Offset(
                                  n.dx.clamp(_margin, maxX),
                                  n.dy.clamp(_margin, maxY),
                                );
                              });
                            },
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
      },
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
