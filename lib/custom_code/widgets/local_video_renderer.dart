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

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '/custom_code/actions/join_agora_call.dart';
import '/auth/supabase_auth/auth_util.dart';
import 'dart:async';

class LocalVideoRenderer extends StatefulWidget {
  const LocalVideoRenderer({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  State<LocalVideoRenderer> createState() => _LocalVideoRendererState();
}

// Last known shape (width / height) of the camera picture, shared by every
// renderer so a swap never starts from a guess.
double _kLocalAspect = 3 / 4;

class _LocalVideoRendererState extends State<LocalVideoRenderer> {
  RtcEngineEventHandler? _sizeHandler;
  bool _engineReady = false;
  Timer? _refreshTimer;
  VideoViewController? _controller;
  double? _controllerWidth;
  double? _controllerHeight;
  int _version = 0;

  @override
  void initState() {
    super.initState();
    _waitForEngine();
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    final engine = AgoraCallManager.engine;
    if (engine != null && _sizeHandler != null) {
      try {
        engine.unregisterEventHandler(_sizeHandler!);
      } catch (_) {}
    }
    _controller?.dispose();
    super.dispose();
  }

  void _setAspect(int w, int h, [int rotation = 0]) {
    if (w <= 0 || h <= 0) return;
    final turned = rotation == 90 || rotation == 270;
    final a = turned ? h / w : w / h;
    if ((a - _kLocalAspect).abs() < 0.001) return;
    _kLocalAspect = a;
    if (mounted) setState(() {});
  }

  void _listenForPictureSize(RtcEngine engine) {
    if (_sizeHandler != null) return;
    _sizeHandler = RtcEngineEventHandler(
      onVideoSizeChanged: (connection, sourceType, uid, width, height, rot) {
        if (uid == 0) _setAspect(width, height, rot);
      },
      onFirstLocalVideoFrame: (source, width, height, elapsed) {
        _setAspect(width, height);
      },
    );
    try {
      engine.registerEventHandler(_sizeHandler!);
    } catch (_) {}
  }

  Future<void> _waitForEngine() async {
    while (AgoraCallManager.engine == null) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
    }
    if (mounted) setState(() => _engineReady = true);
  }

  VideoViewController _makeController(RtcEngine engine) {
    _version++;
    return VideoViewController(
      rtcEngine: engine,
      canvas: const VideoCanvas(
        uid: 0,
        renderMode: RenderModeType.renderModeHidden,
      ),
    );
  }

  // Builds a fresh controller whenever the view changes size (small preview
  // to full screen and back), then once more shortly after, so the newest
  // setup always wins over the old view being torn down.
  void _ensureController(RtcEngine engine) {
    final changed = _controller == null ||
        _controllerWidth != widget.width ||
        _controllerHeight != widget.height;
    if (!changed) return;

    _controller?.dispose();
    _controller = _makeController(engine);
    _controllerWidth = widget.width;
    _controllerHeight = widget.height;

    final versionAtCreate = _version;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || versionAtCreate != _version) return;
      final e = AgoraCallManager.engine;
      if (e == null) return;
      _controller?.dispose();
      _controller = _makeController(e);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final engine = AgoraCallManager.engine;
    if (!_engineReady || engine == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black26,
      );
    }

    // The view stays mounted for the whole call, including while video is
    // off. Muting is handled at the Agora stream level (toggleVideo).
    _listenForPictureSize(engine);
    _ensureController(engine);

    final avatarSize = (widget.width ?? 60.0) * 0.5;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The camera view is sized to the picture's own shape, then
          // enlarged until it covers the whole area and trimmed at the
          // edges, so it fills the screen with no black bars.
          LayoutBuilder(
            builder: (context, box) {
              final w = box.maxWidth.isFinite ? box.maxWidth : 150.0;
              final h = box.maxHeight.isFinite ? box.maxHeight : 200.0;
              final a = _kLocalAspect;
              final coverW = (w / h > a) ? w : h * a;
              final coverH = (w / h > a) ? w / a : h;
              return ClipRect(
                child: OverflowBox(
                  minWidth: coverW,
                  maxWidth: coverW,
                  minHeight: coverH,
                  maxHeight: coverH,
                  child: SizedBox(
                    width: coverW,
                    height: coverH,
                    child: AgoraVideoView(
                      key: ValueKey(
                          'local-$_version-${coverW.round()}x${coverH.round()}'),
                      controller: _controller!,
                    ),
                  ),
                ),
              );
            },
          ),
          if (AgoraCallManager.isVideoOff)
            Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: currentUserPhoto.isNotEmpty
                  ? ClipOval(
                      child: cachedNetworkImage(
                        currentUserPhoto,
                        width: avatarSize,
                        height: avatarSize,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      color: Colors.white54,
                      size: avatarSize,
                    ),
            ),
        ],
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
