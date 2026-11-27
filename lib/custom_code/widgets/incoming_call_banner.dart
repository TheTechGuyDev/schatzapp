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

import '/custom_code/actions/index.dart';
import 'dart:async';

class IncomingCallBanner extends StatefulWidget {
  const IncomingCallBanner({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
  });

  final double? width;
  final double? height;
  final String currentUserId;

  @override
  State<IncomingCallBanner> createState() => _IncomingCallBannerState();
}

class _IncomingCallBannerState extends State<IncomingCallBanner> {
  static const Color _purple = Color(0xFF935CCC);
  static const Color _red = Color(0xFFDF1609);

  StreamSubscription<List<Map<String, dynamic>>>? _sub;
  Map<String, dynamic>? _call;
  String? _ringingFor;
  bool _busy = false;
  String? _camName;
  String? _camAvatar;
  String? _savedName;

  // A Bimp never shows the caller's real identity: it shows one of the
  // receiver's camouflage profiles instead.
  Future<void> _pickCamouflage() async {
    _camName = null;
    _camAvatar = null;
    try {
      final r = await SupaFlow.client.rpc('pcl_pick_camouflage');
      final list = r is List ? r : [r];
      if (list.isNotEmpty && list.first is Map) {
        final m = Map<String, dynamic>.from(list.first as Map);
        _camName = (m['out_name'] as String?)?.trim();
        _camAvatar = (m['out_avatar'] as String?)?.trim();
      }
    } catch (_) {}
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _listen();
  }

  void _listen() {
    _sub?.cancel();
    try {
      _sub = SupaFlow.client
          .from('active_incoming_calls')
          .stream(primaryKey: ['user_id'])
          .eq('user_id', widget.currentUserId)
          .listen(_onRows, onError: (_) {}, cancelOnError: false);
    } catch (_) {}
  }

  // The caller is shown by the name this user saved them as, when there is one.
  Future<void> _loadSavedName(String callId, String? callerId) async {
    _savedName = null;
    if (callerId == null || callerId.isEmpty) return;
    try {
      final r = await SupaFlow.client
          .from('contacts')
          .select('saved_name')
          .eq('owner_id', widget.currentUserId)
          .eq('contact_user_id', callerId)
          .limit(1);
      final list = r as List;
      if (list.isNotEmpty) {
        final n = (list.first['saved_name'] ?? '').toString().trim();
        if (n.isNotEmpty && _ringingFor == callId && mounted) {
          setState(() => _savedName = n);
        }
      }
    } catch (_) {}
  }

  // Tells the caller this phone is online and ringing ("Calling" -> "Ringing").
  Future<void> _ackRinging(String callId) async {
    try {
      await SupaFlow.client
          .rpc('ack_call_ringing', params: {'p_call_id': callId});
    } catch (_) {}
  }

  void _onRows(List<Map<String, dynamic>> rows) {
    Map<String, dynamic>? c = rows.isNotEmpty ? rows.first : null;
    final ringing = c != null &&
        (c['call_id'] ?? '').toString().isNotEmpty &&
        c['status'] == 'ringing';
    final id = ringing ? c['call_id'].toString() : null;
    if (id != null && id != _ringingFor) {
      if (c?['call_type'] == 'bimp') {
        _camName = null;
        _camAvatar = null;
        _pickCamouflage();
      }
      _savedName = null;
      if (c?['call_type'] != 'bimp') {
        _loadSavedName(id, c?['caller_id']?.toString());
      }
      startRingtoneAndVibration();
      _ackRinging(id);
    } else if (id == null && _ringingFor != null) {
      stopRingtoneAndVibration();
    }
    _ringingFor = id;
    if (id == null) _savedName = null;
    if (mounted) setState(() => _call = ringing ? c : null);
  }

  @override
  void dispose() {
    _sub?.cancel();
    if (_ringingFor != null) stopRingtoneAndVibration();
    super.dispose();
  }

  void _toast(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _finishBimp(Map<String, dynamic> c, String status) async {
    final callId = c['call_id'].toString();
    try {
      await SupaFlow.client.from('calls').update({
        'status': status,
        'ended_at': DateTime.now().toUtc().toIso8601String(),
        'duration_seconds': 0,
      }).eq('id', callId);
    } catch (_) {}
    await clearAcceptedIncomingCall(callId);
  }

  Future<void> _decline(Map<String, dynamic> c) async {
    if (_busy) return;
    _busy = true;
    try {
      await stopRingtoneAndVibration();
      if (c['call_type'] == 'bimp') {
        await _finishBimp(c, 'declined');
        return;
      }
      final r = await declineCall(c['call_id'].toString());
      if (r != 'SUCCESS') _toast(r);
    } catch (_) {
      _toast('Could not decline the call');
    } finally {
      _busy = false;
    }
  }

  Future<void> _accept(Map<String, dynamic> c) async {
    if (_busy) return;
    _busy = true;
    try {
      await stopRingtoneAndVibration();
      if (c['call_type'] == 'bimp') {
        // A Bimp only gets the person's attention: accepting ends it at once.
        await _finishBimp(c, 'ended');
        _toast('Bimp received');
        return;
      }
      final callId = c['call_id']?.toString();
      final channel = c['agora_channel_name']?.toString();
      final result = await acceptCall(callId, channel, widget.currentUserId);
      if (result != null) {
        await goToConnectedCallScreen(
          callId,
          c['conversation_id']?.toString(),
          ((_savedName ?? '').isNotEmpty
              ? _savedName!
              : (c['caller_name'] ?? '').toString()),
          c['caller_avatar']?.toString(),
          c['call_type']?.toString(),
          channel,
        );
        await clearAcceptedIncomingCall(callId);
      } else {
        _toast("Couldn't accept the call, please try again");
      }
    } catch (_) {
      _toast("Couldn't accept the call, please try again");
    } finally {
      _busy = false;
    }
  }

  Widget _circle(IconData icon, Color color, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _call;
    if (c == null) return const SizedBox.shrink();
    final theme = FlutterFlowTheme.of(context);
    final bimp = c['call_type'] == 'bimp';
    final name = bimp
        ? ((_camName ?? '').isNotEmpty ? _camName! : 'Unknown')
        : ((_savedName ?? '').isNotEmpty
            ? _savedName!
            : (c['caller_name'] ?? 'Unknown').toString());
    final avatar =
        bimp ? (_camAvatar ?? '') : (c['caller_avatar'] ?? '').toString();
    final video = c['call_type'] == 'video';
    return Container(
      width: widget.width ?? double.infinity,
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.alternate),
        boxShadow: const [
          BoxShadow(
              color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFEFEBF2),
            backgroundImage: (avatar.toLowerCase().startsWith('http') &&
                    !avatar.toLowerCase().contains('unsplash.com'))
                ? NetworkImage(avatar)
                : null,
            child: (avatar.toLowerCase().startsWith('http') &&
                    !avatar.toLowerCase().contains('unsplash.com'))
                ? null
                : const Icon(Icons.person_outline, color: _purple, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: theme.primaryText,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
                const SizedBox(height: 3),
                Text(
                    bimp
                        ? 'calling'
                        : (video ? 'Incoming video call' : 'Incoming Call'),
                    style: TextStyle(color: theme.secondaryText, fontSize: 13)),
              ],
            ),
          ),
          _circle(Icons.call_end_rounded, _red, 'End', () => _decline(c)),
          const SizedBox(width: 16),
          _circle(
              bimp
                  ? Icons.notifications_active_rounded
                  : (video ? Icons.videocam_rounded : Icons.call_rounded),
              _purple,
              'Accept',
              () => _accept(c)),
        ],
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
