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
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as imglib;
import '/custom_code/actions/index.dart';

class _FilterOption {
  const _FilterOption(this.name, this.matrix, {this.isBeauty = false});
  final String name;
  final List<double>? matrix;
  final bool isBeauty;
}

const List<_FilterOption> _filterOptions = [
  _FilterOption('Normal', null),
  _FilterOption('B&W', [
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]),
  _FilterOption('Vivid', [
    1.3,
    0,
    0,
    0,
    -20,
    0,
    1.3,
    0,
    0,
    -20,
    0,
    0,
    1.3,
    0,
    -20,
    0,
    0,
    0,
    1,
    0,
  ]),
  _FilterOption('Warm', [
    1.15,
    0,
    0,
    0,
    10,
    0,
    1.0,
    0,
    0,
    0,
    0,
    0,
    0.85,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]),
  _FilterOption('Cool', [
    0.85,
    0,
    0,
    0,
    0,
    0,
    1.0,
    0,
    0,
    0,
    0,
    0,
    1.2,
    0,
    10,
    0,
    0,
    0,
    1,
    0,
  ]),
  _FilterOption('Beauty', null, isBeauty: true),
];

const List<String> _stickerEmojis = [
  '😂',
  '❤️',
  '🔥',
  '😍',
  '👍',
  '🎉',
  '😢',
  '👏',
  '😎',
  '🥳'
];

class _StickerInstance {
  _StickerInstance(
      {required this.emoji, required this.offset, this.scale = 1.0});
  final String emoji;
  Offset offset;
  double scale;
  double gestureBaseScale = 1.0;
}

enum _BrushStyle { pen, marker, highlighter, neon }

class _BrushOption {
  const _BrushOption(this.style, this.icon, this.label);
  final _BrushStyle style;
  final IconData icon;
  final String label;
}

const List<_BrushOption> _brushOptions = [
  _BrushOption(_BrushStyle.pen, Icons.edit, 'Pen'),
  _BrushOption(_BrushStyle.marker, Icons.brush, 'Marker'),
  _BrushOption(_BrushStyle.highlighter, Icons.format_color_fill, 'Highlighter'),
  _BrushOption(_BrushStyle.neon, Icons.auto_awesome, 'Neon'),
];

class _Stroke {
  _Stroke({required this.color, required this.style}) : points = [];
  final Color color;
  final _BrushStyle style;
  final List<Offset> points;
}

class _DrawingPainter extends CustomPainter {
  _DrawingPainter(this.strokes);
  final List<_Stroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.length < 2) continue;
      final path = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (final p in stroke.points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }

      double width;
      double opacity;
      switch (stroke.style) {
        case _BrushStyle.pen:
          width = 5;
          opacity = 1.0;
          break;
        case _BrushStyle.marker:
          width = 14;
          opacity = 1.0;
          break;
        case _BrushStyle.highlighter:
          width = 22;
          opacity = 0.35;
          break;
        case _BrushStyle.neon:
          width = 8;
          opacity = 1.0;
          break;
      }

      if (stroke.style == _BrushStyle.neon) {
        final glowPaint = Paint()
          ..color = stroke.color.withOpacity(0.5)
          ..strokeWidth = width * 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawPath(path, glowPaint);
      }

      final mainPaint = Paint()
        ..color = stroke.color.withOpacity(opacity)
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, mainPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}

Uint8List _beautyProcessBytes(Uint8List inputBytes) {
  final decoded = imglib.decodeImage(inputBytes);
  if (decoded == null) return inputBytes;

  final blurred = imglib.gaussianBlur(imglib.Image.from(decoded), radius: 6);
  final smoothed = imglib.Image(width: decoded.width, height: decoded.height);

  for (var y = 0; y < decoded.height; y++) {
    for (var x = 0; x < decoded.width; x++) {
      final o = decoded.getPixel(x, y);
      final b = blurred.getPixel(x, y);
      final r = (o.r * 0.35 + b.r * 0.65).round().clamp(0, 255);
      final g = (o.g * 0.35 + b.g * 0.65).round().clamp(0, 255);
      final bl = (o.b * 0.35 + b.b * 0.65).round().clamp(0, 255);
      smoothed.setPixelRgba(x, y, r, g, bl, o.a.toInt());
    }
  }

  imglib.adjustColor(smoothed, brightness: 1.05, saturation: 1.05);
  return Uint8List.fromList(imglib.encodePng(smoothed));
}

