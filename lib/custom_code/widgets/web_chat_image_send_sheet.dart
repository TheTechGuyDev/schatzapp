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

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'dart:typed_data';
import '/custom_code/actions/index.dart';

class WebChatImageSendSheet extends StatefulWidget {
  const WebChatImageSendSheet({
    super.key,
    this.width,
    this.height,
    required this.conversationId,
    required this.senderId,
    this.replyToMessageId,
    this.replyToContent,
    required this.replyToIsOwn,
    required this.onDone,
  });

  final double? width;
  final double? height;
  final String conversationId;
  final String senderId;
  final String? replyToMessageId;
  final String? replyToContent;
  final bool replyToIsOwn;
  final Future Function() onDone;

  @override
  State<WebChatImageSendSheet> createState() => _WebChatImageSendSheetState();
}

class _WebChatImageSendSheetState extends State<WebChatImageSendSheet> {
  List<PendingWebImageStruct> _picked = [];
  bool _loading = true;
  bool _sending = false;
  final TextEditingController _captionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pick();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final result = await pickMultipleWebStoryImages();
    if (!mounted) return;
    if (result.isEmpty) {
      await widget.onDone();
      return;
    }
    setState(() {
      _picked = result;
      _loading = false;
    });
  }

  Future<void> _send() async {
    if (_sending || _picked.isEmpty) return;
    setState(() => _sending = true);

    try {
      final urls = <String>[];
      for (var i = 0; i < _picked.length; i++) {
        final bytes = base64Decode(_picked[i].base64Data);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final path = 'chat_media/$fileName';

        await SupaFlow.client.storage.from('chat-media').uploadBinary(
              path,
              bytes,
              fileOptions: const FileOptions(upsert: true),
            );
        urls.add(SupaFlow.client.storage.from('chat-media').getPublicUrl(path));
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
      await widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: _loading
              ? const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator()),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_picked.length} image(s) selected',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _picked.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final bytes = base64Decode(_picked[i].base64Data);
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                bytes,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _captionController,
                          decoration: const InputDecoration(
                            hintText: 'Add a caption...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: InkWell(
                          onTap: _sending ? null : _send,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFF935CCC),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            alignment: Alignment.center,
                            child: _sending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Send',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
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
