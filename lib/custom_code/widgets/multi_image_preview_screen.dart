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

import 'dart:io';
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _PreviewItem {
  _PreviewItem(this.identifier, this.isVideo);
  final String identifier;
  bool isVideo;
  Uint8List? editedBytes;
}

bool _looksLikeVideoPath(String identifier) {
  final lower = identifier.toLowerCase();
  return lower.endsWith('.mp4') ||
      lower.endsWith('.mov') ||
      lower.endsWith('.webm') ||
      lower.endsWith('.m4v');
}

/// Shown as a bottom sheet / full-screen dialog from the chat composer,
/// exactly the way WebChatImageSendSheet is shown today.
///
/// Displays every staged image so each can be tapped into EditImagePage, then
/// sends the whole batch with one shared caption once "Send" is tapped.
class MultiImagePreviewScreen extends StatefulWidget {
  const MultiImagePreviewScreen({
    super.key,
    this.width,
    this.height,
    required this.conversationId,
    required this.senderId,
    required this.mediaIdentifiers,
    this.initialCaption = '',
    this.replyToMessageId,
    this.replyToContent,
    required this.replyToIsOwn,
    required this.onDone,
  });

  final double? width;
  final double? height;
  final String conversationId;
  final String senderId;

  /// Same identifier scheme as the composer's stagedMediaUrls: a raw file
  /// path (starts with '/') or a photo_manager gallery asset id.
  final List<String> mediaIdentifiers;

  final String initialCaption;
  final String? replyToMessageId;
  final String? replyToContent;
  final bool replyToIsOwn;

  /// Called only after a successful send, so the composer can clear its
  /// staged media / reply state / caption field. Not called on cancel -
  /// backing out of this screen leaves the composer's staged images intact.
  final Future Function() onDone;

  @override
  State<MultiImagePreviewScreen> createState() =>
      _MultiImagePreviewScreenState();
}

class _MultiImagePreviewScreenState extends State<MultiImagePreviewScreen> {
  late List<_PreviewItem> _items;
  late final TextEditingController _captionController;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _items = widget.mediaIdentifiers
        .map((id) => _PreviewItem(
            id, id.startsWith('/') ? _looksLikeVideoPath(id) : false))
        .toList();
    _captionController = TextEditingController(text: widget.initialCaption);
    _resolveVideoFlags();
  }

  // Gallery-picked videos need an async lookup (AssetEntity.type) to detect,
  // unlike camera file paths which are detected synchronously above.
  Future<void> _resolveVideoFlags() async {
    for (final item in _items) {
      if (item.identifier.startsWith('/')) continue;
      final asset = await AssetEntity.fromId(item.identifier);
      if (asset != null && asset.type == AssetType.video) {
        item.isVideo = true;
        if (mounted) setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<Uint8List> _fullBytes(_PreviewItem item) async {
    if (item.editedBytes != null) return item.editedBytes!;
    if (item.identifier.startsWith('/')) {
      return File(item.identifier).readAsBytes();
    }
    final asset = await AssetEntity.fromId(item.identifier);
    final bytes = await asset?.originBytes;
    if (bytes != null) return bytes;
    final file = await asset?.file;
    return file != null ? await file.readAsBytes() : Uint8List(0);
  }

  Future<void> _openEditor(_PreviewItem item) async {
    if (item.isVideo) return;
    final bytes = await _fullBytes(item);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditImagePage(
          imageBytes: bytes,
          mode: 'batchPreview',
          onSaved:
              (editedBytes, caption, voiceNotePath, voiceNoteSeconds) async {
            setState(() => item.editedBytes = editedBytes);
          },
        ),
      ),
    );
  }

  void _remove(_PreviewItem item) {
    setState(() => _items.remove(item));
    if (_items.isEmpty && mounted) Navigator.pop(context);
  }

  Future<void> _send() async {
    if (_sending || _items.isEmpty) return;
    setState(() => _sending = true);
    try {
      final urls = <String>[];
      for (final item in _items) {
        if (item.editedBytes != null) {
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${item.identifier.hashCode}.png';
          final path = 'upload_media/$fileName';
          await SupaFlow.client.storage.from('chat-media').uploadBinary(
                path,
                item.editedBytes!,
                fileOptions: const FileOptions(upsert: true),
              );
          final url =
              SupaFlow.client.storage.from('chat-media').getPublicUrl(path);
          urls.add('image::$url');
        } else {
          final uploaded = await uploadStagedAssets([item.identifier]);
          urls.addAll(uploaded);
        }
      }

      await sendStagedImageMessages(
        widget.conversationId,
        widget.senderId,
        urls,
        _captionController.text.trim(),
        widget.replyToMessageId,
        widget.replyToContent,
        widget.replyToIsOwn,
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
    await widget.onDone();
    if (mounted) Navigator.pop(context);
  }

  Widget _thumbnail(_PreviewItem item) {
    Widget image;
    if (item.identifier.startsWith('/')) {
      image = Image.file(File(item.identifier),
          fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    } else {
      image = FutureBuilder<AssetEntity?>(
        future: AssetEntity.fromId(item.identifier),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Container(color: const Color(0xFF2A2A2A));
          }
          return FutureBuilder<Uint8List?>(
            future: snapshot.data!
                .thumbnailDataWithSize(const ThumbnailSize.square(300)),
            builder: (context, thumbSnap) {
              if (!thumbSnap.hasData || thumbSnap.data == null) {
                return Container(color: const Color(0xFF2A2A2A));
              }
              return Image.memory(thumbSnap.data!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity);
            },
          );
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (item.editedBytes != null)
            Image.memory(item.editedBytes!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity)
          else
            image,
          if (item.isVideo)
            const Center(
              child: Icon(Icons.play_circle_fill,
                  color: Colors.white70, size: 36.0),
            ),
          if (item.editedBytes != null)
            Positioned(
              bottom: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF935CCC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Edited',
                    style: TextStyle(color: Colors.white, fontSize: 10.0)),
              ),
            ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => _remove(item),
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                child: const Icon(Icons.close, size: 15.0, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Container(
        color: Colors.black,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                    Text('${_items.length} photo(s) selected',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    const SizedBox(width: 24),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: _items.length,
                    itemBuilder: (context, i) {
                      final item = _items[i];
                      return GestureDetector(
                        onTap: () => _openEditor(item),
                        child: _thumbnail(item),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(color: const Color(0xFF3A3A3A)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _captionController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Add a caption...',
                              hintStyle: TextStyle(color: Colors.white54),
                            ),
                            maxLines: 3,
                            minLines: 1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: _sending ? null : _send,
                          child: Container(
                            width: 44,
                            height: 44,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF935CCC),
                            ),
                            child: _sending
                                ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.send,
                                    color: Colors.white, size: 20.0),
                          ),
                        ),
                      ],
                    ),
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
