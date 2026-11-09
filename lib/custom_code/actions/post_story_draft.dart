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
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as imglib;
import 'package:flutter/foundation.dart' show compute;
import 'package:path_provider/path_provider.dart';
import 'package:light_compressor/light_compressor.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:uuid/uuid.dart';

// args: [Uint8List bytes, int maxDim (0 = keep full size), int jpegQuality]
Uint8List _compressForUpload(List<dynamic> args) {
  final input = args[0] as Uint8List;
  final maxDim = args[1] as int;
  final quality = args[2] as int;

  final decoded = imglib.decodeImage(input);
  if (decoded == null) return input;

  var resized = decoded;
  if (maxDim > 0 && (decoded.width > maxDim || decoded.height > maxDim)) {
    resized = decoded.width >= decoded.height
        ? imglib.copyResize(decoded,
            width: maxDim, interpolation: imglib.Interpolation.cubic)
        : imglib.copyResize(decoded,
            height: maxDim, interpolation: imglib.Interpolation.cubic);
  }

  return Uint8List.fromList(imglib.encodeJpg(resized, quality: quality));
}

// Returns [videoBytes, firstFrameJpeg?]. The first frame is uploaded next to
// the video so viewers see a picture instantly while the video loads.
Future<List<Uint8List?>> _processVideo(
    Uint8List rawBytes, int index, String quality) async {
  File? tempInputFile;
  Uint8List? thumb;
  Uint8List outBytes = rawBytes;
  try {
    final tempDir = await getTemporaryDirectory();
    tempInputFile = File(
      '${tempDir.path}/story_draft_${DateTime.now().millisecondsSinceEpoch}_$index.mp4',
    );
    await tempInputFile.writeAsBytes(rawBytes);

    try {
      thumb = await VideoThumbnail.thumbnailData(
        video: tempInputFile.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 720,
        quality: 80,
      );
    } catch (_) {}

    // Original: no re-encoding, the story keeps the source quality.
    if (quality != 'original') {
      final response = await LightCompressor().compressVideo(
        path: tempInputFile.path,
        videoQuality: quality == 'hd' ? VideoQuality.high : VideoQuality.medium,
        isMinBitrateCheckEnabled: false,
        video: Video(
          videoName: 'story_${DateTime.now().millisecondsSinceEpoch}.mp4',
        ),
        android: AndroidConfig(isSharedStorage: false, saveAt: SaveAt.Movies),
        ios: IOSConfig(saveInGallery: false),
      );

      if (response is OnSuccess) {
        final compressedFile = File(response.destinationPath);
        outBytes = await compressedFile.readAsBytes();
        unawaited(compressedFile.delete().catchError((_) => compressedFile));
      }
    }
  } catch (_) {
    outBytes = rawBytes;
  } finally {
    if (tempInputFile != null) {
      unawaited(tempInputFile.delete().catchError((_) => tempInputFile!));
    }
  }
  return [outBytes, thumb];
}

Future<void> postStoryDraft(String userId) async {
  try {
    final quality = await mediaQualityPreference('');
    final maxDim = quality == 'original' ? 0 : (quality == 'hd' ? 2560 : 1280);
    final jpegQuality =
        quality == 'original' ? 100 : (quality == 'hd' ? 92 : 82);

    final originals = FFAppState().storyDraftOriginalImages;
    final edited = FFAppState().storyDraftEditedImages;
    final mediaTypes = FFAppState().storyDraftMediaTypes;
    final captions = FFAppState().storyDraftCaptions;
    final carousel = FFAppState().storyDraftCarousel;
    final taggedUserIds = FFAppState().pendingStoryTaggedUserIds;
    final durationHours = FFAppState().storyDraftDurationHours;

    final carouselCount = originals
        .asMap()
        .entries
        .where((e) => e.key < carousel.length && carousel[e.key])
        .length;
    final batchId = carouselCount >= 2 ? const Uuid().v4() : '';

    for (var i = 0; i < originals.length; i++) {
      try {
        final useEdited = i < edited.length && edited[i].isNotEmpty;
        final base64Str = useEdited ? edited[i] : originals[i];
        if (base64Str.isEmpty) continue;

        final rawBytes = base64Decode(base64Str);
        if (rawBytes.isEmpty) continue;

        final mediaType = i < mediaTypes.length ? mediaTypes[i] : 'image';
        final caption = i < captions.length ? captions[i] : '';
        final isInCarousel = i < carousel.length && carousel[i];

        Uint8List bytesToUpload = rawBytes;
        Uint8List? videoThumb;
        var ext = 'png';
        if (mediaType != 'video') {
          bytesToUpload = await compute(
              _compressForUpload, <dynamic>[rawBytes, maxDim, jpegQuality]);
          ext = 'jpg';
        } else {
          final processed = await _processVideo(rawBytes, i, quality);
          bytesToUpload = processed[0] ?? rawBytes;
          videoThumb = processed[1];
          ext = 'mp4';
        }

        final baseName = '${DateTime.now().millisecondsSinceEpoch}_$i';
        final fileName = '$baseName.$ext';
        final path = 'status_media/$fileName';

        await SupaFlow.client.storage.from('chat-media').uploadBinary(
              path,
              bytesToUpload,
              fileOptions: const FileOptions(upsert: true),
            );
        final url =
            SupaFlow.client.storage.from('chat-media').getPublicUrl(path);

        // First frame, stored as "<same name>_thumb.jpg" next to the video.
        if (videoThumb != null && videoThumb.isNotEmpty) {
          try {
            await SupaFlow.client.storage.from('chat-media').uploadBinary(
                  'status_media/${baseName}_thumb.jpg',
                  videoThumb,
                  fileOptions: const FileOptions(
                      upsert: true, contentType: 'image/jpeg'),
                );
          } catch (_) {}
        }

        await postStory(
          userId,
          url,
          mediaType,
          caption,
          '',
          taggedUserIds,
          0,
          durationHours,
          isInCarousel ? batchId : '',
        );
      } catch (_) {
        continue;
      }
    }

    unawaited(
      getMyStories(userId).then((refreshed) {
        FFAppState().myStoryGroup = refreshed;
      }),
    );
  } catch (_) {
  } finally {
    FFAppState().storyDraftOriginalImages = [];
    FFAppState().storyDraftEditedImages = [];
    FFAppState().storyDraftMediaTypes = [];
    FFAppState().storyDraftCaptions = [];
    FFAppState().storyDraftCarousel = [];
    FFAppState().storyDraftEditingIndex = -1;
    FFAppState().storyDraftDurationHours = 24;
    FFAppState().pendingStoryTaggedUserIds = [];
    FFAppState().pendingStoryImagePaths = [];
    FFAppState().pendingWebStoryImages = [];
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
