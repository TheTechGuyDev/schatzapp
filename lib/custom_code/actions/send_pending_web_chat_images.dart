// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image/image.dart' as imglib;
import 'package:flutter/foundation.dart' show compute;
import 'package:mime_type/mime_type.dart';
import 'package:pdfx/pdfx.dart';

class PendingChatSend {
  PendingChatSend({
    required this.id,
    required this.conversationId,
    required this.previewBytesList,
    required this.mediaTypes,
    required this.caption,
    this.hasError = false,
    this.errorText = '',
  });
  final String id;
  final String conversationId;
  final List<Uint8List> previewBytesList;
  final List<String> mediaTypes;
  final String caption;
  bool hasError;
  String errorText;
}

final ValueNotifier<List<PendingChatSend>> pendingChatSendsNotifier =
    ValueNotifier<List<PendingChatSend>>([]);

void removePendingChatSend(String id) {
  pendingChatSendsNotifier.value =
      pendingChatSendsNotifier.value.where((p) => p.id != id).toList();
}

// args: [Uint8List bytes, int maxDim (0 = keep full size), int jpegQuality]
Uint8List _compressForChatUpload(List<dynamic> args) {
  final input = args[0] as Uint8List;
  final maxDim = args[1] as int;
  final quality = args[2] as int;

  final decoded = imglib.decodeImage(input);
  if (decoded == null) return input;

  var resized = decoded;
  if (maxDim > 0 && (decoded.width > maxDim || decoded.height > maxDim)) {
    resized = decoded.width >= decoded.height
        ? imglib.copyResize(decoded, width: maxDim)
        : imglib.copyResize(decoded, height: maxDim);
  }

  return Uint8List.fromList(imglib.encodeJpg(resized, quality: quality));
}

Future<void> _putBinary(
    String path, Uint8List bytes, String contentType) async {
  await SupaFlow.client.storage.from('chat-media').uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(upsert: true, contentType: contentType),
      );
}

String _publicUrl(String path) =>
    SupaFlow.client.storage.from('chat-media').getPublicUrl(path);

// Photos and videos. Returns "image::url[::thumbUrl]" or "video::url".
Future<String?> _uploadOne(
    Uint8List bytes, String mediaType, int index, String quality) async {
  final isVideo = mediaType == 'video';
  final stamp = DateTime.now().millisecondsSinceEpoch;

  if (isVideo) {
    final path = 'chat_media/${stamp}_$index.mp4';
    await _putBinary(path, bytes, 'video/mp4');
    return 'video::${_publicUrl(path)}';
  }

  final maxDim = quality == 'original' ? 0 : (quality == 'hd' ? 2560 : 1280);
  final jpegQuality = quality == 'original' ? 100 : (quality == 'hd' ? 90 : 75);
  final bytesToUpload = await compute(
      _compressForChatUpload, <dynamic>[bytes, maxDim, jpegQuality]);

  final base = 'chat_media/${stamp}_$index';
  await _putBinary('$base.jpg', bytesToUpload, 'image/jpeg');
  final url = _publicUrl('$base.jpg');

  // Small thumbnail stored beside the photo as "<name>_thumb.jpg".
  String? thumbUrl;
  try {
    final thumb = await compute(
        _compressForChatUpload, <dynamic>[bytesToUpload, 480, 70]);
    await _putBinary('${base}_thumb.jpg', thumb, 'image/jpeg');
    thumbUrl = _publicUrl('${base}_thumb.jpg');
  } catch (_) {}

  return 'image::$url${thumbUrl == null ? '' : '::$thumbUrl'}';
}

