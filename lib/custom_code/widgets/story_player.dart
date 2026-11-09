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
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_fonts/google_fonts.dart';
import '/custom_code/actions/index.dart';

class StoryPlayer extends StatefulWidget {
  const StoryPlayer({
    Key? key,
    this.width,
    this.height,
    required this.items,
    required this.viewerId,
    required this.onFinishedGroup,
    required this.onExitToPrevious,
    this.startIndex = 0,
    this.isOwnStory = false,
    this.onIndexChanged,
  }) : super(key: key);

  final double? width;
  final double? height;
  final List<StoryItemStruct> items;
  final String viewerId;
  final Future Function() onFinishedGroup;
  final Future Function() onExitToPrevious;
  final int startIndex;
  final bool isOwnStory;
  final Future Function(int index)? onIndexChanged;

  @override
  State<StoryPlayer> createState() => _StoryPlayerState();
}

class _StoryPlayerState extends State<StoryPlayer>
    with SingleTickerProviderStateMixin {
  late int _index;
  late AnimationController _controller;
  VideoPlayerController? _videoController;
  AudioPlayer? _audioController;
  bool _paused = false;
  bool _videoFailed = false;

  static const _imageDuration = Duration(seconds: 5);
  static const _voiceFallbackDuration = Duration(seconds: 5);
  static const _maxVideoDuration = Duration(minutes: 3);

  StoryItemStruct get _current => widget.items[_index];

  @override
  void initState() {
    super.initState();
    if (widget.items.isEmpty) {
      _index = 0;
    } else {
      _index = widget.startIndex.clamp(0, widget.items.length - 1);
    }
    _controller = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _advance();
      });
    if (widget.items.isNotEmpty) {
      _loadCurrent();
      widget.onIndexChanged?.call(_index);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoController?.dispose();
    _audioController?.dispose();
    super.dispose();
  }

  Future<void> _loadCurrent() async {
    _videoController?.dispose();
    _videoController = null;
    _audioController?.dispose();
    _audioController = null;
    _controller.stop();
    _controller.reset();

    if (!widget.isOwnStory) {
      markStatusViewed(_current.id, widget.viewerId);
    }

    _videoFailed = false;
    if (_current.mediaType == 'video' && _current.mediaUrl.isNotEmpty) {
      final loadingIndex = _index;
      VideoPlayerController? vc;
      // Videos uploaded without "fast start" can take a while to open on a
      // mobile connection, so wait up to 30 seconds and try twice.
      for (var attempt = 0; attempt < 2; attempt++) {
        final candidate =
            VideoPlayerController.networkUrl(Uri.parse(_current.mediaUrl));
        _videoController = candidate;
        try {
          await candidate.initialize().timeout(const Duration(seconds: 30));
          vc = candidate;
          break;
        } catch (_) {
          candidate.dispose();
          if (_videoController == candidate) _videoController = null;
          if (!mounted || _index != loadingIndex) return;
        }
      }
      if (!mounted || _index != loadingIndex) return;
      if (vc == null) {
        _videoFailed = true;
        _controller.duration = const Duration(seconds: 3);
        setState(() {});
        _controller.forward();
        return;
      }
      final videoDuration = vc.value.duration > _maxVideoDuration
          ? _maxVideoDuration
          : vc.value.duration;
      _controller.duration = videoDuration;
      vc.play();
      setState(() {});
      _controller.forward();
    } else if (_current.mediaType == 'voice' && _current.mediaUrl.isNotEmpty) {
      final ac = AudioPlayer();
      _audioController = ac;
      try {
        final audioDuration = await ac
            .setUrl(_current.mediaUrl)
            .timeout(const Duration(seconds: 8));
        if (!mounted) return;
        final effectiveDuration =
            (audioDuration != null && audioDuration > Duration.zero)
                ? (audioDuration > _maxVideoDuration
                    ? _maxVideoDuration
                    : audioDuration)
                : _voiceFallbackDuration;
        _controller.duration = effectiveDuration;
        ac.play();
        setState(() {});
        _controller.forward();
      } catch (_) {
        if (!mounted) return;
        _audioController?.dispose();
        _audioController = null;
        _controller.duration = _voiceFallbackDuration;
        setState(() {});
        _controller.forward();
      }
    } else {
      _controller.duration = _imageDuration;
      setState(() {});
      _controller.forward();
    }
  }

  void _advance() {
    if (_index < widget.items.length - 1) {
      setState(() => _index++);
      widget.onIndexChanged?.call(_index);
      _loadCurrent();
    } else {
      widget.onFinishedGroup();
    }
  }

  void _rewind() {
    if (_index > 0) {
      setState(() => _index--);
      widget.onIndexChanged?.call(_index);
      _loadCurrent();
    } else {
      widget.onExitToPrevious();
    }
  }

  void _pause() {
    if (_paused) return;
    _paused = true;
    _controller.stop();
    _videoController?.pause();
    _audioController?.pause();
  }

  void _resume() {
    if (!_paused) return;
    _paused = false;
    _controller.forward();
    _videoController?.play();
    _audioController?.play();
  }

  TextStyle _fontStyle(int index,
      {required double size, required Color color}) {
    switch (index) {
      case 0:
        return GoogleFonts.roboto(
            fontSize: size, color: color, fontWeight: FontWeight.w600);
      case 1:
        return GoogleFonts.openSans(
            fontSize: size, color: color, fontWeight: FontWeight.w600);
      case 2:
        return GoogleFonts.lato(
            fontSize: size, color: color, fontWeight: FontWeight.w600);
      case 3:
        return GoogleFonts.montserrat(
            fontSize: size, color: color, fontWeight: FontWeight.w600);
      case 4:
        return GoogleFonts.poppins(
            fontSize: size, color: color, fontWeight: FontWeight.w300);
      case 5:
        return GoogleFonts.dancingScript(
            fontSize: size, color: color, fontWeight: FontWeight.w600);
      case 6:
        return GoogleFonts.greatVibes(fontSize: size, color: color);
      case 7:
        return GoogleFonts.pacifico(fontSize: size, color: color);
      case 8:
        return GoogleFonts.sacramento(fontSize: size, color: color);
      case 9:
        return GoogleFonts.satisfy(fontSize: size, color: color);
      default:
        return GoogleFonts.roboto(
            fontSize: size, color: color, fontWeight: FontWeight.w600);
    }
  }

  String _posterUrl(String url) {
    if (!url.contains('/status_media/')) return '';
    final dot = url.lastIndexOf('.');
    if (dot <= url.lastIndexOf('/')) return '';
    return '${url.substring(0, dot)}_thumb.jpg';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: const Text('No stories to show',
              style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    final item = _current;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: item.mediaType == 'video'
                  ? (_videoController != null &&
                          _videoController!.value.isInitialized
                      ? FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoController!.value.size.width,
                            height: _videoController!.value.size.height,
                            child: VideoPlayer(_videoController!),
                          ),
                        )
                      : (_videoFailed
                          ? const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.videocam_off,
                                      color: Colors.white54, size: 44),
                                  SizedBox(height: 10),
                                  Text(
                                    "Couldn't load this video",
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                            )
                          : Stack(
                              fit: StackFit.expand,
                              children: [
                                // First frame saved beside the video, shown
                                // while the video itself loads.
                                if (_posterUrl(item.mediaUrl).isNotEmpty)
                                  Image.network(
                                    _posterUrl(item.mediaUrl),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const SizedBox.shrink(),
                                  ),
                                const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white),
                                ),
                              ],
                            )))
                  : item.mediaType == 'text'
                      ? Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors:
                                  _parseGradientColors(item.backgroundColor),
                            ),
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            item.caption,
                            textAlign: TextAlign.center,
                            style: _fontStyle(item.fontIndex,
                                size: 22, color: Colors.white),
                          ),
                        )
                      : item.mediaType == 'voice'
                          ? Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: _parseGradientColors(
                                      item.backgroundColor),
                                ),
                              ),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.15),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      _audioController == null
                                          ? Icons.mic
                                          : (_paused
                                              ? Icons.pause
                                              : Icons.graphic_eq),
                                      color: Colors.white,
                                      size: 44,
                                    ),
                                  ),
                                  if (item.caption.isNotEmpty) ...[
                                    const SizedBox(height: 20),
                                    Text(
                                      item.caption,
                                      textAlign: TextAlign.center,
                                      style: _fontStyle(item.fontIndex,
                                          size: 18, color: Colors.white),
                                    ),
                                  ],
                                ],
                              ),
                            )
                          : (item.mediaUrl.isNotEmpty
                              ? Image.network(
                                  item.mediaUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.white),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(Icons.broken_image,
                                          color: Colors.white54, size: 40),
                                    );
                                  },
                                )
                              : const SizedBox.shrink()),
            ),
          ),
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _rewind,
                    onLongPress: _pause,
                    onLongPressUp: _resume,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _advance,
                    onLongPress: _pause,
                    onLongPressUp: _resume,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            left: 8,
            right: 8,
            child: Row(
              children: List.generate(widget.items.length, (i) {
                return Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          final fraction = i < _index
                              ? 1.0
                              : i == _index
                                  ? _controller.value
                                  : 0.0;
                          return FractionallySizedBox(
                            widthFactor: fraction,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _parseGradientColors(String? hex) {
    if (hex == null || hex.isEmpty) {
      return [Colors.deepPurple, Colors.deepPurple];
    }
    final parts = hex.split(',');
    Color parseOne(String h) {
      var value = h.trim().replaceAll('#', '');
      if (value.length == 6) value = 'FF$value';
      try {
        return Color(int.parse(value, radix: 16));
      } catch (_) {
        return Colors.deepPurple;
      }
    }

    if (parts.length >= 2) {
      return [parseOne(parts[0]), parseOne(parts[1])];
    }
    final single = parseOne(parts[0]);
    return [single, single];
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
