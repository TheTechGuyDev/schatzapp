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

import 'package:just_audio/just_audio.dart';
import 'dart:async';

class VoiceNoteBubble extends StatefulWidget {
  const VoiceNoteBubble({
    super.key,
    this.width,
    this.height,
    required this.audioUrl,
    required this.durationSeconds,
    required this.avatarUrl,
    required this.isOwnMessage,
  });

  final double? width;
  final double? height;
  final String audioUrl;
  final int durationSeconds;
  final String avatarUrl;
  final bool isOwnMessage;

  @override
  State<VoiceNoteBubble> createState() => _VoiceNoteBubbleState();
}

class _VoiceNoteBubbleState extends State<VoiceNoteBubble> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  bool _isLoaded = false;
  Duration _position = Duration.zero;
  Duration _totalDuration = Duration.zero;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;
  String? _loadedUrl;

  @override
  void initState() {
    super.initState();
    _totalDuration = Duration(seconds: widget.durationSeconds);
    _initPlayer();
  }

  void _initPlayer() {
    _player = AudioPlayer();
    _positionSub = _player.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _stateSub = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state.playing);
      if (state.processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
      }
    });
  }

  @override
  void didUpdateWidget(covariant VoiceNoteBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Critical fix: this widget's State can be reused by ListView.builder
    // for a completely different message row. If the audioUrl changed
    // under us, this is really a different voice note, reset everything.
    if (oldWidget.audioUrl != widget.audioUrl) {
      _positionSub?.cancel();
      _stateSub?.cancel();
      _player.dispose();
      setState(() {
        _isPlaying = false;
        _isLoaded = false;
        _loadedUrl = null;
        _position = Duration.zero;
        _totalDuration = Duration(seconds: widget.durationSeconds);
      });
      _initPlayer();
    }
  }

  Future<void> _togglePlay() async {
    // Always verify the loaded source actually matches this bubble's
    // current audioUrl before playing, never trust audioSource == null
    // alone, that's what caused the wrong-track-replay bug.
    if (!_isLoaded || _loadedUrl != widget.audioUrl) {
      await _player.setUrl(widget.audioUrl);
      _loadedUrl = widget.audioUrl;
      _isLoaded = true;
    }
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(1, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalDuration.inMilliseconds > 0
        ? (_position.inMilliseconds / _totalDuration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: widget.width,
      height: widget.height ?? 60,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: widget.avatarUrl.isNotEmpty
                    ? cachedNetworkImage(
                        widget.avatarUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 40,
                          height: 40,
                          color: FlutterFlowTheme.of(context).primaryBackground,
                        ),
                      )
                    : Container(
                        width: 40,
                        height: 40,
                        color: FlutterFlowTheme.of(context).primaryBackground,
                      ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: FlutterFlowTheme.of(context).primary,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.mic,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10.0),
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: FlutterFlowTheme.of(context).primary,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 18.0,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 26,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final totalBars = 30;
                      final filledBars = (progress * totalBars).round();
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(totalBars, (index) {
                          final isFilled = index < filledBars;
                          final seed =
                              (index * 37 + widget.audioUrl.length * 7) % 17;
                          final barHeight = 5.0 + (seed % 17);
                          return Expanded(
                            child: Container(
                              height: barHeight,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 0.9),
                              decoration: BoxDecoration(
                                color: isFilled
                                    ? FlutterFlowTheme.of(context).primary
                                    : FlutterFlowTheme.of(context)
                                        .secondaryText
                                        .withOpacity(0.55),
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  _formatDuration(
                    _isPlaying || _position > Duration.zero
                        ? _position
                        : _totalDuration,
                  ),
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
