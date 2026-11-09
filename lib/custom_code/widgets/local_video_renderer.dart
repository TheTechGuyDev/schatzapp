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

class _LocalVideoRendererState extends State<LocalVideoRenderer> {
  bool _engineReady = false;
  Timer? _refreshTimer;
  VideoViewController? _controller;

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
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _waitForEngine() async {
    while (AgoraCallManager.engine == null) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
    }
    if (mounted) setState(() => _engineReady = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_engineReady || AgoraCallManager.engine == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black26,
      );
    }

    // Create the controller ONCE and keep AgoraVideoView permanently
    // mounted for this widget's whole lifetime — including while video is
    // toggled off. Swapping it out for a different widget on toggle was
    // what caused Agora to lose track of its own view element (the "can
    // not find AgoraSurfaceView_N" failure), which visually broke the
    // rest of the call screen. Muting is handled at the Agora stream
    // level (see toggleVideo/muteLocalVideoStream) — the view itself
    // should never be torn down just because video is off.
    _controller ??= VideoViewController(
      rtcEngine: AgoraCallManager.engine!,
      canvas: const VideoCanvas(uid: 0),
    );

    final avatarSize = (widget.width ?? 60.0) * 0.5;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AgoraVideoView(
            controller: _controller!,
          ),
          if (AgoraCallManager.isVideoOff)
            Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: currentUserPhoto.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
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
