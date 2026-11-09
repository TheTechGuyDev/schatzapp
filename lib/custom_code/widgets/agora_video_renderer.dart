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

class AgoraVideoRenderer extends StatefulWidget {
  const AgoraVideoRenderer({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  final double? width;
  final double? height;

  @override
  State<AgoraVideoRenderer> createState() => _AgoraVideoRendererState();
}

class _AgoraVideoRendererState extends State<AgoraVideoRenderer> {
  bool _engineReady = false;
  Timer? _debugTimer;

  @override
  void initState() {
    super.initState();
    _waitForEngine();
    _debugTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _debugTimer?.cancel();
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
      return const Center(child: CircularProgressIndicator());
    }

    final engine = AgoraCallManager.engine!;

    return ClipOval(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: engine,
                canvas: const VideoCanvas(uid: 0),
              ),
            ),
            Positioned(
              left: 4,
              bottom: 4,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(4),
                child: Text(
                  AgoraCallManager.lastLocalVideoState,
                  style: const TextStyle(color: Colors.white, fontSize: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
