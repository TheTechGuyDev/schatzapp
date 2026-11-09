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

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';

Uint8List _rotateBytes90Batch(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;
  final rotated = img.copyRotate(decoded, angle: 90);
  return Uint8List.fromList(img.encodeJpg(rotated, quality: 92));
}

class _BatchTextLayer {
  _BatchTextLayer({
    required this.id,
    required this.text,
    required this.position,
    this.color = Colors.white,
    this.fontSize = 28.0,
  });

  final String id;
  String text;
  Offset position;
  Color color;
  double fontSize;
}

class _BatchStroke {
  _BatchStroke(this.color, this.width) : points = [];
  final Color color;
  final double width;
  final List<Offset> points;
}

class _BatchDrawPainter extends CustomPainter {
  _BatchDrawPainter(this.strokes);
  final List<_BatchStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      for (var i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BatchDrawPainter oldDelegate) => true;
}

/// Full-screen swipeable batch image editor.
///
/// Pushed directly with Navigator.push from the composer's staged-media badge
/// - it is never placed on a Canvas page. Lets the user swipe between every
/// currently staged image and edit each one (crop, rotate, text, draw,
/// remove) independently. A single shared checkmark composes and returns
/// every edited image at once; nothing is uploaded here, and no
/// caption/voice-note field is shown (the composer's own caption covers the
/// whole batch).
class BatchEditImagePage extends StatefulWidget {
  const BatchEditImagePage({
    super.key,
    this.width,
    this.height,
    required this.mediaIdentifiers,
    this.initialIndex = 0,
    required this.onDone,
  });

  final double? width;
  final double? height;

  /// Same identifier scheme as the composer's stagedMediaUrls: a raw file
  /// path (starts with '/') or a photo_manager gallery asset id.
  final List<String> mediaIdentifiers;
  final int initialIndex;

  /// Called once, when the shared checkmark is tapped. The value passed
  /// back is a Map<int, Uint8List> (kept as dynamic here so FlutterFlow's
  /// parameter parser can process this widget) keyed by index into
  /// [mediaIdentifiers] - only images that were actually edited are
  /// included. Also carries which indexes (if any) were removed, as a
  /// Set<int> under the reserved key -1's paired list (see [removedIndexes]
  /// helper below) so the composer can drop them from its own list.
  final Future Function(dynamic editedByIndex, dynamic removedIndexes) onDone;

  @override
  State<BatchEditImagePage> createState() => _BatchEditImagePageState();
}

class _BatchEditImagePageState extends State<BatchEditImagePage> {
  late final PageController _pageController;
  late int _currentIndex;
  late List<String> _identifiers;
  late List<GlobalKey<_BatchEditorPageState>> _pageKeys;
  final Set<int> _removedOriginalIndexes = {};
  late List<int> _originalIndexes;

