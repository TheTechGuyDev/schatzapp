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

/// Right side of a row in "people viewed your story":
/// - the viewer's reactions to this story (max 2 emoji), then
/// - "..." (Accept / Decline) if they sent you a request you haven't
///   accepted yet, so they can't message you, or
/// - a message icon that opens your chat with them.
/// After Decline the row shows only the reactions.
class ViewerMoreButton extends StatefulWidget {
  const ViewerMoreButton({
    super.key,
    this.width,
    this.height,
    required this.viewerId,
    this.statusId,
    this.displayName,
    this.avatarUrl,
  });

  final double? width;
  final double? height;
  final String viewerId;
  final String? statusId;
  final String? displayName;
  final String? avatarUrl;

  @override
  State<ViewerMoreButton> createState() => _ViewerMoreButtonState();
}

class _ViewerMoreButtonState extends State<ViewerMoreButton> {
  static const Color _purple = Color(0xFF935CCC);

  String? _notifId;
  bool _loaded = false;
  bool _declined = false;
  bool _busy = false;
  List<String> _reactions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ViewerMoreButton old) {
    super.didUpdateWidget(old);
    if (old.viewerId != widget.viewerId || old.statusId != widget.statusId) {
      _load();
    }
  }

  Future<void> _load() async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null || widget.viewerId.isEmpty) return;
    await Future.wait([_loadRequest(uid), _loadReactions()]);
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _loadRequest(String uid) async {
    try {
      final r = await SupaFlow.client
          .from('notifications')
          .select('id')
          .eq('user_id', uid)
          .eq('from_user_id', widget.viewerId)
          .eq('status', 'pending')
          .inFilter('type', ['friend_request', 'message_request'])
          .order('created_at', ascending: false)
          .limit(1);
      _notifId = (r as List).isEmpty ? null : r.first['id'].toString();
    } catch (_) {
      _notifId = null;
    }
  }

  Future<void> _loadReactions() async {
    final statusId = widget.statusId ?? '';
    if (statusId.isEmpty) {
      _reactions = [];
      return;
    }
    try {
      final rows = await SupaFlow.client
          .from('status_reactions')
          .select('reaction_type')
          .eq('status_id', statusId)
          .eq('user_id', widget.viewerId);
      final types = <String>{};
      for (final row in rows) {
        final t = row['reaction_type'] as String?;
        if (t == null) continue;
        types.add(t == 'thumbs' ? 'laugh' : t);
      }
      // Keep the app's reaction order.
      _reactions = kReactionTypes.where(types.contains).toList();
    } catch (_) {
      _reactions = [];
    }
  }

  void _toast(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _respond(bool accept) async {
    final id = _notifId;
    if (id == null || _busy) return;
    setState(() => _busy = true);
    try {
      await SupaFlow.client.rpc('respond_notification',
          params: {'p_id': id, 'p_accept': accept});
      _toast(accept
          ? 'Accepted. You can now see each other\'s stories and message.'
          : 'Declined');
      _notifId = null;
      _declined = !accept;
    } catch (_) {
      _toast('Could not complete that. Try again.');
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _openChat() async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null || _busy) return;
    setState(() => _busy = true);
    try {
      await openSavedContactAction(
        'message',
        uid,
        widget.viewerId,
        widget.displayName ?? '',
        widget.avatarUrl ?? '',
        widget.displayName ?? '',
        '',
      );
    } catch (_) {
      _toast('Could not open the chat. Try again.');
    }
    if (mounted) setState(() => _busy = false);
  }

  Widget _emoji(String type) {
    if (type == 'favorite') {
      return const Icon(Icons.favorite, color: Color(0xFFE0245E), size: 22);
    }
    return Text(
      kReactionEmoji[type] ?? '',
      style: const TextStyle(fontSize: 19, height: 1.1),
    );
  }

  Widget _action() {
    if (!_loaded || _declined) return const SizedBox(width: 40, height: 40);

    if (_notifId != null) {
      return SizedBox(
        width: 40,
        height: 40,
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          tooltip: 'Message request',
          icon: const Icon(Icons.more_horiz, color: Colors.black87, size: 26),
          onSelected: (v) => _respond(v == 'accept'),
          itemBuilder: (_) => const [
            PopupMenuItem<String>(value: 'accept', child: Text('Accept')),
            PopupMenuItem<String>(value: 'decline', child: Text('Decline')),
          ],
        ),
      );
    }

    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        padding: EdgeInsets.zero,
        tooltip: 'Message',
        onPressed: _openChat,
        icon: const Icon(Icons.chat_bubble_outline_rounded,
            color: Color(0xFF111B21), size: 25),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final t in _reactions)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _emoji(t),
          ),
        if (_reactions.isNotEmpty) const SizedBox(width: 6),
        _busy
            ? const SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _purple),
                  ),
                ),
              )
            : _action(),
      ],
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
