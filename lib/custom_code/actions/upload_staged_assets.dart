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

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async' show unawaited;
import 'dart:io';
import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:light_compressor/light_compressor.dart';

Future<Uint8List?> _compressVideoFile(String inputPath, String quality) async {
  // Original: never re-encode, so the video keeps its source quality.
  if (quality == 'original') return null;
  try {
    final response = await LightCompressor().compressVideo(
      path: inputPath,
      videoQuality: quality == 'hd' ? VideoQuality.high : VideoQuality.medium,
      isMinBitrateCheckEnabled: false,
      video: Video(
        videoName: 'chat_${DateTime.now().millisecondsSinceEpoch}.mp4',
      ),
      android: AndroidConfig(isSharedStorage: false, saveAt: SaveAt.Movies),
      ios: IOSConfig(saveInGallery: false),
    );

    if (response is OnSuccess) {
      final compressedFile = File(response.destinationPath);
      final bytes = await compressedFile.readAsBytes();
      unawaited(compressedFile.delete().catchError((_) => compressedFile));
      return bytes;
    }
    return null;
  } catch (_) {
    return null;
  }
}

Future<String?> _uploadThumb(Uint8List? thumbBytes, String baseName) async {
  if (thumbBytes == null || thumbBytes.isEmpty) return null;
  try {
    final path = 'upload_media/${baseName}_thumb.jpg';
    await SupaFlow.client.storage.from('chat-media').uploadBinary(
          path,
          thumbBytes,
          fileOptions:
              const FileOptions(upsert: true, contentType: 'image/jpeg'),
        );
    return SupaFlow.client.storage.from('chat-media').getPublicUrl(path);
  } catch (_) {
    return null;
  }
}

Future<List<String>> uploadStagedAssets(List<String> assetIds) async {
  final quality = await mediaQualityPreference('');

  final uploadFutures = assetIds.map((identifier) async {
    Uint8List? rawBytes;
    Uint8List? thumbBytes;
    bool isVideo = false;
    bool alreadyRightSize = false;
    String? localVideoPath;

    if (identifier.startsWith('/')) {
      final lower = identifier.toLowerCase();
      isVideo = lower.endsWith('.mp4') ||
          lower.endsWith('.mov') ||
          lower.endsWith('.webm') ||
          lower.endsWith('.m4v');
      if (isVideo) {
        localVideoPath = identifier;
      } else {
        final file = File(identifier);
        if (await file.exists()) {
          rawBytes = await file.readAsBytes();
        }
      }
    } else {
      final asset = await AssetEntity.fromId(identifier);
      if (asset != null) {
        isVideo = asset.type == AssetType.video;
        if (isVideo) {
          final file = await asset.file;
          localVideoPath = file?.path;
          // Real first frame, uploaded separately for instant previews.
          thumbBytes = await asset.thumbnailDataWithSize(
            const ThumbnailSize(640, 640),
            quality: 80,
          );
        } else if (quality == 'original') {
          rawBytes = await asset.originBytes;
        } else {
          final dim = quality == 'hd' ? 2560 : 1280;
          rawBytes = await asset.thumbnailDataWithSize(
            ThumbnailSize(dim, dim),
            quality: quality == 'hd' ? 92 : 80,
          );
          alreadyRightSize = true;
        }
      }
    }

    if (isVideo) {
      if (localVideoPath == null) return null;
      rawBytes = await _compressVideoFile(localVideoPath, quality);
      // Original quality, or compression failed: upload the source file.
      rawBytes ??= await File(localVideoPath).readAsBytes();
    }

    if (rawBytes == null) return null;

    Uint8List bytesToUpload;
    String ext;
    if (isVideo) {
      bytesToUpload = rawBytes;
      ext = 'mp4';
    } else if (alreadyRightSize) {
      bytesToUpload = rawBytes;
      ext = 'jpg';
    } else if (quality == 'original') {
      // One pass only: full resolution, highest quality, JPEG so every
      // device can display it (phone originals can be HEIC).
      bytesToUpload = await FlutterImageCompress.compressWithList(
        rawBytes,
        minWidth: 20000,
        minHeight: 20000,
        quality: 100,
        format: CompressFormat.jpeg,
      );
      ext = 'jpg';
    } else {
      final isHd = quality == 'hd';
      bytesToUpload = await FlutterImageCompress.compressWithList(
        rawBytes,
        minWidth: isHd ? 2560 : 1280,
        minHeight: isHd ? 2560 : 1280,
        quality: isHd ? 90 : 75,
        format: CompressFormat.jpeg,
      );
      ext = 'jpg';
    }

    // Small separate thumbnail for photos (videos got theirs above).
    if (!isVideo) {
      try {
        thumbBytes = await FlutterImageCompress.compressWithList(
          bytesToUpload,
          minWidth: 480,
          minHeight: 480,
          quality: 70,
          format: CompressFormat.jpeg,
        );
      } catch (_) {}
    }

    final baseName =
        '${DateTime.now().millisecondsSinceEpoch}_${identifier.hashCode}';
    final path = 'upload_media/$baseName.$ext';

    await SupaFlow.client.storage.from('chat-media').uploadBinary(
          path,
          bytesToUpload,
          fileOptions: const FileOptions(upsert: true),
        );

    final url = SupaFlow.client.storage.from('chat-media').getPublicUrl(path);
    final thumbUrl = await _uploadThumb(thumbBytes, baseName);
    // "type::url" or "type::url::thumbUrl". sendStagedImageMessages reads it.
    return '${isVideo ? 'video' : 'image'}::$url'
        '${thumbUrl == null ? '' : '::$thumbUrl'}';
  });

  final results = await Future.wait(uploadFutures);
  return results.whereType<String>().toList();
}
