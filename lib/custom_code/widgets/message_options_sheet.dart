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

import 'dart:ui';
import 'package:flutter/services.dart';

class MessageOptionsSheet extends StatefulWidget {
  const MessageOptionsSheet({
    super.key,
    this.width,
    this.height,
    required this.messageId,
    required this.messageType,
    required this.messageContent,
    required this.mediaUrl,
    required this.isOwn,
    required this.isPinned,
    required this.isImportant,
    required this.currentUserId,
    required this.otherUserId,
    required this.conversationId,
    required this.onReply,
    required this.onEnterSelection,
  });

  final double? width;
  final double? height;
  final String messageId;
  final String messageType;
  final String messageContent;
  final String mediaUrl;
  final bool isOwn;
  final bool isPinned;
  final bool isImportant;
  final String currentUserId;
  final String otherUserId;
  final String conversationId;
  final Future Function(String messageId, String content, bool isOwn) onReply;
  final Future Function(String messageId, String action) onEnterSelection;

  @override
  State<MessageOptionsSheet> createState() => _MessageOptionsSheetState();
}

class _MessageOptionsSheetState extends State<MessageOptionsSheet> {
  static const int _maxPins = 4;

  // Edit rules: 8 min if the other person replied, otherwise 30 min.
  bool _canEdit = false;

  @override
  void initState() {
    super.initState();
    _loadEditEligibility();
  }

  Future<void> _loadEditEligibility() async {
    if (!widget.isOwn ||
        widget.messageType != 'text' ||
        widget.messageId.isEmpty) {
      return;
    }
    try {
      final row = await SupaFlow.client
          .from('messages')
          .select('created_at')
          .eq('id', widget.messageId)
          .maybeSingle();
      if (row == null || row['created_at'] == null) return;
      final createdAt = DateTime.parse(row['created_at'].toString());
      final replies = await SupaFlow.client
          .from('messages')
          .select('id')
          .eq('conversation_id', widget.conversationId)
          .neq('sender_id', widget.currentUserId)
          .gt('created_at', createdAt.toUtc().toIso8601String())
          .limit(1);
      final replied = (replies as List).isNotEmpty;
      final limit = Duration(minutes: replied ? 8 : 30);
      final allowed = DateTime.now().difference(createdAt) <= limit;
      if (mounted && allowed != _canEdit) {
        setState(() => _canEdit = allowed);
      }
    } catch (e) {
      debugPrint('_loadEditEligibility failed: $e');
    }
  }

  Future<void> _togglePin() async {
    if (!widget.isPinned) {
      final pinnedRows = await SupaFlow.client
          .from('messages')
          .select('id')
          .eq('conversation_id', widget.conversationId)
          .eq('is_pinned', true);

      if (pinnedRows.length >= _maxPins) {
        if (mounted) {
          _showToast(context, 'You can only pin up to $_maxPins messages');
        }
        return;
      }
    }

    await SupaFlow.client
        .from('messages')
        .update({'is_pinned': !widget.isPinned}).eq('id', widget.messageId);
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _toggleStar() async {
    try {
      if (widget.isImportant) {
        await SupaFlow.client
            .from('message_stars')
            .delete()
            .eq('user_id', widget.currentUserId)
            .eq('message_id', widget.messageId);
      } else {
        await SupaFlow.client.from('message_stars').upsert({
          'user_id': widget.currentUserId,
          'message_id': widget.messageId,
        });
      }
    } catch (e) {
      debugPrint('_toggleStar failed: $e');
      if (mounted) _showToast(context, 'Could not update. Try again');
      return;
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _editMessage() async {
    Navigator.pop(context);

    final controller = TextEditingController(text: widget.messageContent);
    final newContent = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit message'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: null,
          decoration: const InputDecoration(hintText: 'Message'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newContent == null ||
        newContent.isEmpty ||
        newContent == widget.messageContent) {
      return;
    }

    try {
      await SupaFlow.client.from('messages').update({
        'content': newContent,
        'is_edited': true,
      }).eq('id', widget.messageId);
    } catch (e) {
      debugPrint('_editMessage failed: $e');
    }
  }

  Future<void> _reportMessage() async {
    Navigator.pop(context);

    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Report message'),
        children: [
          _reportReasonTile(dialogContext, 'Spam'),
          _reportReasonTile(dialogContext, 'Harassment'),
          _reportReasonTile(dialogContext, 'Inappropriate content'),
          _reportReasonTile(dialogContext, 'Other'),
        ],
      ),
    );

    if (reason == null) return;

    try {
      await SupaFlow.client.from('message_reports').insert({
        'message_id': widget.messageId,
        'reporter_id': widget.currentUserId,
        'reported_user_id': widget.otherUserId,
        'reason': reason,
      });
      if (mounted) {
        _showToast(context, 'Message reported');
      }
    } catch (e) {
      debugPrint('_reportMessage failed: $e');
    }
  }

  Widget _reportReasonTile(BuildContext dialogContext, String reason) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(dialogContext, reason),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(reason),
      ),
    );
  }

  void _showInfo() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${widget.messageType}'),
            const SizedBox(height: 6),
            Text(widget.isOwn ? 'Sent by you' : 'Received'),
            if (widget.isPinned) const Text('📌 Pinned'),
            if (widget.isImportant) const Text('⭐ Marked as important'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showToast(BuildContext overlayContext, String message) {
    final overlay = Overlay.of(overlayContext);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.42,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10),
                ],
              ),
              child: Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 1400), () {
      entry.remove();
    });
  }

  Widget _optionTile(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 19, color: color ?? Colors.black87),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(fontSize: 14, color: color ?? Colors.black87)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: 200,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 16),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _optionTile(Icons.reply, 'Reply', () async {
                  await widget.onReply(
                      widget.messageId, widget.messageContent, widget.isOwn);
                  if (mounted) Navigator.pop(context);
                }),
                _optionTile(Icons.reply_all_outlined, 'Forward', () async {
                  Navigator.pop(context);
                  await widget.onEnterSelection(widget.messageId, 'forward');
                }),
                _optionTile(Icons.copy, 'Copy', () async {
                  await Clipboard.setData(
                      ClipboardData(text: widget.messageContent));
                  _showToast(context, 'Copied');
                  if (mounted) Navigator.pop(context);
                }),
                _optionTile(Icons.info_outline, 'Info', _showInfo),
                if (_canEdit)
                  _optionTile(Icons.edit_outlined, 'Edit', _editMessage),
                if (!widget.isOwn)
                  _optionTile(Icons.flag_outlined, 'Report', _reportMessage,
                      color: const Color(0xFFE91414)),
                _optionTile(
                    widget.isImportant ? Icons.star : Icons.star_border,
                    widget.isImportant
                        ? 'Unmark as important'
                        : 'Mark as important',
                    _toggleStar),
                _optionTile(
                    widget.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    widget.isPinned ? 'Unpin' : 'Pin',
                    _togglePin),
                _optionTile(Icons.delete_outline, 'Delete', () async {
                  Navigator.pop(context);
                  await widget.onEnterSelection(widget.messageId, 'delete');
                }, color: const Color(0xFFE91414)),
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
