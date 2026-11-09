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

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:mime_type/mime_type.dart';
import 'package:pdfx/pdfx.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lets the user pick any document, uploads it and sends it as a document
/// message. PDFs also get a first-page preview image and a page count.
/// Returns true when a document was sent.
Future<bool> pickAndSendDocument(
  String conversationId,
  String senderId,
) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return false;

    final picked = result.files.first;
    Uint8List? bytes = picked.bytes;
    if (bytes == null && picked.path != null) {
      bytes = await File(picked.path!).readAsBytes();
    }
    if (bytes == null || bytes.isEmpty) return false;

    // Storage limit guard (50 MB).
    if (bytes.length > 50 * 1024 * 1024) return false;

    final name = picked.name;
    final safe = name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final base = 'documents/${DateTime.now().millisecondsSinceEpoch}_$safe';

    // First-page preview and page count for PDFs.
    int? pageCount;
    Uint8List? previewBytes;
    if (!kIsWeb && name.toLowerCase().endsWith('.pdf')) {
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
        previewBytes = img?.bytes;
        await page.close();
        await doc.close();
      } catch (_) {}
    }

    await SupaFlow.client.storage.from('chat-media').uploadBinary(
          base,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: mime(name) ?? 'application/octet-stream',
          ),
        );
    final url = SupaFlow.client.storage.from('chat-media').getPublicUrl(base);

    String? thumbUrl;
    if (previewBytes != null && previewBytes.isNotEmpty) {
      try {
        final thumbPath = '${base}_preview.jpg';
        await SupaFlow.client.storage.from('chat-media').uploadBinary(
              thumbPath,
              previewBytes,
              fileOptions:
                  const FileOptions(upsert: true, contentType: 'image/jpeg'),
            );
        thumbUrl =
            SupaFlow.client.storage.from('chat-media').getPublicUrl(thumbPath);
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
    return true;
  } catch (_) {
    return false;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
