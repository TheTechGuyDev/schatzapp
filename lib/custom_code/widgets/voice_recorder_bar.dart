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

import 'dart:async';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class VoiceRecorderBar extends StatefulWidget {
  const VoiceRecorderBar({
    super.key,
    this.width,
    this.height,
    required this.onCancel,
    required this.onSend,
  });

  final double? width;
  final double? height;
  final Future Function() onCancel;
  final Future Function(String filePath, int durationSeconds) onSend;

  @override
  State<VoiceRecorderBar> createState() => _VoiceRecorderBarState();
}

class _VoiceRecorderBarState extends State<VoiceRecorderBar> {
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Amplitude>? _amplitudeSub;
  Timer? _durationTimer;

  bool _isPaused = false;
  int _elapsedSeconds = 0;
  String? _filePath;
  final List<double> _amplitudes = [];

  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    _filePath = path;

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused && mounted) {
        setState(() => _elapsedSeconds++);
      }
    });

    _amplitudeSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 200))
        .listen((amp) {
      if (!mounted) return;
      setState(() {
        // Normalize dBFS (-45 to 0) to a 0-1 range for bar heights.
        final normalized = ((amp.current + 45) / 45).clamp(0.0, 1.0);
        _amplitudes.add(normalized);
        if (_amplitudes.length > 40) _amplitudes.removeAt(0);
      });
    });
  }

  Future<void> _togglePause() async {
    if (_isPaused) {
      await _recorder.resume();
    } else {
      await _recorder.pause();
    }
    setState(() => _isPaused = !_isPaused);
  }

  Future<void> _cancel() async {
    _durationTimer?.cancel();
    await _amplitudeSub?.cancel();
    await _recorder.stop();
    if (_filePath != null) {
      final file = File(_filePath!);
      if (await file.exists()) await file.delete();
    }
    widget.onCancel();
  }

  Future<void> _send() async {
    _durationTimer?.cancel();
    await _amplitudeSub?.cancel();
    final path = await _recorder.stop();
    if (path != null) {
      widget.onSend(path, _elapsedSeconds);
    }
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _amplitudeSub?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(1, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height ?? 56,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _cancel,
            child: Icon(
              Icons.delete_outline,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 24.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Text(
            _formatDuration(_elapsedSeconds),
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: SizedBox(
              height: 30,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _amplitudes.map((amp) {
                  return Container(
                    width: 2.5,
                    height: (amp * 26).clamp(3.0, 26.0),
                    margin: const EdgeInsets.symmetric(horizontal: 1.0),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          GestureDetector(
            onTap: _togglePause,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.withOpacity(0.15),
                border: Border.all(color: Colors.redAccent, width: 1.5),
              ),
              child: Icon(
                _isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.redAccent,
                size: 20.0,
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: FlutterFlowTheme.of(context).primary,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 18.0,
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