  @override
  void initState() {
    super.initState();
    _identifiers = List.of(widget.mediaIdentifiers);
    _originalIndexes = List.generate(_identifiers.length, (i) => i);
    _currentIndex = widget.initialIndex.clamp(0, _identifiers.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
    _pageKeys = List.generate(
        _identifiers.length, (_) => GlobalKey<_BatchEditorPageState>());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _anyHasEdits =>
      _pageKeys.any((k) => k.currentState?.hasEdits ?? false);

  Future<bool> _confirmDiscard() async {
    if (!_anyHasEdits && _removedOriginalIndexes.isEmpty) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Discard changes?',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE05C6E)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Discard',
                      style: TextStyle(
                          color: Color(0xFFE05C6E),
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Keep editing',
                    style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  void _removeCurrent() {
    final removedOriginal = _originalIndexes[_currentIndex];
    if (_identifiers.length <= 1) {
      // Removing the last image just closes the editor with a removal.
      _removedOriginalIndexes.add(removedOriginal);
      widget.onDone(<int, Uint8List>{}, _removedOriginalIndexes).then((_) {
        if (mounted) Navigator.pop(context);
      });
      return;
    }
    setState(() {
      _removedOriginalIndexes.add(removedOriginal);
      _identifiers.removeAt(_currentIndex);
      _pageKeys.removeAt(_currentIndex);
      _originalIndexes.removeAt(_currentIndex);
      if (_currentIndex >= _identifiers.length) {
        _currentIndex = _identifiers.length - 1;
      }
    });
  }

  Future<void> _handleDone() async {
    final Map<int, Uint8List> edited = {};
    for (var i = 0; i < _pageKeys.length; i++) {
      final state = _pageKeys[i].currentState;
      if (state != null && state.hasEdits) {
        edited[_originalIndexes[i]] = await state.composeFinal();
      }
    }
    await widget.onDone(edited, _removedOriginalIndexes);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: WillPopScope(
        onWillPop: _confirmDiscard,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () async {
                          if (await _confirmDiscard() && mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child:
                            const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      if (_identifiers.length > 1)
                        Text('${_currentIndex + 1} / ${_identifiers.length}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      InkWell(
                        onTap: _handleDone,
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _identifiers.isEmpty
                      ? const SizedBox.shrink()
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: _identifiers.length,
                          onPageChanged: (i) =>
                              setState(() => _currentIndex = i),
                          itemBuilder: (context, i) => _BatchEditorPage(
                            key: _pageKeys[i],
                            identifier: _identifiers[i],
                            onRemove: _removeCurrent,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One page of the batch editor: resolves its own image bytes, then offers
/// crop / rotate / text / draw / remove on it.
class _BatchEditorPage extends StatefulWidget {
  const _BatchEditorPage({
    super.key,
    required this.identifier,
    required this.onRemove,
  });

  final String identifier;
  final VoidCallback onRemove;

  @override
  State<_BatchEditorPage> createState() => _BatchEditorPageState();
}

class _BatchEditorPageState extends State<_BatchEditorPage> {
  Uint8List? _original;
  Uint8List? _baseImage;
  double? _imgWidth;
  double? _imgHeight;

  final GlobalKey _boundaryKey = GlobalKey();
  final CropController _cropController = CropController();

  bool _cropping = false;
  bool _drawMode = false;
  bool _rotating = false;

  Color _drawColor = Colors.redAccent;
  static const List<Color> _drawColors = [
    Colors.redAccent,
    Colors.white,
    Colors.black,
    Colors.amber,
    Color(0xFF935CCC),
    Colors.greenAccent,
  ];

  final List<_BatchTextLayer> _textLayers = [];
  final List<_BatchStroke> _strokes = [];
  _BatchStroke? _activeStroke;

  bool get hasEdits =>
      _textLayers.isNotEmpty ||
      _strokes.isNotEmpty ||
      (_original != null &&
          _baseImage != null &&
          !identical(_original, _baseImage));

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    Uint8List bytes;
    if (widget.identifier.startsWith('b64:')) {
      bytes = base64Decode(widget.identifier.substring(4));
    } else if (widget.identifier.startsWith('/')) {
      bytes = await File(widget.identifier).readAsBytes();
    } else {
      final asset = await AssetEntity.fromId(widget.identifier);
      final full = await asset?.originBytes;
      if (full != null) {
        bytes = full;
      } else {
        final file = await asset?.file;
        bytes = file != null ? await file.readAsBytes() : Uint8List(0);
      }
    }
    if (!mounted) return;
    _original = bytes;
    _baseImage = bytes;
    await _decodeDimensions();
  }

  Future<void> _decodeDimensions() async {
    final descriptor = await ui.instantiateImageCodec(_baseImage!);
    final frame = await descriptor.getNextFrame();
    if (!mounted) return;
    setState(() {
      _imgWidth = frame.image.width.toDouble();
      _imgHeight = frame.image.height.toDouble();
    });
  }

  Future<void> _rotate() async {
    setState(() => _rotating = true);
    final rotated = await compute(_rotateBytes90Batch, _baseImage!);
    if (!mounted) return;
    setState(() {
      _baseImage = rotated;
      _rotating = false;
    });
    await _decodeDimensions();
  }

  Future<void> _addTextLayer() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add text', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Type something...',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (text == null || text.isEmpty) return;
    setState(() {
      _textLayers.add(
        _BatchTextLayer(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          position: const Offset(60, 200),
        ),
      );
    });
  }

  Future<void> _confirmRemove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Remove this image?',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE05C6E)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Remove',
                      style: TextStyle(
                          color: Color(0xFFE05C6E),
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true) widget.onRemove();
  }

  Future<Uint8List> composeFinal() async {
    final boundary = _boundaryKey.currentContext!.findRenderObject()
        as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Widget _iconCircle(
      {required Widget icon, required VoidCallback? onTap, Color? bg}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg ?? Colors.black45,
        ),
        alignment: Alignment.center,
        child: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = _baseImage != null && _imgWidth != null && _imgHeight != null;
    if (!ready) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    return Stack(
      children: [
        Positioned.fill(
          child: _cropping
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 40.0),
                  child: Crop(
                    controller: _cropController,
                    image: _baseImage!,
                    onCropped: (result) {
                      switch (result) {
                        case CropSuccess(:final croppedImage):
                          setState(() {
                            _baseImage = croppedImage;
                            _cropping = false;
                          });
                          _decodeDimensions();
                        case CropFailure():
                          setState(() => _cropping = false);
                      }
                    },
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _imgWidth! / _imgHeight!,
                      child: RepaintBoundary(
                        key: _boundaryKey,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child:
                                  Image.memory(_baseImage!, fit: BoxFit.cover),
                            ),
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _BatchDrawPainter([
                                  ..._strokes,
                                  if (_activeStroke != null) _activeStroke!,
                                ]),
                              ),
                            ),
                            if (_drawMode)
                              Positioned.fill(
                                child: GestureDetector(
                                  onPanStart: (details) {
                                    _activeStroke =
                                        _BatchStroke(_drawColor, 5.0)
                                          ..points.add(details.localPosition);
                                    setState(() {});
                                  },
                                  onPanUpdate: (details) {
                                    _activeStroke?.points
                                        .add(details.localPosition);
                                    setState(() {});
                                  },
                                  onPanEnd: (_) {
                                    if (_activeStroke != null) {
                                      _strokes.add(_activeStroke!);
                                      _activeStroke = null;
                                    }
                                    setState(() {});
                                  },
                                ),
                              ),
                            ..._textLayers.map(
                              (t) => Positioned(
                                left: t.position.dx,
                                top: t.position.dy,
                                child: GestureDetector(
                                  onPanUpdate: (details) => setState(
                                      () => t.position += details.delta),
                                  onLongPress: () =>
                                      setState(() => _textLayers.remove(t)),
                                  child: Text(
                                    t.text,
                                    style: TextStyle(
                                      color: t.color,
                                      fontSize: t.fontSize,
                                      fontWeight: FontWeight.bold,
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black54,
                                          blurRadius: 6,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        if (_drawMode)
          Positioned(
            bottom: 82,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _drawColors
                  .map((c) => GestureDetector(
                        onTap: () => setState(() => _drawColor = c),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: _drawColor == c ? 28 : 22,
                          height: _drawColor == c ? 28 : 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c,
                            border: Border.all(
                              color: Colors.white,
                              width: _drawColor == c ? 2.5 : 1.0,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: _cropping
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _iconCircle(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onTap: () => setState(() => _cropping = false),
                      bg: Colors.white,
                    ),
                    Row(
                      children: [
                        _rotating
                            ? const SizedBox(
                                width: 40,
                                height: 40,
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : _iconCircle(
                                icon: const Icon(Icons.rotate_right,
                                    color: Colors.black),
                                onTap: _rotate,
                                bg: Colors.white,
                              ),
                        const SizedBox(width: 15),
                        _iconCircle(
                          icon: const Icon(Icons.check, color: Colors.black),
                          onTap: () => _cropController.crop(),
                          bg: Colors.white,
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _iconCircle(
                      icon:
                          const Icon(Icons.delete_outline, color: Colors.white),
                      onTap: _confirmRemove,
                    ),
                    Row(
                      children: [
                        _iconCircle(
                          icon: const Icon(Icons.crop_rotate,
                              color: Colors.white),
                          onTap: () => setState(() => _cropping = true),
                        ),
                        const SizedBox(width: 12),
                        _iconCircle(
                          icon: const Icon(Icons.abc_rounded,
                              color: Colors.white),
                          onTap: _addTextLayer,
                        ),
                        const SizedBox(width: 12),
                        _iconCircle(
                          icon: Icon(Icons.edit,
                              color: _drawMode
                                  ? const Color(0xFF935CCC)
                                  : Colors.white),
                          onTap: () => setState(() => _drawMode = !_drawMode),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
