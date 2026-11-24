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
import 'dart:async';

class RemoteVideoRenderer extends StatefulWidget {
  const RemoteVideoRenderer({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  State<RemoteVideoRenderer> createState() => _RemoteVideoRendererState();
}

class _RemoteVideoRendererState extends State<RemoteVideoRenderer> {
  Timer? _refreshTimer;
  VideoViewController? _controller;
  int? _controllerUid;
  double? _controllerWidth;
  double? _controllerHeight;

  // Wide video (screen share, laptop camera) is shown whole, not cropped.
  bool _landscape = false;
  bool? _controllerLandscape;
  RtcEngine? _handlerEngine;
  late final RtcEngineEventHandler _sizeHandler = RtcEngineEventHandler(
    onVideoSizeChanged: (connection, sourceType, uid, width, height, rotation) {
      if (uid == 0 || uid != AgoraCallManager.remoteUid) return;
      final turned = rotation == 90 || rotation == 270;
      final w = turned ? height : width;
      final h = turned ? width : height;
      final wide = w > h;
      if (wide != _landscape && mounted) {
        setState(() => _landscape = wide);
      }
    },
  );

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    try {
      _handlerEngine?.unregisterEventHandler(_sizeHandler);
    } catch (_) {}
    _controller?.dispose();
    super.dispose();
  }

  void _watchSizes(RtcEngine engine) {
    if (identical(_handlerEngine, engine)) return;
    try {
      _handlerEngine?.unregisterEventHandler(_sizeHandler);
    } catch (_) {}
    try {
      engine.registerEventHandler(_sizeHandler);
      _handlerEngine = engine;
    } catch (_) {}
  }

  Future<void> _forceRemoteReplay(int remoteUid) async {
    final engine = AgoraCallManager.engine;
    if (engine == null) return;
    try {
      await engine.muteRemoteVideoStream(uid: remoteUid, mute: true);
      await Future.delayed(const Duration(milliseconds: 150));
      await engine.muteRemoteVideoStream(uid: remoteUid, mute: false);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final engine = AgoraCallManager.engine;
    final remoteUid = AgoraCallManager.remoteUid;
    if (engine != null) _watchSizes(engine);

    final sizeChanged =
        _controllerWidth != widget.width || _controllerHeight != widget.height;
    final modeChanged = _controllerLandscape != _landscape;

    if (engine != null &&
        remoteUid != null &&
        (_controllerUid != remoteUid || sizeChanged || modeChanged)) {
      _controller?.dispose();
      _controller = VideoViewController.remote(
        rtcEngine: engine,
        canvas: VideoCanvas(
          uid: remoteUid,
          renderMode: _landscape
              ? RenderModeType.renderModeFit
              : RenderModeType.renderModeHidden,
        ),
        connection: RtcConnection(channelId: AgoraCallManager.channelName),
      );
      final uidChanged = _controllerUid != remoteUid;
      _controllerUid = remoteUid;
      _controllerWidth = widget.width;
      _controllerHeight = widget.height;
      _controllerLandscape = _landscape;

      if (uidChanged) {
        final remoteUidForReplay = remoteUid;
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_controllerUid == remoteUidForReplay) {
            _forceRemoteReplay(remoteUidForReplay);
          }
        });
      }
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.black,
      alignment: Alignment.center,
      child: engine == null
          ? const CircularProgressIndicator(color: Colors.white)
          : remoteUid == null || _controller == null
              ? const Text(
                  'Waiting for the other person...',
                  style: TextStyle(color: Colors.white),
                )
              : SizedBox(
                  width: widget.width,
                  height: widget.height,
                  child: AgoraVideoView(
                    key: ValueKey('remote-$remoteUid-$_landscape-'
                        '${widget.width}x${widget.height}'),
                    controller: _controller!,
                  ),
                ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
