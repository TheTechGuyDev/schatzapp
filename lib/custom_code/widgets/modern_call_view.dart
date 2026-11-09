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
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

// Remembers when each call was connected, so the timer keeps counting while
// the call screen is minimized and shows the right time when it comes back.
class _CallClock {
  static final Map<String, DateTime> start = {};
}

// The floating bubble shown while a call is minimized.
class _CallBubble {
  static OverlayEntry? _entry;

  static bool get isShowing => _entry != null;

  static void hide() {
    try {
      _entry?.remove();
    } catch (_) {}
    _entry = null;
  }

  static void show({
    required OverlayState overlay,
    required GoRouter router,
    required String callId,
    required String conversationId,
    required String name,
    required String avatar,
    required String callType,
    required String channel,
  }) {
    hide();
    _entry = OverlayEntry(
      builder: (_) => _BubbleBody(
        router: router,
        callId: callId,
        conversationId: conversationId,
        name: name,
        avatar: avatar,
        callType: callType,
        channel: channel,
      ),
    );
    overlay.insert(_entry!);
  }
}

class _BubbleBody extends StatefulWidget {
  const _BubbleBody({
    required this.router,
    required this.callId,
    required this.conversationId,
    required this.name,
    required this.avatar,
    required this.callType,
    required this.channel,
  });

  final GoRouter router;
  final String callId;
  final String conversationId;
  final String name;
  final String avatar;
  final String callType;
  final String channel;

  @override
  State<_BubbleBody> createState() => _BubbleBodyState();
}

