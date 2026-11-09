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

Future<void> sendStagedImageMessages(
  String conversationId,
  String senderId,
  List<String> imageUrls,
  String caption,
  String? replyToMessageId,
  String? replyToContent,
  bool replyToIsOwn,
) async {
  final cleanReplyToMessageId =
      (replyToMessageId == null || replyToMessageId.isEmpty)
          ? null
          : replyToMessageId;
  final cleanReplyToContent = (replyToContent == null || replyToContent.isEmpty)
      ? null
      : replyToContent;

  if (imageUrls.isEmpty) return;

  // Each entry is "video::<url>[::<thumbUrl>]" or "image::<url>[::<thumbUrl>]"
  // (from uploadStagedAssets), or a bare URL (older/web callers).
  final images = <String>[];
  final imageThumbs = <String?>[];
  final videos = <String>[];
  final videoThumbs = <String?>[];

  for (final entry in imageUrls) {
    final isVideo = entry.startsWith('video::');
    final isImage = entry.startsWith('image::');
    if (!isVideo && !isImage) {
      images.add(entry);
      imageThumbs.add(null);
      continue;
    }
    final parts = entry.split('::');
    final url = parts.length > 1 ? parts[1] : '';
    final thumb = parts.length > 2 && parts[2].isNotEmpty ? parts[2] : null;
    if (url.isEmpty) continue;
    if (isVideo) {
      videos.add(url);
      videoThumbs.add(thumb);
    } else {
      images.add(url);
      imageThumbs.add(thumb);
    }
  }

  // Videos: one message per video.
  for (var i = 0; i < videos.length; i++) {
    await SupaFlow.client.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': senderId,
      'message_type': 'video',
      'media_url': videos[i],
      'thumbnail_url': videoThumbs[i],
      'content': (i == 0 && caption.isNotEmpty) ? caption : null,
      'reply_to_message_id': i == 0 ? cleanReplyToMessageId : null,
      'reply_to_content': i == 0 ? cleanReplyToContent : null,
      'reply_to_is_own': i == 0 ? replyToIsOwn : false,
    });
  }

  if (images.isEmpty) return;

  final attachReplyHere = videos.isEmpty;

  if (images.length == 1) {
    await SupaFlow.client.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': senderId,
      'message_type': 'image',
      'media_url': images[0],
      'thumbnail_url': imageThumbs[0],
      'content': (attachReplyHere && caption.isNotEmpty) ? caption : null,
      'reply_to_message_id': attachReplyHere ? cleanReplyToMessageId : null,
      'reply_to_content': attachReplyHere ? cleanReplyToContent : null,
      'reply_to_is_own': attachReplyHere ? replyToIsOwn : false,
    });
    return;
  }

  await SupaFlow.client.from('messages').insert({
    'conversation_id': conversationId,
    'sender_id': senderId,
    'message_type': 'image_group',
    'media_url': images[0],
    'media_urls': images,
    'content': (attachReplyHere && caption.isNotEmpty) ? caption : null,
    'reply_to_message_id': attachReplyHere ? cleanReplyToMessageId : null,
    'reply_to_content': attachReplyHere ? cleanReplyToContent : null,
    'reply_to_is_own': attachReplyHere ? replyToIsOwn : false,
  });
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
