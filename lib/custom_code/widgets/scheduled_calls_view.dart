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

import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class ScheduledCallsView extends StatefulWidget {
  const ScheduledCallsView({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
  });

  final double? width;
  final double? height;
  final String currentUserId;

  @override
  State<ScheduledCallsView> createState() => _ScheduledCallsViewState();
}

class _ScheduledCallsViewState extends State<ScheduledCallsView> {
  static const Color _purple = Color(0xFF935CCC);

  bool _loading = true;
  List<Map<String, dynamic>> _items = [];
  // All chats the user is in: {id, name, avatar, isGroup, otherId}
  List<Map<String, dynamic>> _chats = [];

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _ink => _dark ? Colors.white : const Color(0xFF1B1230);
  Color get _soft => _dark ? Colors.white70 : const Color(0xFF6B6480);
  Color get _card => _dark ? const Color(0xFF1F1433) : Colors.white;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _toast(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _loadChats() async {
    final me = widget.currentUserId;
    final mine = await SupaFlow.client
        .from('conversation_participants')
        .select('conversation_id')
        .eq('user_id', me);
    final ids = (mine as List)
        .map((r) => r['conversation_id'] as String)
        .toSet()
        .toList();
    if (ids.isEmpty) {
      _chats = [];
      return;
    }
    final convos = await SupaFlow.client
        .from('conversations')
        .select('id, type, name, avatar_url')
        .inFilter('id', ids)
        .filter('deleted_at', 'is', null);
    final others = await SupaFlow.client
        .from('conversation_participants')
        .select('conversation_id, user_id')
        .inFilter('conversation_id', ids)
        .neq('user_id', me);
    final otherByConvo = <String, String>{};
    for (final r in others as List) {
      otherByConvo.putIfAbsent(
          r['conversation_id'] as String, () => r['user_id'] as String);
    }
    final otherIds = otherByConvo.values.toSet().toList();
    final profMap = <String, Map<String, dynamic>>{};
    final savedMap = <String, String>{};
    if (otherIds.isNotEmpty) {
      final profs = await SupaFlow.client
          .from('profiles')
          .select('id, full_name, username, avatar_url')
          .inFilter('id', otherIds);
      for (final p in profs as List) {
        profMap[p['id'] as String] = Map<String, dynamic>.from(p);
      }
      final saved = await SupaFlow.client
          .from('contacts')
          .select('contact_user_id, saved_name')
          .eq('owner_id', me)
          .inFilter('contact_user_id', otherIds);
      for (final c in saved as List) {
        final n = (c['saved_name'] ?? '').toString().trim();
        if (n.isNotEmpty) savedMap[c['contact_user_id'] as String] = n;
      }
    }
    final out = <Map<String, dynamic>>[];
    for (final c in convos as List) {
      final id = c['id'] as String;
      final isGroup = (c['type'] ?? '') == 'group';
      String name;
      String avatar = (c['avatar_url'] ?? '').toString();
      final otherId = otherByConvo[id];
      if (isGroup) {
        name = (c['name'] ?? 'Group').toString();
      } else {
        final p = otherId == null ? null : profMap[otherId];
        final saved = otherId == null ? null : savedMap[otherId];
        final username = (p?['username'] ?? '').toString();
        final full = (p?['full_name'] ?? '').toString();
        name = (saved != null && saved.isNotEmpty)
            ? saved
            : (username.isNotEmpty
                ? username
                : (full.isNotEmpty ? full : 'Chat'));
        avatar = (p?['avatar_url'] ?? '').toString();
      }
      out.add({
        'id': id,
        'name': name,
        'avatar': avatar,
        'isGroup': isGroup,
        'otherId': otherId,
      });
    }
    out.sort((a, b) => (a['name'] as String)
        .toLowerCase()
        .compareTo((b['name'] as String).toLowerCase()));
    _chats = out;
  }

  Future<void> _load() async {
    try {
      try {
        await _loadChats().timeout(const Duration(seconds: 15));
      } catch (_) {}
      final since = DateTime.now()
          .toUtc()
          .subtract(const Duration(hours: 2))
          .toIso8601String();
      final rows = await SupaFlow.client
          .from('scheduled_calls')
          .select()
          .eq('status', 'scheduled')
          .gte('scheduled_at', since)
          .order('scheduled_at', ascending: true);
      if (mounted) {
        setState(() {
          _items = List<Map<String, dynamic>>.from(rows as List);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      _toast('Could not load scheduled calls');
    }
  }

  Map<String, dynamic>? _chat(String id) {
    for (final c in _chats) {
      if (c['id'] == id) return c;
    }
    return null;
  }

  Future<void> _delete(String id) async {
    try {
      await SupaFlow.client.from('scheduled_calls').delete().eq('id', id);
      _load();
    } catch (_) {
      _toast('Could not cancel');
    }
  }

  Future<void> _callNow(Map<String, dynamic> item) async {
    final chat = _chat(item['conversation_id'] as String);
    final type = (item['call_type'] ?? 'voice').toString();
    final convoId = item['conversation_id'] as String;
    final result = await startCall(convoId, widget.currentUserId, type);
    if (result == null) {
      _toast('Could not start the call, please try again');
      return;
    }
    if (!mounted) return;
    context.pushNamed('ActiveCallScreen', queryParameters: {
      'callId': result.callId ?? '',
      'conversationId': convoId,
      'calleeName': (chat?['name'] ?? '').toString(),
      'calleeAvatar': (chat?['avatar'] ?? '').toString(),
      'callType': type,
      'agoraChannelName': result.agoraChannelName ?? '',
      'agoraToken': result.agoraToken ?? '',
      'agoraUid': (result.agoraUid ?? 0).toString(),
    });
  }

  // ------------------------- schedule sheet -------------------------
  Future<void> _openSheet() async {
    String? chatId;
    String type = 'voice';
    DateTime? date;
    TimeOfDay? time;
    final titleCtrl = TextEditingController();
    bool saving = false;
    String? err;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          Future<void> save() async {
            if (chatId == null || date == null || time == null) {
              _toast('Pick a chat, a date and a time');
              return;
            }
            final when = DateTime(
                date!.year, date!.month, date!.day, time!.hour, time!.minute);
            if (when.isBefore(DateTime.now())) {
              _toast('Pick a time in the future');
              return;
            }
            final uid =
                SupaFlow.client.auth.currentUser?.id ?? widget.currentUserId;
            if (uid.isEmpty) {
              setSheet(
                  () => err = 'You are not signed in. Please log in again.');
              return;
            }
            setSheet(() {
              saving = true;
              err = null;
            });
            try {
              await SupaFlow.client.from('scheduled_calls').insert({
                'conversation_id': chatId,
                'creator_id': uid,
                'title': titleCtrl.text.trim().isEmpty
                    ? null
                    : titleCtrl.text.trim(),
                'call_type': type,
                'scheduled_at': when.toUtc().toIso8601String(),
              }).timeout(const Duration(seconds: 15));
              // Tell the chat members, so they get the reminder in the chat.
              final label = DateFormat('EEE d MMM, h:mm a').format(when);
              final t = titleCtrl.text.trim();
              try {
                await SupaFlow.client.from('messages').insert({
                  'conversation_id': chatId,
                  'sender_id': uid,
                  'message_type': 'text',
                  'content':
                      'Scheduled ${type == 'video' ? 'video' : 'voice'} call${t.isEmpty ? '' : ' ($t)'}: $label',
                }).timeout(const Duration(seconds: 10));
              } catch (_) {}
              if (ctx.mounted) Navigator.pop(ctx);
              _load();
            } catch (e) {
              final m = e.toString();
              setSheet(() {
                saving = false;
                err = m.contains('TimeoutException')
                    ? 'No response from the server. Check your connection and try again.'
                    : 'Could not schedule: ${m.length > 160 ? m.substring(0, 160) : m}';
              });
            }
          }

          return Container(
            padding: EdgeInsets.fromLTRB(
                20, 14, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            decoration: BoxDecoration(
              color: _card,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: _soft.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 14),
                  Text('Schedule a call',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _ink)),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: chatId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Chat',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    items: _chats
                        .map((c) => DropdownMenuItem<String>(
                              value: c['id'] as String,
                              child: Text(
                                  '${c['name']}${c['isGroup'] == true ? ' (group)' : ''}',
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) => setSheet(() => chatId = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Title (optional)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.event_rounded, size: 18),
                          label: Text(date == null
                              ? 'Date'
                              : DateFormat('d MMM yyyy').format(date!)),
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: ctx,
                              initialDate: date ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (d != null) setSheet(() => date = d);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.schedule_rounded, size: 18),
                          label:
                              Text(time == null ? 'Time' : time!.format(ctx)),
                          onPressed: () async {
                            final t = await showTimePicker(
                                context: ctx,
                                initialTime: time ?? TimeOfDay.now());
                            if (t != null) setSheet(() => time = t);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Voice'),
                        selected: type == 'voice',
                        onSelected: (_) => setSheet(() => type = 'voice'),
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text('Video'),
                        selected: type == 'video',
                        onSelected: (_) => setSheet(() => type = 'video'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (err != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(err!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 13)),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: saving ? null : save,
                      child: Text(saving ? 'Saving...' : 'Schedule',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
    titleCtrl.dispose();
  }

  // ------------------------- list -------------------------
  Widget _tile(Map<String, dynamic> item) {
    final chat = _chat(item['conversation_id'] as String);
    final name = (chat?['name'] ?? 'Chat').toString();
    final avatar = (chat?['avatar'] ?? '').toString();
    final when = DateTime.parse(item['scheduled_at'] as String).toLocal();
    final isVideo = (item['call_type'] ?? 'voice') == 'video';
    final title = (item['title'] ?? '').toString();
    final mine = item['creator_id'] == widget.currentUserId;
    final due = when.difference(DateTime.now()).inMinutes <= 15;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: due ? Border.all(color: _purple, width: 1.4) : null,
        boxShadow: _dark
            ? null
            : [
                BoxShadow(
                    color: _purple.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
      ),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 48,
              height: 48,
              child: (avatar.toLowerCase().startsWith('http') &&
                      !avatar.toLowerCase().contains('unsplash.com'))
                  ? cachedNetworkImage(avatar,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _initialBox(initial))
                  : _initialBox(initial),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _ink)),
                if (title.isNotEmpty)
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, color: _soft)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                        size: 14, color: _purple),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        DateFormat('EEE d MMM, h:mm a').format(when),
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _soft),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (mine)
            IconButton(
              icon: Icon(Icons.close_rounded, color: _soft),
              onPressed: () => _delete(item['id'] as String),
            ),
          GestureDetector(
            onTap: () => _callNow(item),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                  color: _purple, borderRadius: BorderRadius.circular(14)),
              child: Text(due ? 'Call now' : 'Call',
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialBox(String initial) => Container(
        color: const Color(0xFFEFEBF2),
        alignment: Alignment.center,
        child: const Icon(Icons.person_outline, color: _purple, size: 26),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text('Schedule a call',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                onPressed: _loading ? null : _openSheet,
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(
                        child: Text('No scheduled calls',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 15, color: _soft)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          itemCount: _items.length,
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
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