class MultiImageEditPost extends StatefulWidget {
  const MultiImageEditPost({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
    required this.taggedUserIds,
    required this.onClose,
    required this.onPosted,
  });

  final double? width;
  final double? height;
  final String currentUserId;
  final List<String> taggedUserIds;
  final Future Function() onClose;
  final Future Function() onPosted;

  @override
  State<MultiImageEditPost> createState() => _MultiImageEditPostState();
}

class _MultiImageEditPostState extends State<MultiImageEditPost> {
  Uint8List _sourceBytes = Uint8List(0);
  int _filterIndex = 0;
  List<_StickerInstance> _stickers = [];
  bool _showStickerPicker = false;
  bool _capturing = false;

  Uint8List? _beautyBytes;
  bool _beautyProcessing = false;

  final GlobalKey _previewKey = GlobalKey();

  // Crop state
  bool _cropping = false;
  bool _imageReady = false;
  double _imgNaturalW = 0;
  double _imgNaturalH = 0;
  Rect _cropRect = Rect.zero;
  double _displayScale = 1;
  Offset _displayOffset = Offset.zero;

  // Draw state
  bool _drawing = false;
  List<_Stroke> _strokes = [];
  List<_Stroke> _strokesSnapshotBeforeDraw = [];
  Color _currentColor = Colors.red;
  _BrushStyle _currentBrushStyle = _BrushStyle.pen;

  @override
  void initState() {
    super.initState();
    final index = FFAppState().storyDraftEditingIndex;
    final originals = FFAppState().storyDraftOriginalImages;
    final edited = FFAppState().storyDraftEditedImages;

    final useEdited =
        index >= 0 && index < edited.length && edited[index].isNotEmpty;
    final source = useEdited
        ? edited[index]
        : (index >= 0 && index < originals.length ? originals[index] : '');

    _sourceBytes = source.isNotEmpty ? base64Decode(source) : Uint8List(0);
    _loadImageSize();
  }

  Future<void> _loadImageSize() async {
    if (_sourceBytes.isEmpty) return;
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(_sourceBytes, completer.complete);
    final image = await completer.future;
    if (!mounted) return;
    setState(() {
      _imgNaturalW = image.width.toDouble();
      _imgNaturalH = image.height.toDouble();
      _imageReady = true;
    });
  }

  void _addSticker(String emoji) {
    setState(() {
      _stickers.add(
        _StickerInstance(emoji: emoji, offset: const Offset(90, 170)),
      );
      _showStickerPicker = false;
    });
  }

  Future<void> _selectFilter(int i) async {
    setState(() => _filterIndex = i);
    if (_filterOptions[i].isBeauty) {
      await _applyBeauty();
    }
  }

  Future<void> _applyBeauty() async {
    if (_beautyBytes != null || _beautyProcessing) return;
    setState(() => _beautyProcessing = true);
    final bytes = await compute(_beautyProcessBytes, _sourceBytes);
    if (!mounted) return;
    setState(() {
      _beautyBytes = bytes;
      _beautyProcessing = false;
    });
  }

