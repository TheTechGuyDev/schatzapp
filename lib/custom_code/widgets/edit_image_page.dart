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

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/foundation.dart' show compute, kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

class _TextLayer {
  _TextLayer({
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

class _Stroke {
  _Stroke(this.color, this.width) : points = [];
  final Color color;
  final double width;
  final List<Offset> points;
}

class _DrawPainter extends CustomPainter {
  _DrawPainter(this.strokes);
  final List<_Stroke> strokes;

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
  bool shouldRepaint(covariant _DrawPainter oldDelegate) => true;
}

Uint8List _rotateBytes90(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;
  final rotated = img.copyRotate(decoded, angle: 90);
  return Uint8List.fromList(img.encodeJpg(rotated, quality: 92));
}

/// Full-screen image editor.
///
/// Pushed directly with Navigator.push from other custom widgets (the
/// multi-image preview screen, and the sent-image viewer) - it is never
/// placed on a Canvas page.
///
/// [imageBytes] must already be resolved to bytes by the caller (from a local
/// file, a gallery asset, or a downloaded network image).
///
/// [mode] is either: - 'batchPreview': shows a checkmark. Saves the edit and
/// hands it back to the caller via [onSaved] - no network call happens here.
/// - 'resend': shows a paper-plane. Uploads and sends a brand new message
/// directly to [conversationId] as [currentUserId].
class EditImagePage extends StatefulWidget {
  const EditImagePage({
    super.key,
    this.width,
    this.height,
    required this.imageBytes,
    required this.mode,
    this.conversationId,
    this.currentUserId,
    this.initialCaption = '',
    this.onSaved,
  });

  final double? width;
  final double? height;
  final dynamic imageBytes;
  final String mode;
  final String? conversationId;
  final String? currentUserId;
  final String initialCaption;

  /// Required when mode == 'batchPreview'.
  final Future Function(
    dynamic editedBytes,
    String caption,
    String? voiceNotePath,
    int voiceNoteSeconds,
  )? onSaved;

  @override
  State<EditImagePage> createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> {
  late Uint8List _baseImage;
  double? _imgWidth;
  double? _imgHeight;

  final GlobalKey _boundaryKey = GlobalKey();
  final CropController _cropController = CropController();
  late final TextEditingController _captionController;

  bool _cropping = false;
  bool _drawMode = false;
  bool _recordingVoice = false;
  bool _rotating = false;
  bool _saving = false;

  Color _drawColor = Colors.redAccent;

  static const List<Color> _drawColorChoices = [
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.yellowAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.white,
    Colors.black,
  ];

  String? _voiceNotePath;
  int _voiceNoteSeconds = 0;

  final List<_TextLayer> _textLayers = [];
  final List<_Stroke> _strokes = [];
  _Stroke? _activeStroke;

  bool get _hasEdits =>
      _textLayers.isNotEmpty ||
      _strokes.isNotEmpty ||
      _voiceNotePath != null ||
      _captionController.text.trim().isNotEmpty ||
      !identical(_baseImage, widget.imageBytes);

  @override
  void initState() {
    super.initState();
    _baseImage = widget.imageBytes as Uint8List;
    _captionController = TextEditingController(text: widget.initialCaption);
    _decodeDimensions();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _decodeDimensions() async {
    final descriptor = await ui.instantiateImageCodec(_baseImage);
    final frame = await descriptor.getNextFrame();
    if (!mounted) return;
    setState(() {
      _imgWidth = frame.image.width.toDouble();
      _imgHeight = frame.image.height.toDouble();
    });
  }

  Future<void> _rotate() async {
    setState(() => _rotating = true);
    final rotated = await compute(_rotateBytes90, _baseImage);
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
        _TextLayer(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          position: const Offset(60, 200),
        ),
      );
    });
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasEdits) return true;
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

  Future<Uint8List> _composeFinalImage() async {
    final boundary = _boundaryKey.currentContext!.findRenderObject()
        as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _download() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Download isn't available on web yet.")),
      );
      return;
    }
    final bytes = await _composeFinalImage();
    try {
      await Gal.putImageBytes(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to your gallery.')));
    } on GalException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.type.message)));
    }
  }

  Future<void> _handleDone() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final finalBytes = await _composeFinalImage();
      final caption = _captionController.text.trim();

      if (widget.mode == 'batchPreview') {
        await widget.onSaved?.call(
          finalBytes,
          caption,
          _voiceNotePath,
          _voiceNoteSeconds,
        );
        if (mounted) Navigator.pop(context);
        return;
      }

      // resend mode: upload and send directly.
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'chat_media/$fileName';
      await SupaFlow.client.storage.from('chat-media').uploadBinary(
            path,
            finalBytes,
            fileOptions: const FileOptions(upsert: true),
          );
      final url = SupaFlow.client.storage.from('chat-media').getPublicUrl(path);

      await sendStagedImageMessages(
        widget.conversationId!,
        widget.currentUserId!,
        [url],
        caption,
        null,
        null,
        false,
      );

      if (_voiceNotePath != null) {
        final voiceUrl = await uploadVoiceNote(_voiceNotePath!);
        if (voiceUrl != null && voiceUrl.isNotEmpty) {
          await MessagesTable().insert({
            'conversation_id': widget.conversationId,
            'sender_id': widget.currentUserId,
            'message_type': 'voice_note',
            'media_url': voiceUrl,
            'duration_seconds': _voiceNoteSeconds,
          });
        }
      }

      if (mounted) {
        // resend mode is opened from the sent-image full-screen viewer, which
        // was itself pushed on top of the chat page. Pop both routes so the
        // user lands back on the chat page immediately, not the viewer.
        Navigator.of(context)
          ..pop()
          ..pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _iconCircle({required Widget icon, required VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          shape: BoxShape.circle,
        ),
        child: Center(child: icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = _imgWidth != null && _imgHeight != null;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: WillPopScope(
        onWillPop: () async {
          if (_cropping) {
            setState(() => _cropping = false);
            return false;
          }
          return _confirmDiscard();
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: !ready
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: _cropping
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24.0, vertical: 40.0),
                                      child: Crop(
                                        controller: _cropController,
                                        image: _baseImage,
                                        onCropped: (result) {
                                          switch (result) {
                                            case CropSuccess(
                                                :final croppedImage
                                              ):
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
                                  : Center(
                                      child: AspectRatio(
                                        aspectRatio: _imgWidth! / _imgHeight!,
                                        child: RepaintBoundary(
                                          key: _boundaryKey,
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: Image.memory(_baseImage,
                                                    fit: BoxFit.cover),
                                              ),
                                              Positioned.fill(
                                                child: CustomPaint(
                                                  painter: _DrawPainter([
                                                    ..._strokes,
                                                    if (_activeStroke != null)
                                                      _activeStroke!,
                                                  ]),
                                                ),
                                              ),
                                              if (_drawMode)
                                                Positioned.fill(
                                                  child: GestureDetector(
                                                    onPanStart: (details) {
                                                      _activeStroke = _Stroke(
                                                          _drawColor, 5.0)
                                                        ..points.add(details
                                                            .localPosition);
                                                      setState(() {});
                                                    },
                                                    onPanUpdate: (details) {
                                                      _activeStroke?.points.add(
                                                          details
                                                              .localPosition);
                                                      setState(() {});
                                                    },
                                                    onPanEnd: (_) {
                                                      if (_activeStroke !=
                                                          null) {
                                                        _strokes.add(
                                                            _activeStroke!);
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
                                                    onPanUpdate: (details) {
                                                      setState(() {
                                                        t.position +=
                                                            details.delta;
                                                      });
                                                    },
                                                    onLongPress: () {
                                                      setState(() => _textLayers
                                                          .remove(t));
                                                    },
                                                    child: Text(
                                                      t.text,
                                                      style: TextStyle(
                                                        color: t.color,
                                                        fontSize: t.fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        shadows: const [
                                                          Shadow(
                                                            color:
                                                                Colors.black54,
                                                            blurRadius: 6,
                                                            offset:
                                                                Offset(0, 1),
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
                            Positioned(
                              top: 10.0,
                              left: 16.0,
                              right: 16.0,
                              child: _cropping
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _iconCircle(
                                          icon: const Icon(Icons.close,
                                              color: Colors.black),
                                          onTap: () =>
                                              setState(() => _cropping = false),
                                        ),
                                        Row(
                                          children: [
                                            _rotating
                                                ? const SizedBox(
                                                    width: 40,
                                                    height: 40,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2),
                                                    ),
                                                  )
                                                : _iconCircle(
                                                    icon: const Icon(
                                                        Icons.rotate_right,
                                                        color: Colors.black),
                                                    onTap: _rotate,
                                                  ),
                                            const SizedBox(width: 15.0),
                                            _iconCircle(
                                              icon: const Icon(Icons.check,
                                                  color: Colors.black),
                                              onTap: () =>
                                                  _cropController.crop(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _iconCircle(
                                          icon: Icon(Icons.arrow_back,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              size: 24.0),
                                          onTap: () async {
                                            if (await _confirmDiscard()) {
                                              if (mounted) {
                                                Navigator.pop(context);
                                              }
                                            }
                                          },
                                        ),
                                        Row(
                                          children: [
                                            _iconCircle(
                                              icon: Icon(
                                                  Icons.download_outlined,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 24.0),
                                              onTap: _download,
                                            ),
                                            const SizedBox(width: 15.0),
                                            _iconCircle(
                                              icon: Icon(Icons.crop_rotate,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 24.0),
                                              onTap: () => setState(
                                                  () => _cropping = true),
                                            ),
                                            const SizedBox(width: 15.0),
                                            _iconCircle(
                                              icon: Icon(Icons.abc_rounded,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 26.0),
                                              onTap: _addTextLayer,
                                            ),
                                            const SizedBox(width: 15.0),
                                            _iconCircle(
                                              icon: Icon(Icons.edit,
                                                  color: _drawMode
                                                      ? const Color(0xFF935CCC)
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  size: 24.0),
                                              onTap: () => setState(
                                                  () => _drawMode = !_drawMode),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                            ),
                            if (_drawMode && !_cropping)
                              Positioned(
                                top: 60.0,
                                left: 16.0,
                                right: 16.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _drawColorChoices.map((color) {
                                    final selected = color == _drawColor;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0),
                                      child: GestureDetector(
                                        onTap: () =>
                                            setState(() => _drawColor = color),
                                        child: Container(
                                          width: selected ? 30.0 : 24.0,
                                          height: selected ? 30.0 : 24.0,
                                          decoration: BoxDecoration(
                                            color: color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: selected
                                                  ? Colors.white
                                                  : Colors.white54,
                                              width: selected ? 2.5 : 1.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (!_cropping)
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              15.0, 5.0, 15.0, 10.0),
                          child: Material(
                            color: Colors.transparent,
                            elevation: 0.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(30.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  width: 2.0,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: _recordingVoice
                                    ? VoiceRecorderBar(
                                        width: double.infinity,
                                        height: 56.0,
                                        onCancel: () async {
                                          setState(
                                              () => _recordingVoice = false);
                                        },
                                        onSend:
                                            (filePath, durationSeconds) async {
                                          setState(() {
                                            _voiceNotePath = filePath;
                                            _voiceNoteSeconds = durationSeconds;
                                            _recordingVoice = false;
                                          });
                                        },
                                      )
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (_voiceNotePath != null)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 4, 10, 4),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.mic,
                                                      size: 16.0,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary),
                                                  const SizedBox(width: 6.0),
                                                  Text(
                                                    'Voice note (${_voiceNoteSeconds}s) attached',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall,
                                                  ),
                                                  const Spacer(),
                                                  InkWell(
                                                    onTap: () => setState(() {
                                                      _voiceNotePath = null;
                                                      _voiceNoteSeconds = 0;
                                                    }),
                                                    child: const Icon(
                                                        Icons.close,
                                                        size: 16.0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(9.0, 0.0, 9.0, 0.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 0.0, 0.0, 8.0),
                                                  child: FaIcon(
                                                    FontAwesomeIcons.images,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 20.0,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: TextFormField(
                                                    controller:
                                                        _captionController,
                                                    autofocus: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      border: InputBorder.none,
                                                      hintText:
                                                          'Add a caption...',
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium,
                                                    maxLines: 5,
                                                    minLines: 1,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 0.0, 0.0, 8.0),
                                                  child: InkWell(
                                                    onTap: () => setState(() =>
                                                        _recordingVoice = true),
                                                    child: Icon(Icons.mic_none,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        size: 26.0),
                                                  ),
                                                ),
                                                const SizedBox(width: 5.0),
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 0.0, 0.0, 8.0),
                                                  child: _saving
                                                      ? const SizedBox(
                                                          width: 26,
                                                          height: 26,
                                                          child:
                                                              CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2),
                                                        )
                                                      : InkWell(
                                                          onTap: _handleDone,
                                                          child: Icon(
                                                            widget.mode ==
                                                                    'batchPreview'
                                                                ? Icons.check
                                                                : Icons
                                                                    .send_outlined,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                            size: 26.0,
                                                          ),
                                                        ),
                                                ),
                                              ],
                                            ),
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
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
