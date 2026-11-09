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

class HomeTabBadges extends StatefulWidget {
  const HomeTabBadges({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
    required this.selectedTab,
  });

  final double? width;
  final double? height;
  final String currentUserId;
  final int selectedTab; // 0 Chats, 1 Calls, 2 Wallets, 3 Stories, 4 Profile

  @override
  State<HomeTabBadges> createState() => _HomeTabBadgesState();
}

class _HomeTabBadgesState extends State<HomeTabBadges> {
  int _chats = 0;
  int _calls = 0;
  int _wallet = 0;
  int _stories = 0;
  int _profile = 0;

  final List<StreamSubscription> _subs = [];
  Timer? _debounce;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    for (final table in const [
      'messages',
      'conversation_participants',
      'calls',
      'wallet_transactions',
      'statuses',
      'status_views',
      'profiles',
      'wallets',
    ]) {
      try {
        _subs.add(SupaFlow.client
            .from(table)
            .stream(primaryKey: ['id']).listen((_) => _schedule()));
      } catch (e) {
        debugPrint('HomeTabBadges stream $table failed: $e');
      }
    }
    _poll = Timer.periodic(const Duration(seconds: 60), (_) => _schedule());
    _refresh();
  }

  @override
  void didUpdateWidget(covariant HomeTabBadges oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTab != widget.selectedTab) _schedule();
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _debounce?.cancel();
    _poll?.cancel();
    super.dispose();
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) _refresh();
    });
  }

  Future<void> _markSeen(String column) async {
    try {
      await SupaFlow.client
          .from('profiles')
          .update({column: DateTime.now().toUtc().toIso8601String()}).eq(
              'id', widget.currentUserId);
    } catch (e) {
      debugPrint('HomeTabBadges markSeen $column failed: $e');
    }
  }

  Future<void> _refresh() async {
    final me = widget.currentUserId;
    if (me.isEmpty) return;

    Map<String, dynamic>? profile;
    try {
      profile = await SupaFlow.client
          .from('profiles')
          .select(
              'avatar_url, full_name, about_text, calls_seen_at, wallet_seen_at')
          .eq('id', me)
          .maybeSingle();
    } catch (e) {
      debugPrint('HomeTabBadges profile failed: $e');
    }

    final epoch = DateTime.fromMillisecondsSinceEpoch(0).toUtc();
    final callsSeen =
        DateTime.tryParse('${profile?['calls_seen_at'] ?? ''}') ?? epoch;
    final walletSeen =
        DateTime.tryParse('${profile?['wallet_seen_at'] ?? ''}') ?? epoch;

    // Chats: number of unread chats.
    var chats = 0;
    try {
      final rows = await SupaFlow.client
          .from('chat_list_view')
          .select('conversation_id, unread_count, is_archived, is_locked');
      chats = rows
          .where((r) =>
              ((r['unread_count'] as int?) ?? 0) > 0 &&
              r['is_archived'] != true &&
              r['is_locked'] != true)
          .length;
    } catch (e) {
      debugPrint('HomeTabBadges chats failed: $e');
    }

    // Calls: missed calls since the Calls tab was last opened.
    var calls = 0;
    try {
      final rows = await SupaFlow.client
          .from('calls')
          .select('id')
          .eq('callee_id', me)
          .eq('status', 'missed')
          .gt('started_at', callsSeen.toIso8601String());
      calls = rows.length;
    } catch (e) {
      debugPrint('HomeTabBadges calls failed: $e');
    }
    if (widget.selectedTab == 1 && calls > 0) {
      calls = 0;
      _markSeen('calls_seen_at');
    }

    // Wallets: incoming transactions since the Wallets tab was last opened.
    var wallet = 0;
    try {
      final rows = await SupaFlow.client
          .from('wallet_transactions')
          .select('id')
          .eq('user_id', me)
          .eq('status', 'success')
          .inFilter('type', ['send_money_in', 'giftcard_received']).gt(
              'created_at', walletSeen.toIso8601String());
      wallet = rows.length;
    } catch (e) {
      debugPrint('HomeTabBadges wallet failed: $e');
    }
    if (widget.selectedTab == 2 && wallet > 0) {
      wallet = 0;
      _markSeen('wallet_seen_at');
    }

    // Stories: friends who have stories you have not viewed.
    var stories = 0;
    try {
      final rows = await SupaFlow.client
          .from('story_ring_view')
          .select('user_id, has_unviewed');
      stories = rows
          .where((r) => r['has_unviewed'] == true && r['user_id'] != me)
          .length;
    } catch (e) {
      debugPrint('HomeTabBadges stories failed: $e');
    }

    // Profile: things still missing.
    var profileCount = 0;
    if (profile != null) {
      bool empty(dynamic v) => v == null || '$v'.trim().isEmpty;
      if (empty(profile['avatar_url'])) profileCount++;
      if (empty(profile['full_name'])) profileCount++;
      if (empty(profile['about_text'])) profileCount++;
      try {
        final w = await SupaFlow.client
            .from('wallets')
            .select('kyc_status')
            .eq('user_id', me)
            .maybeSingle();
        final kyc = '${w?['kyc_status'] ?? ''}';
        if (kyc != 'verified' && kyc != 'pending') profileCount++;
      } catch (e) {
        debugPrint('HomeTabBadges kyc failed: $e');
      }
    }

    if (!mounted) return;
    setState(() {
      _chats = chats;
      _calls = calls;
      _wallet = wallet;
      _stories = stories;
      _profile = profileCount;
    });
  }

  Widget _badge(BuildContext context, int count) {
    if (count <= 0) return const SizedBox(height: 18);
    final text = count > 99 ? '99+' : '$count';
    return Container(
      // One digit: a small circle. Two or more digits: a slightly wider pill.
      width: text.length == 1 ? 18 : null,
      height: 18,
      padding: EdgeInsets.symmetric(horizontal: text.length == 1 ? 0 : 5),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        widthFactor: 1.0,
        heightFactor: 1.0,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final counts = [_chats, _calls, _wallet, _stories, _profile];
    return SizedBox(
      width: widget.width,
      height: widget.height ?? 20,
      child: IgnorePointer(
        child: Row(
          children: [
            for (final count in counts)
              Expanded(
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(15, 8),
                    child: _badge(context, count),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
