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

import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/custom_code/actions/index.dart';

class LiveCameraCapture extends StatefulWidget {
  const LiveCameraCapture({
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
  State<LiveCameraCapture> createState() => _LiveCameraCaptureState();
}

class _LiveCameraCaptureState extends State<LiveCameraCapture> {
  CameraController? _controller;
  bool _permissionDenied = false;
  bool _isVideoMode = false;
  bool _isRecording = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (!mounted) return;
      setState(() => _permissionDenied = true);
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() => _error = 'No camera found on this device');
        return;
      }
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: true,
      );
      await controller.initialize();
      if (!mounted) return;
      setState(() => _controller = controller);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _handleCapture() async {
    if (_controller == null || _busy) return;

    if (!_isVideoMode) {
      setState(() => _busy = true);
      try {
        final file = await _controller!.takePicture();
        await _uploadAndPost(file, 'image');
      } catch (e) {
        _showError(e.toString());
      } finally {
        if (mounted) setState(() => _busy = false);
      }
      return;
    }

    if (!_isRecording) {
      try {
        await _controller!.startVideoRecording();
        setState(() => _isRecording = true);
      } catch (e) {
        _showError(e.toString());
      }
    } else {
      setState(() => _busy = true);
      try {
        final file = await _controller!.stopVideoRecording();
        setState(() => _isRecording = false);
        await _uploadAndPost(file, 'video');
      } catch (e) {
        _showError(e.toString());
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    }
  }

  Future<void> _uploadAndPost(XFile file, String mediaType) async {
    final bytes = await file.readAsBytes();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final path = 'status_media/$fileName';

    await SupaFlow.client.storage.from('chat-media').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    final url = SupaFlow.client.storage.from('chat-media').getPublicUrl(path);

    final storySettings = await getOrCreateStorySettings(widget.currentUserId);
    await postStory(
      widget.currentUserId,
      url,
      mediaType,
      '',
      '',
      widget.taggedUserIds,
      0,
      storySettings.durationHours ?? 24,
      '',
    );

    final refreshed = await getMyStories(widget.currentUserId);
    FFAppState().myStoryGroup = refreshed;

    if (!mounted) return;
    widget.onPosted();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Couldn\'t capture: $message')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            if (_controller != null && _controller!.value.isInitialized)
              Positioned.fill(child: CameraPreview(_controller!))
            else if (_permissionDenied)
              const Center(
                child: Text('Camera permission denied',
                    style: TextStyle(color: Colors.white70)),
              )
            else if (_error != null)
              Center(
                child: Text(_error!,
                    style: const TextStyle(color: Colors.white70)),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            Positioned(
              top: 40,
              left: 16,
              child: InkWell(
                onTap: () => widget.onClose(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _modeButton('PHOTO', !_isVideoMode),
                      const SizedBox(width: 20),
                      _modeButton('VIDEO', _isVideoMode),
                    ],
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: _busy ? null : _handleCapture,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: _isRecording ? Colors.red : Colors.white24,
                      ),
                      alignment: Alignment.center,
                      child: _busy
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeButton(String label, bool selected) {
    return InkWell(
      onTap: _isRecording
          ? null
          : () => setState(() => _isVideoMode = label == 'VIDEO'),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.orangeAccent : Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
