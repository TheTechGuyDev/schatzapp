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

class ViewerMoreButton extends StatefulWidget {
  const ViewerMoreButton({
    super.key,
    this.width,
    this.height,
    required this.viewerId,
  });

  final double? width;
  final double? height;
  final String viewerId;

  @override
  State<ViewerMoreButton> createState() => _ViewerMoreButtonState();
}

class _ViewerMoreButtonState extends State<ViewerMoreButton> {
  String? _notifId;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ViewerMoreButton old) {
    super.didUpdateWidget(old);
    if (old.viewerId != widget.viewerId) _load();
  }

  Future<void> _load() async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null || widget.viewerId.isEmpty) return;
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
      if (!mounted) return;
      setState(() {
        _notifId = (r as List).isEmpty ? null : r.first['id'].toString();
      });
    } catch (_) {}
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
    } catch (_) {
      _toast('Could not complete that. Try again.');
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.keyboard_control, color: Colors.black87, size: 24),
      onSelected: (v) => _respond(v == 'accept'),
      itemBuilder: (_) {
        if (_notifId == null) {
          return const [
            PopupMenuItem<String>(
              enabled: false,
              value: 'none',
              child: Text('No pending request'),
            ),
          ];
        }
        return const [
          PopupMenuItem<String>(value: 'accept', child: Text('Accept')),
          PopupMenuItem<String>(value: 'decline', child: Text('Decline')),
        ];
      },
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
