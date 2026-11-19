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

import 'dart:async';

class NotificationsView extends StatefulWidget {
  const NotificationsView({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  static const Color _purple = Color(0xFF935CCC);
  static const Color _soft = Color(0xFFEFEBF2);

  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  final Set<String> _busy = {};
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _load();
    _poll = Timer.periodic(const Duration(seconds: 12), (_) => _load());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final rows = await SupaFlow.client
          .from('notifications')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(100);
      if (!mounted) return;
      setState(() {
        _items = (rows as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAllRead() async {
    try {
      await SupaFlow.client.rpc('mark_notifications_read');
    } catch (_) {}
    await _load();
  }

  Future<void> _markRead(Map<String, dynamic> n) async {
    if (n['is_read'] == true) return;
    setState(() => n['is_read'] = true);
    try {
      await SupaFlow.client
          .from('notifications')
          .update({'is_read': true}).eq('id', n['id']);
    } catch (_) {}
  }

  Future<void> _respond(Map<String, dynamic> n, bool accept) async {
    final id = n['id'].toString();
    if (_busy.contains(id)) return;
    setState(() => _busy.add(id));
    String? error;
    try {
      final res = await SupaFlow.client.rpc('respond_notification',
          params: {'p_id': id, 'p_accept': accept});
      if (res != 'OK' && res != 'DONE') error = 'Could not complete that.';
    } catch (_) {
      error = 'Could not complete that. Try again.';
    }
    if (!mounted) return;
    setState(() => _busy.remove(id));
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
    await _load();
  }

  String _ago(String? iso) {
    final t = DateTime.tryParse(iso ?? '')?.toLocal();
    if (t == null) return '';
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return '${t.day}/${t.month}/${t.year}';
  }

  Widget _leading(Map<String, dynamic> n) {
    final type = n['type'];
    final from = n['from_user_id']?.toString();
    if ((type == 'friend_request' ||
            type == 'message_request' ||
            type == 'friend_accepted') &&
        from != null) {
      return ContactAvatar(
        width: 46,
        height: 46,
        size: 46,
        userId: from,
        name: (n['title'] ?? '').toString(),
      );
    }
    IconData icon = Icons.notifications_none_rounded;
    if (type == 'new_login') icon = Icons.shield_outlined;
    if (type == 'admin_message') icon = Icons.campaign_outlined;
    if (type == 'ad') icon = Icons.local_offer_outlined;
    return Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(color: _soft, shape: BoxShape.circle),
      child: Icon(icon, color: _purple, size: 24),
    );
  }

  Widget _actions(Map<String, dynamic> n) {
    final type = n['type'];
    if (type != 'friend_request' && type != 'message_request') {
      return const SizedBox.shrink();
    }
    final status = (n['status'] ?? 'pending').toString();
    if (status != 'pending') {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          status == 'accepted' ? 'Accepted' : 'Declined',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: status == 'accepted' ? _purple : Colors.black45),
        ),
      );
    }
    final busy = _busy.contains(n['id'].toString());
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          SizedBox(
            height: 34,
            child: ElevatedButton(
              onPressed: busy ? null : () => _respond(n, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Accept',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 34,
            child: OutlinedButton(
              onPressed: busy ? null : () => _respond(n, false),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Color(0xFFD9D4DE)),
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Decline',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(Map<String, dynamic> n) {
    final unread = n['is_read'] != true;
    final type = n['type'];
    var title = (n['title'] ?? '').toString();
    var body = (n['body'] ?? '').toString();
    if (type == 'friend_request') {
      body = 'sent you a friend request';
    } else if (type == 'message_request') {
      body = 'wants to send you a message';
    } else if (type == 'friend_accepted') {
      body = 'accepted your friend request';
    }
    return InkWell(
      onTap: () => _markRead(n),
      child: Container(
        color: unread ? _purple.withOpacity(0.06) : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _leading(n),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14.5),
                        ),
                      ),
                      Text(_ago(n['created_at']?.toString()),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black45)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(body,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54)),
                  _actions(n),
                ],
              ),
            ),
            if (unread)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 6),
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                      color: _purple, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _items.any((n) => n['is_read'] != true);
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: hasUnread ? _markAllRead : null,
                child: Text('Mark all as read',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: hasUnread ? _purple : Colors.black26)),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: _purple, strokeWidth: 2.5))
                : _items.isEmpty
                    ? const Center(
                        child: Text('No notifications yet',
                            style: TextStyle(color: Colors.black45)))
                    : RefreshIndicator(
                        color: _purple,
                        onRefresh: _load,
                        child: ListView.separated(
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFF0EDF3)),
                          itemBuilder: (_, i) => _tile(_items[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