// Documents: uploaded as-is and sent as their own message.
Future<void> _sendDocument(
  Uint8List bytes,
  String name,
  int index,
  String conversationId,
  String senderId,
) async {
  final safe = name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  final base =
      'documents/${DateTime.now().millisecondsSinceEpoch}_${index}_$safe';
  await _putBinary(base, bytes, mime(name) ?? 'application/octet-stream');
  final url = _publicUrl(base);

  int? pageCount;
  String? thumbUrl;
  if (name.toLowerCase().endsWith('.pdf')) {
    try {
      final doc = await PdfDocument.openData(bytes);
      pageCount = doc.pagesCount;
      final page = await doc.getPage(1);
      final scale = 900 / page.width;
      final img = await page.render(
        width: page.width * scale,
        height: page.height * scale,
        format: PdfPageImageFormat.jpeg,
        backgroundColor: '#FFFFFF',
        quality: 85,
      );
      await page.close();
      await doc.close();
      final previewBytes = img?.bytes;
      if (previewBytes != null && previewBytes.isNotEmpty) {
        await _putBinary('${base}_preview.jpg', previewBytes, 'image/jpeg');
        thumbUrl = _publicUrl('${base}_preview.jpg');
      }
    } catch (_) {}
  }

  await SupaFlow.client.from('messages').insert({
    'conversation_id': conversationId,
    'sender_id': senderId,
    'message_type': 'document',
    'content': name,
    'media_url': url,
    'media_size_bytes': bytes.length,
    'thumbnail_url': thumbUrl,
    'media_pages': pageCount,
  });
}

Future<String> sendPendingWebChatImages(
  String conversationId,
  String senderId,
  List<PendingWebImageStruct> images,
  String caption,
  String? replyToMessageId,
  String? replyToContent,
  bool replyToIsOwn,
) async {
  final previewBytes =
      images.map((img) => base64Decode(img.base64Data)).toList();
  final mediaTypes = images
      .map((img) => img.mediaType.isNotEmpty ? img.mediaType : 'image')
      .toList();

  final pendingId = DateTime.now().microsecondsSinceEpoch.toString();
  final pending = PendingChatSend(
    id: pendingId,
    conversationId: conversationId,
    previewBytesList: previewBytes,
    mediaTypes: mediaTypes,
    caption: caption,
  );

  pendingChatSendsNotifier.value = [
    ...pendingChatSendsNotifier.value,
    pending,
  ];

  void markFailed(String reason) {
    pendingChatSendsNotifier.value = pendingChatSendsNotifier.value
        .map((p) => p.id == pendingId
            ? (PendingChatSend(
                id: p.id,
                conversationId: p.conversationId,
                previewBytesList: p.previewBytesList,
                mediaTypes: p.mediaTypes,
                caption: p.caption,
                hasError: true,
                errorText: reason,
              ))
            : p)
        .toList();
  }

  final quality = await mediaQualityPreference('');
  bool isDoc(int i) => mediaTypes[i].startsWith('document:');

  List<String?> results;
  try {
    // Upload every photo and video in parallel instead of one at a time.
    results = await Future.wait(
      List.generate(
        previewBytes.length,
        (i) => isDoc(i)
            ? Future<String?>.value(null)
            : _uploadOne(previewBytes[i], mediaTypes[i], i, quality),
      ),
    );

    // Documents go out as their own messages.
    for (var i = 0; i < previewBytes.length; i++) {
      if (!isDoc(i)) continue;
      final name =
          mediaTypes[i].length > 9 ? mediaTypes[i].substring(9) : 'Document';
      await _sendDocument(previewBytes[i], name, i, conversationId, senderId);
    }
  } catch (e) {
    markFailed('Upload failed. Tap to dismiss.');
    return 'Upload failed: $e';
  }

  final uploadedEntries = results.whereType<String>().toList();
  final hasDocs = List.generate(previewBytes.length, isDoc).any((d) => d);

  if (uploadedEntries.isEmpty && !hasDocs) {
    markFailed('Nothing was uploaded. Tap to dismiss.');
    return 'No media was uploaded.';
  }
  if (uploadedEntries.isEmpty) {
    removePendingChatSend(pendingId);
    return '';
  }

  try {
    await sendStagedImageMessages(
      conversationId,
      senderId,
      uploadedEntries,
      caption,
      replyToMessageId,
      replyToContent,
      replyToIsOwn,
    );
  } catch (e) {
    markFailed('Couldn\'t send. Tap to dismiss.');
    return 'Message save failed: $e';
  }

  removePendingChatSend(pendingId);
  return '';
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