  Widget _filteredImage({BoxFit fit = BoxFit.contain}) {
    final option = _filterOptions[_filterIndex];

    if (option.isBeauty) {
      if (_beautyBytes != null) {
        return Image.memory(_beautyBytes!, fit: fit);
      }
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(_sourceBytes, fit: fit),
          if (_beautyProcessing)
            Container(
              color: Colors.black38,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(color: Colors.white),
            ),
        ],
      );
    }

    final img = Image.memory(_sourceBytes, fit: fit);
    if (option.matrix == null) return img;
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(option.matrix!),
      child: img,
    );
  }

  Future<Uint8List?> _capturePreview() async {
    final ctx = _previewKey.currentContext;
    if (ctx == null) return null;
    final boundary = ctx.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    return byteData.buffer.asUint8List();
  }

  void _startCrop() {
    if (!_imageReady) return;
    setState(() {
      _cropping = true;
      _drawing = false;
      _showStickerPicker = false;
      _cropRect = Rect.zero;
    });
  }

  void _cancelCrop() {
    setState(() {
      _cropRect = Rect.zero;
      _cropping = false;
    });
  }

  Future<void> _confirmCrop() async {
    if (_displayScale == 0 || _cropRect == Rect.zero) {
      setState(() => _cropping = false);
      return;
    }

    final decoded = imglib.decodeImage(_sourceBytes);
    if (decoded == null) {
      setState(() => _cropping = false);
      return;
    }

    final x =
        (_cropRect.left / _displayScale).round().clamp(0, decoded.width - 1);
    final y =
        (_cropRect.top / _displayScale).round().clamp(0, decoded.height - 1);
    final w =
        (_cropRect.width / _displayScale).round().clamp(1, decoded.width - x);
    final h =
        (_cropRect.height / _displayScale).round().clamp(1, decoded.height - y);

    final cropped = imglib.copyCrop(decoded, x: x, y: y, width: w, height: h);
    final newBytes = Uint8List.fromList(imglib.encodePng(cropped));

    if (!mounted) return;
    setState(() {
      _sourceBytes = newBytes;
      _imgNaturalW = w.toDouble();
      _imgNaturalH = h.toDouble();
      _cropRect = Rect.zero;
      _stickers.clear();
      _strokes.clear();
      _beautyBytes = null;
      _cropping = false;
    });
  }

  void _startDraw() {
    setState(() {
      _drawing = true;
      _cropping = false;
      _showStickerPicker = false;
      _strokesSnapshotBeforeDraw = List<_Stroke>.from(_strokes);
    });
  }

  void _cancelDraw() {
    setState(() {
      _strokes = List<_Stroke>.from(_strokesSnapshotBeforeDraw);
      _drawing = false;
    });
  }

  void _confirmDraw() {
    setState(() => _drawing = false);
  }

  void _pickColorAt(double y, double height) {
    final clampedY = y.clamp(0.0, height);
    final t = clampedY / height;
    final stops = [
      Colors.white,
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.cyan,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.black,
    ];
    final segment = t * (stops.length - 1);
    final index = segment.floor().clamp(0, stops.length - 2);
    final localT = segment - index;
    final color = Color.lerp(stops[index], stops[index + 1], localT)!;
    setState(() => _currentColor = color);
  }

  Widget _colorSlider() {
    const sliderHeight = 220.0;
    return Container(
      width: 28,
      height: sliderHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 2),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.green,
            Colors.cyan,
            Colors.blue,
            Colors.purple,
            Colors.pink,
            Colors.black,
          ],
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) =>
            _pickColorAt(details.localPosition.dy, sliderHeight),
        onTapDown: (details) =>
            _pickColorAt(details.localPosition.dy, sliderHeight),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _cropOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;
        if (_imgNaturalW == 0 || _imgNaturalH == 0) {
          return const SizedBox.shrink();
        }

        _displayScale = math.min(maxW / _imgNaturalW, maxH / _imgNaturalH);
        final dispW = _imgNaturalW * _displayScale;
        final dispH = _imgNaturalH * _displayScale;
        _displayOffset = Offset((maxW - dispW) / 2, (maxH - dispH) / 2);

        if (_cropRect == Rect.zero) {
          const inset = 24.0;
          final safeInsetW = math.min(inset, dispW / 4);
          final safeInsetH = math.min(inset, dispH / 4);
          _cropRect = Rect.fromLTWH(
            safeInsetW,
            safeInsetH,
            dispW - safeInsetW * 2,
            dispH - safeInsetH * 2,
          );
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: _displayOffset.dx,
              top: _displayOffset.dy,
              width: dispW,
              height: dispH,
              child: Image.memory(_sourceBytes, fit: BoxFit.fill),
            ),
            Positioned(
              left: _displayOffset.dx + _cropRect.left,
              top: _displayOffset.dy + _cropRect.top,
              width: _cropRect.width,
              height: _cropRect.height,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    var newLeft = _cropRect.left + details.delta.dx;
                    var newTop = _cropRect.top + details.delta.dy;
                    newLeft = newLeft.clamp(0.0, dispW - _cropRect.width);
                    newTop = newTop.clamp(0.0, dispH - _cropRect.height);
                    _cropRect = Rect.fromLTWH(
                        newLeft, newTop, _cropRect.width, _cropRect.height);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
            Positioned(
              left: _displayOffset.dx + _cropRect.right - 22,
              top: _displayOffset.dy + _cropRect.bottom - 22,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  setState(() {
                    final newW = (_cropRect.width + details.delta.dx)
                        .clamp(40.0, dispW - _cropRect.left);
                    final newH = (_cropRect.height + details.delta.dy)
                        .clamp(40.0, dispH - _cropRect.top);
                    _cropRect = Rect.fromLTWH(
                        _cropRect.left, _cropRect.top, newW, newH);
                  });
                },
                child: Container(
                  width: 44,
                  height: 44,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF935CCC),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _next() async {
    if (_capturing || _beautyProcessing || _sourceBytes.isEmpty) return;

    // IMPORTANT: capture the preview WHILE it is still on screen, before
    // switching to the loading spinner. If we flip `_capturing` first,
    // the RepaintBoundary is removed from the tree and capture silently
    // falls back to the plain, unedited source bytes.
    final captured = await _capturePreview();

    setState(() => _capturing = true);

    final bytesToSave = captured ?? _sourceBytes;
    final base64Str = base64Encode(bytesToSave);

    final index = FFAppState().storyDraftEditingIndex;
    final edited = List<String>.from(FFAppState().storyDraftEditedImages);
    if (index >= 0 && index < edited.length) {
      edited[index] = base64Str;
      FFAppState().storyDraftEditedImages = edited;
    }

    if (!mounted) return;
    setState(() => _capturing = false);
    widget.onPosted();
  }

  @override
  Widget build(BuildContext context) {
    if (_sourceBytes.isEmpty) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: const Text('No image selected',
              style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Container(
        color: Colors.black,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: _cropping
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: _cancelCrop,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                          const Text('Crop',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                          InkWell(
                            onTap: _confirmCrop,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFF935CCC),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.check,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      )
                    : _drawing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: _cancelDraw,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                              const Text('Draw',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                              InkWell(
                                onTap: _confirmDraw,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF935CCC),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.check,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () => widget.onClose(),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                              const Text('Edit photo',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: _startCrop,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.crop,
                                          color: Colors.white, size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  InkWell(
                                    onTap: _startDraw,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.edit_outlined,
                                          color: Colors.white, size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  InkWell(
                                    onTap: () => setState(() =>
                                        _showStickerPicker =
                                            !_showStickerPicker),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: _showStickerPicker
                                            ? const Color(0xFF935CCC)
                                            : Colors.white24,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                          Icons.emoji_emotions_outlined,
                                          color: Colors.white,
                                          size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
              ),
              Expanded(
                child: _capturing
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _cropping
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 28),
                            child: _cropOverlay(),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Stack(
                              children: [
                                RepaintBoundary(
                                  key: _previewKey,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Stack(
                                      fit: StackFit.passthrough,
                                      children: [
                                        _filteredImage(),
                                        Positioned.fill(
                                          child: CustomPaint(
                                            painter: _DrawingPainter(_strokes),
                                          ),
                                        ),
                                        ..._stickers.map(
                                          (s) => Positioned(
                                            left: s.offset.dx,
                                            top: s.offset.dy,
                                            child: GestureDetector(
                                              behavior:
                                                  HitTestBehavior.translucent,
                                              onScaleStart: (details) {
                                                s.gestureBaseScale = s.scale;
                                              },
                                              onScaleUpdate: (details) {
                                                setState(() {
                                                  s.offset +=
                                                      details.focalPointDelta;
                                                  s.scale =
                                                      (s.gestureBaseScale *
                                                              details.scale)
                                                          .clamp(0.4, 4.0);
                                                });
                                              },
                                              onLongPress: () {
                                                setState(() {
                                                  _stickers.remove(s);
                                                });
                                              },
                                              child: SizedBox(
                                                width: 120,
                                                height: 120,
                                                child: Center(
                                                  child: Text(
                                                    s.emoji,
                                                    style: TextStyle(
                                                        fontSize: 40 * s.scale),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (_drawing)
                                          Positioned.fill(
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onPanStart: (details) {
                                                setState(() {
                                                  _strokes = List<_Stroke>.from(
                                                      _strokes)
                                                    ..add(_Stroke(
                                                        color: _currentColor,
                                                        style:
                                                            _currentBrushStyle));
                                                  _strokes.last.points.add(
                                                      details.localPosition);
                                                });
                                              },
                                              onPanUpdate: (details) {
                                                setState(() {
                                                  _strokes.last.points.add(
                                                      details.localPosition);
                                                });
                                              },
                                              child: const SizedBox.expand(),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (_drawing)
                                  Positioned(
                                    right: 8,
                                    top: 20,
                                    child: _colorSlider(),
                                  ),
                              ],
                            ),
                          ),
              ),
              if (!_cropping && !_drawing && _showStickerPicker)
                SizedBox(
                  height: 56,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _stickerEmojis.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) => InkWell(
                      onTap: () => _addSticker(_stickerEmojis[i]),
                      child: Text(
                        _stickerEmojis[i],
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                ),
              if (!_cropping && !_drawing) const SizedBox(height: 12),
              if (!_cropping && !_drawing)
                SizedBox(
                  height: 76,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filterOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final option = _filterOptions[i];
                      final selected = i == _filterIndex;
                      return InkWell(
                        onTap: () => _selectFilter(i),
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFF935CCC)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: option.isBeauty
                                    ? Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.memory(_sourceBytes,
                                              fit: BoxFit.cover),
                                          Container(
                                            color: Colors.black26,
                                            alignment: Alignment.center,
                                            child: const Icon(
                                                Icons.auto_awesome,
                                                color: Colors.white,
                                                size: 18),
                                          ),
                                        ],
                                      )
                                    : option.matrix == null
                                        ? Image.memory(_sourceBytes,
                                            fit: BoxFit.cover)
                                        : ColorFiltered(
                                            colorFilter: ColorFilter.matrix(
                                                option.matrix!),
                                            child: Image.memory(_sourceBytes,
                                                fit: BoxFit.cover),
                                          ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              option.name,
                              style: TextStyle(
                                color: selected
                                    ? const Color(0xFF935CCC)
                                    : Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              if (_drawing)
                SizedBox(
                  height: 64,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _brushOptions.map((opt) {
                      final selected = _currentBrushStyle == opt.style;
                      return InkWell(
                        onTap: () =>
                            setState(() => _currentBrushStyle = opt.style),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF935CCC)
                                : Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(opt.icon, color: Colors.white, size: 20),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              if (!_cropping) const SizedBox(height: 16),
              if (!_cropping && !_drawing)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                    onTap: (_capturing || _beautyProcessing) ? null : _next,
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF935CCC),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      alignment: Alignment.center,
                      child: (_capturing || _beautyProcessing)
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Next',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