class _BubbleBodyState extends State<_BubbleBody> {
  Offset? _pos;
  Timer? _tick;
  Timer? _poll;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _poll = Timer.periodic(const Duration(seconds: 2), (_) => _checkEnded());
  }

  @override
  void dispose() {
    _tick?.cancel();
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _checkEnded() async {
    if (_closing) return;
    try {
      final row = await SupaFlow.client
          .from('calls')
          .select('status')
          .eq('id', widget.callId)
          .maybeSingle();
      final s = (row?['status'] ?? '').toString();
      if (s == 'ended' || s == 'missed' || s == 'declined') {
        _closing = true;
        _CallBubble.hide();
        await leaveCallLocally();
      }
    } catch (_) {}
  }

  String _clock() {
    final st = _CallClock.start[widget.callId];
    final sec = st == null ? 0 : DateTime.now().difference(st).inSeconds;
    final h = sec ~/ 3600;
    final m = ((sec % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  void _open() {
    if (_closing) return;
    _closing = true;
    _CallBubble.hide();
    widget.router.pushNamed('ConnectedCallScreen', queryParameters: {
      'callId': widget.callId,
      'conversationId': widget.conversationId,
      'otherUserName': widget.name,
      'otherUserAvatar': widget.avatar,
      'callType': widget.callType,
      'agoraChannelName': widget.channel,
    });
  }

  Future<void> _end() async {
    if (_closing) return;
    _closing = true;
    _CallBubble.hide();
    await endCall(widget.callId);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final top = MediaQuery.of(context).padding.top;
    _pos ??= Offset(size.width - 200, top + 70);
    final initial = widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?';
    return Positioned(
      left: _pos!.dx,
      top: _pos!.dy,
      child: GestureDetector(
        onPanUpdate: (d) {
          final n = _pos! + d.delta;
          setState(() {
            _pos = Offset(
              n.dx.clamp(8.0, size.width - 190),
              n.dy.clamp(top + 8, size.height - 120),
            );
          });
        },
        onTap: _open,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            decoration: BoxDecoration(
              color: const Color(0xFF935CCC),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 5))
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: widget.avatar.startsWith('http')
                        ? Image.network(widget.avatar,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                color: Colors.white24,
                                alignment: Alignment.center,
                                child: Text(initial,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800))))
                        : Container(
                            color: Colors.white24,
                            alignment: Alignment.center,
                            child: Text(initial,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800))),
                  ),
                ),
                const SizedBox(width: 10),
                Text(_clock(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _end,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                        color: Color(0xFFE5484D), shape: BoxShape.circle),
                    child: const Icon(Icons.call_end_rounded,
                        color: Colors.white, size: 20),
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

/// The call screen: used while ringing (connected = false) and during the
/// call (connected = true).
///
/// Light by default, dark when the app is dark.
class ModernCallView extends StatefulWidget {
  const ModernCallView({
    super.key,
    this.width,
    this.height,
    required this.callId,
    required this.conversationId,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.callType,
    required this.agoraChannelName,
    required this.connected,
  });

  final double? width;
  final double? height;
  final String callId;
  final String conversationId;
  final String otherUserName;
  final String otherUserAvatar;
  final String callType;
  final String agoraChannelName;
  final bool connected;

  @override
  State<ModernCallView> createState() => _ModernCallViewState();
}

class _ModernCallViewState extends State<ModernCallView>
    with SingleTickerProviderStateMixin {
  static const Color _purple = Color(0xFF935CCC);
  static const Color _red = Color(0xFFE5484D);

  late final AnimationController _pulse;
  Timer? _timer;
  Timer? _pollTimer;
  Timer? _hideTimer;
  int _seconds = 0;
  bool _muted = false;
  bool _speaker = false;
  bool _videoOff = false;
  late bool _isVideo;
  bool _hungUp = false;
  bool _isGroup = false;
  List<Map<String, dynamic>> _members = [];

  // Video upgrade request state.
  bool _myRequestPending = false;
  String? _incomingRequestName;
  String? _lastRequester;

  // Tap-to-hide controls (video mode).
  bool _controlsVisible = true;
  Offset? _downPos;
  DateTime? _downTime;

  @override
  void initState() {
    super.initState();
    _isVideo = widget.callType == 'video';
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    if (_CallBubble.isShowing) _CallBubble.hide();
    if (widget.connected) {
      _CallClock.start.putIfAbsent(widget.callId, () => DateTime.now());
      _syncSeconds();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(_syncSeconds);
      });
    }
    _poll();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
    _scheduleHide();
  }

  void _syncSeconds() {
    final st = _CallClock.start[widget.callId];
    _seconds = st == null ? 0 : DateTime.now().difference(st).inSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pollTimer?.cancel();
    _hideTimer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _ink => _dark ? Colors.white : const Color(0xFF1B1230);
  Color get _soft => _dark ? Colors.white70 : const Color(0xFF6B6480);
  bool get _videoLayout => _isVideo && widget.connected;

  String _clock() {
    final h = _seconds ~/ 3600;
    final m = ((_seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  void _toast(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  // ------------------------ polling ------------------------
  Future<void> _poll() async {
    try {
      final me = SupaFlow.client.auth.currentUser?.id;
      final call = await SupaFlow.client
          .from('calls')
          .select('is_group, call_type, video_request_by')
          .eq('id', widget.callId)
          .maybeSingle();
      if (call == null || !mounted) return;

      final group = call['is_group'] == true;
      final type = (call['call_type'] ?? '').toString();
      final reqBy = call['video_request_by']?.toString();

      // Someone else asked to switch to video.
      if (reqBy != null && reqBy.isNotEmpty && reqBy != me && !_isVideo) {
        if (_lastRequester != reqBy || _incomingRequestName == null) {
          _lastRequester = reqBy;
          String name = widget.otherUserName;
          if (group) {
            try {
              final p = await SupaFlow.client
                  .from('profiles')
                  .select('full_name')
                  .eq('id', reqBy)
                  .maybeSingle();
              final n = (p?['full_name'] ?? '').toString();
              if (n.isNotEmpty) name = n;
            } catch (_) {
              name = 'Someone';
            }
          }
          if (mounted) setState(() => _incomingRequestName = name);
        }
      } else if (_incomingRequestName != null) {
        if (mounted) setState(() => _incomingRequestName = null);
        _lastRequester = null;
      }

      // My own request: waiting, accepted, or declined.
      if (_myRequestPending) {
        if (type == 'video') {
          if (mounted) setState(() => _myRequestPending = false);
        } else if (reqBy == null || reqBy.isEmpty) {
          if (mounted) setState(() => _myRequestPending = false);
          _toast('Video request was declined');
        }
      } else if (reqBy != null && reqBy == me && !_isVideo) {
        if (mounted) setState(() => _myRequestPending = true);
      }

      if (!group) {
        if (mounted && _isGroup) setState(() => _isGroup = false);
        return;
      }
      final parts = await SupaFlow.client
          .from('call_participants')
          .select('user_id')
          .eq('call_id', widget.callId)
          .not('joined_at', 'is', null)
          .filter('left_at', 'is', null);
      final ids = (parts as List).map((r) => r['user_id'] as String).toList();
      List<Map<String, dynamic>> profs = [];
      if (ids.isNotEmpty) {
        final rows = await SupaFlow.client
            .from('profiles')
            .select('id, full_name, avatar_url')
            .inFilter('id', ids);
        profs = List<Map<String, dynamic>>.from(rows as List);
      }
      if (mounted) {
        setState(() {
          _isGroup = true;
          _members = profs;
        });
      }
    } catch (_) {}
  }

  // ------------------------ video request ------------------------
  Future<void> _requestVideo() async {
    final me = SupaFlow.client.auth.currentUser?.id;
    if (me == null || _myRequestPending) return;
    try {
      await SupaFlow.client
          .from('calls')
          .update({'video_request_by': me}).eq('id', widget.callId);
      if (mounted) setState(() => _myRequestPending = true);
    } catch (_) {
      _toast('Could not send the video request');
    }
  }

  Future<void> _cancelRequest() async {
    try {
      await SupaFlow.client
          .from('calls')
          .update({'video_request_by': null}).eq('id', widget.callId);
    } catch (_) {}
    if (mounted) setState(() => _myRequestPending = false);
  }

  Future<void> _acceptRequest() async {
    try {
      await SupaFlow.client.from('calls').update({
        'call_type': 'video',
        'video_request_by': null,
      }).eq('id', widget.callId);
    } catch (_) {
      _toast('Could not switch to video');
    }
    if (mounted) setState(() => _incomingRequestName = null);
  }

  Future<void> _declineRequest() async {
    try {
      await SupaFlow.client
          .from('calls')
          .update({'video_request_by': null}).eq('id', widget.callId);
    } catch (_) {}
    if (mounted) setState(() => _incomingRequestName = null);
  }

  // ------------------------ controls hide ------------------------
  void _scheduleHide() {
    _hideTimer?.cancel();
    if (!_videoLayout) return;
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _videoLayout) setState(() => _controlsVisible = false);
    });
  }

  void _onPointerUp(PointerUpEvent e, double screenH) {
    final d = _downPos;
    final t = _downTime;
    _downPos = null;
    _downTime = null;
    if (!_videoLayout || d == null || t == null) return;
    final quick = DateTime.now().difference(t).inMilliseconds < 300;
    final still = (e.position - d).distance < 12;
    if (!quick || !still) return;
    final inControlZone =
        _controlsVisible && (d.dy > screenH - 340 || d.dy < 100);
    if (inControlZone) {
      _scheduleHide();
      return;
    }
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _scheduleHide();
  }

  // ------------------------ actions ------------------------
  Future<void> _toggleMute() async {
    final v = await toggleMute();
    if (mounted) setState(() => _muted = v);
  }

  Future<void> _toggleSpeaker() async {
    final v = await toggleSpeaker();
    if (mounted) setState(() => _speaker = v);
  }

  Future<void> _toggleVideo() async {
    if (!_isVideo) {
      await _requestVideo();
    } else {
      final off = await toggleVideo();
      if (mounted) setState(() => _videoOff = off);
    }
  }

  void _minimize() {
    if (!widget.connected) return;
    final overlay = Navigator.of(context, rootNavigator: true).overlay;
    final router = GoRouter.of(context);
    if (overlay == null) {
      _toast('Could not minimize the call');
      return;
    }
    _CallBubble.show(
      overlay: overlay,
      router: router,
      callId: widget.callId,
      conversationId: widget.conversationId,
      name: widget.otherUserName,
      avatar: widget.otherUserAvatar,
      callType: _isVideo ? 'video' : widget.callType,
      channel: widget.agoraChannelName,
    );
    // Go home (clears the call screens from the stack); the bubble brings
    // the call back.
    router.goNamed('HomePage');
  }

  void _openChat() {
    context.pushNamed('chatpage', queryParameters: {
      'conversationId': widget.conversationId,
      'otherUserId': '',
      'displayName': widget.otherUserName,
      'displayAvatar': widget.otherUserAvatar,
    });
  }

  void _goToChatAfterCall() {
    if (!mounted) return;
    context.goNamed('chatpage', queryParameters: {
      'conversationId': widget.conversationId,
      'otherUserId': '',
      'displayName': widget.otherUserName,
      'displayAvatar': widget.otherUserAvatar,
    });
  }

  Future<void> _end() async {
    if (_hungUp) return;
    _hungUp = true;
    _CallClock.start.remove(widget.callId);
    await endCall(widget.callId);
    _goToChatAfterCall();
  }

  Future<void> _onRemoteEnded() async {
    if (_hungUp) return;
    _hungUp = true;
    _CallClock.start.remove(widget.callId);
    await leaveCallLocally();
    _goToChatAfterCall();
  }

  void _more() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        decoration: BoxDecoration(
          color: _dark ? const Color(0xFF1F1433) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: _soft.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            if (_isVideo)
              ListTile(
                leading: const Icon(Icons.cameraswitch_rounded, color: _purple),
                title: Text('Switch camera', style: TextStyle(color: _ink)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await switchCamera();
                },
              ),
            ListTile(
              leading:
                  const Icon(Icons.chat_bubble_outline_rounded, color: _purple),
              title: Text('Open chat', style: TextStyle(color: _ink)),
              onTap: () {
                Navigator.pop(ctx);
                _openChat();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------ pieces ------------------------
  Widget _roundIcon(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _dark ? Colors.white12 : Colors.white,
            shape: BoxShape.circle,
            boxShadow: _dark
                ? null
                : [
                    BoxShadow(
                        color: _purple.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3))
                  ],
          ),
          child: Icon(icon, color: _ink, size: 22),
        ),
      );

  Widget _topBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          children: [
            if (widget.connected)
              _roundIcon(Icons.keyboard_arrow_down_rounded, _minimize)
            else
              const SizedBox(width: 42, height: 42),
            const Spacer(),
            _roundIcon(Icons.person_add_alt_1_rounded,
                () => _toast('Group calls are coming soon')),
            const SizedBox(width: 10),
            _roundIcon(Icons.chat_bubble_outline_rounded, _openChat),
          ],
        ),
      );

  Widget _initialBox(String initial) => Container(
        color: _purple.withOpacity(0.2),
        alignment: Alignment.center,
        child: Text(initial,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 48, fontWeight: FontWeight.w700, color: _purple)),
      );

  Widget _avatar() {
    final url = widget.otherUserAvatar.trim();
    final initial = widget.otherUserName.isNotEmpty
        ? widget.otherUserName[0].toUpperCase()
        : '?';
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final p = widget.connected ? 0.0 : _pulse.value;
        return SizedBox(
          width: 210,
          height: 210,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 190 + 20 * p,
                height: 190 + 20 * p,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: _purple.withOpacity(0.08)),
              ),
              Container(
                width: 160 + 12 * p,
                height: 160 + 12 * p,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: _purple.withOpacity(0.14)),
              ),
              child!,
            ],
          ),
        );
      },
      child: Container(
        width: 128,
        height: 128,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
                color: _purple.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 8))
          ],
        ),
        child: ClipOval(
          child: url.startsWith('http')
              ? Image.network(url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _initialBox(initial))
              : _initialBox(initial),
        ),
      ),
    );
  }

  Widget _header() {
    final status = widget.connected
        ? _clock()
        : (_isVideo ? 'Video calling...' : 'Calling...');
    return Column(
      children: [
        Text(widget.otherUserName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 26, fontWeight: FontWeight.w800, color: _ink)),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.connected)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(
                    color: Color(0xFF2FBF71), shape: BoxShape.circle),
              ),
            Text(status,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 15, fontWeight: FontWeight.w600, color: _soft)),
          ],
        ),
      ],
    );
  }

  Widget _memberStrip() {
    if (!_isGroup || _members.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Text('${_members.length} in this call',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w600, color: _soft)),
          const SizedBox(height: 10),
          SizedBox(
            height: 64,
            child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _members.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final m = _members[i];
                final name = (m['full_name'] ?? '').toString();
                final url = (m['avatar_url'] ?? '').toString();
                final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
                return Column(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: url.startsWith('http')
                            ? Image.network(url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _initialBox(initial))
                            : _initialBox(initial),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 52,
                      child: Text(name.split(' ').first,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, color: _ink)),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _control(
      {required IconData icon,
      required String label,
      required VoidCallback onTap,
      bool active = false,
      bool danger = false}) {
    final bg = danger
        ? _red
        : active
            ? _purple
            : (_dark ? Colors.white12 : Colors.white);
    final fg = (danger || active) ? Colors.white : _ink;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: _dark || danger
                  ? null
                  : [
                      BoxShadow(
                          color: _purple.withOpacity(0.12),
                          blurRadius: 14,
                          offset: const Offset(0, 5))
                    ],
            ),
            child: Icon(icon, color: fg, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
        ],
      ),
    );
  }

  Widget _grid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _control(
                  icon: _isVideo && !_videoOff
                      ? Icons.videocam_rounded
                      : Icons.videocam_off_rounded,
                  label: 'Video',
                  active: (_isVideo && !_videoOff) || _myRequestPending,
                  onTap: _toggleVideo),
              _control(
                  icon: _speaker
                      ? Icons.volume_up_rounded
                      : Icons.volume_down_rounded,
                  label: 'Speaker',
                  active: _speaker,
                  onTap: _toggleSpeaker),
              _control(
                  icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  label: 'Mute',
                  active: _muted,
                  onTap: _toggleMute),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _control(
                  icon: Icons.more_horiz_rounded, label: 'More', onTap: _more),
              _control(
                  icon: Icons.screen_share_rounded,
                  label: 'Share screen',
                  onTap: () => _toast('Screen sharing is not available yet')),
              _control(
                  icon: Icons.call_end_rounded,
                  label: 'End',
                  danger: true,
                  onTap: _end),
            ],
          ),
        ],
      ),
    );
  }

  Widget _banner() {
    if (_incomingRequestName != null) {
      return _bannerCard(
        '$_incomingRequestName wants to switch to video',
        [
          _bannerBtn('Decline', _red, _declineRequest),
          const SizedBox(width: 10),
          _bannerBtn('Accept', const Color(0xFF2FBF71), _acceptRequest),
        ],
      );
    }
    if (_myRequestPending) {
      return _bannerCard(
        'Waiting for ${widget.otherUserName} to accept video...',
        [_bannerBtn('Cancel', _soft, _cancelRequest)],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _bannerCard(String text, List<Widget> actions) => Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _dark ? const Color(0xFF2A1C42) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 14,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w700, color: _ink)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: actions),
          ],
        ),
      );

  Widget _bannerBtn(String label, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(14)),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final showVideo = _videoLayout;
    final screenH = MediaQuery.of(context).size.height;
    final hideUi = showVideo && !_controlsVisible;
    return Listener(
      onPointerDown: (e) {
        _downPos = e.position;
        _downTime = DateTime.now();
      },
      onPointerUp: (e) => _onPointerUp(e, screenH),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: _dark
                        ? const [Color(0xFF120C1F), Color(0xFF1F1433)]
                        : const [Color(0xFFFFFFFF), Color(0xFFF1E8FB)],
                  ),
                ),
              ),
            ),
            if (showVideo)
              const Positioned.fill(
                child: SwappableCallVideos(
                    width: double.infinity, height: double.infinity),
              ),
            // Listens for the other side answering, ending, or switching to video.
            SizedBox(
              width: 1,
              height: 1,
              child: CallStatusListener(
                width: 1,
                height: 1,
                callId: widget.callId,
                onAnswered: () async {
                  if (!widget.connected) {
                    await goToConnectedCallScreen(
                      widget.callId,
                      widget.conversationId,
                      widget.otherUserName,
                      widget.otherUserAvatar,
                      widget.callType,
                      widget.agoraChannelName,
                    );
                  }
                },
                onEnded: _onRemoteEnded,
                onCallTypeChanged: (t) async {
                  await enableVideoMidCall();
                  if (mounted) {
                    setState(() {
                      _isVideo = true;
                      _myRequestPending = false;
                      _incomingRequestName = null;
                      _controlsVisible = true;
                    });
                    _scheduleHide();
                  }
                },
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: hideUi ? 0 : 1,
                    child: IgnorePointer(ignoring: hideUi, child: _topBar()),
                  ),
                  _banner(),
                  Expanded(
                    child: showVideo
                        ? Align(
                            alignment: Alignment.topCenter,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: hideUi ? 0 : 1,
                              child: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: _header()),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _avatar(),
                              const SizedBox(height: 14),
                              _header(),
                              _memberStrip(),
                              if (_isVideo && !widget.connected)
                                Padding(
                                  padding: const EdgeInsets.only(top: 18),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: const SizedBox(
                                      width: 150,
                                      height: 190,
                                      child: AgoraVideoRenderer(
                                          width: 150, height: 190),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: hideUi ? 0 : 1,
                    child: IgnorePointer(
                      ignoring: hideUi,
                      child: Container(
                        padding: const EdgeInsets.only(top: 14, bottom: 22),
                        decoration: BoxDecoration(
                          color: showVideo
                              ? (_dark ? Colors.black54 : Colors.white70)
                              : Colors.transparent,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(30)),
                        ),
                        child: _grid(),
                      ),
                    ),
                  ),
                ],
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
