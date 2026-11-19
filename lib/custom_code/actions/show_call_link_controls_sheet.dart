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

import '/flutter_flow/nav/nav.dart';
import 'package:flutter/services.dart';

Future<void> showCallLinkControlsSheet(
    String callId, String channelName) async {
  final ctx = appNavigatorKey.currentContext;
  if (ctx == null) return;
  await showModalBottomSheet<void>(
    context: ctx,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) =>
        _LinkControlsSheet(callId: callId, channelName: channelName),
  );
}

class _LinkControlsSheet extends StatefulWidget {
  const _LinkControlsSheet({required this.callId, required this.channelName});

  final String callId;
  final String channelName;

  @override
  State<_LinkControlsSheet> createState() => _LinkControlsSheetState();
}

class _LinkControlsSheetState extends State<_LinkControlsSheet> {
  static const Color _purple = Color(0xFF935CCC);
  static const Color _red = Color(0xFFDF1609);

  bool _loading = true;
  bool _busy = false;
  bool _noLink = false;
  String _block = '';
  String _note = '';
  bool _noteIsError = false;

  String _code = '';
  String _type = 'voice';
  bool _active = true;
  bool _approval = false;
  bool _expired = false;
  DateTime? _expiresAt;
  String _base = '';

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _dark ? const Color(0xFF1E1630) : Colors.white;
  Color get _ink => _dark ? Colors.white : const Color(0xFF1B1230);
  Color get _soft => _dark ? Colors.white70 : const Color(0xFF6B6480);

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _say(String t, {bool error = false}) {
    if (!mounted) return;
    setState(() {
      _note = t;
      _noteIsError = error;
    });
  }

  String _friendly(Object e) {
    final s = e.toString();
    if (s.contains('NOT_HOST')) {
      return 'Only the person who started the call can do this.';
    }
    if (s.contains('CALL_ENDED')) return 'This call has already ended.';
    if (s.contains('NOT_GROUP')) {
      return 'Invitation links work in group calls only.';
    }
    return 'Something went wrong, please try again.';
  }

  Future<void> _load() async {
    try {
      final me = SupaFlow.client.auth.currentUser?.id ?? '';
      final call = await SupaFlow.client
          .from('calls')
          .select('caller_id, is_group')
          .eq('id', widget.callId)
          .maybeSingle();
      if (call == null || call['caller_id'].toString() != me) {
        _blockWith('Only the person who started the call can change the link.');
        return;
      }
      if (call['is_group'] != true) {
        _blockWith(
            'Invitation links work in group calls. Start a group call from New call.');
        return;
      }
      final link = await SupaFlow.client
          .from('call_links')
          .select('code, call_type, is_active, requires_approval, expires_at')
          .eq('call_id', widget.callId)
          .maybeSingle();
      if (link == null) {
        if (!mounted) return;
        setState(() {
          _noLink = true;
          _loading = false;
        });
        return;
      }
      try {
        final cfg = await SupaFlow.client
            .from('app_config')
            .select('value')
            .eq('key', 'call_link_base')
            .maybeSingle();
        _base = (cfg?['value'] ?? '').toString().trim();
      } catch (_) {}
      while (_base.endsWith('/')) {
        _base = _base.substring(0, _base.length - 1);
      }
      final exp = DateTime.tryParse('${link['expires_at']}');
      if (!mounted) return;
      setState(() {
        _noLink = false;
        _code = link['code'].toString();
        _type = (link['call_type'] ?? 'voice').toString();
        _active = link['is_active'] == true;
        _approval = link['requires_approval'] == true;
        _expiresAt = exp?.toLocal();
        _expired = exp != null && exp.isBefore(DateTime.now().toUtc());
        _loading = false;
      });
    } catch (_) {
      _blockWith('Could not load the link, please try again.');
    }
  }

  void _blockWith(String t) {
    if (!mounted) return;
    setState(() {
      _block = t;
      _loading = false;
    });
  }

  Future<void> _save({bool? active, bool? approval}) async {
    if (_busy) return;
    final newActive = active ?? _active;
    final newApproval = approval ?? _approval;
    setState(() {
      _busy = true;
      _note = '';
    });
    try {
      await SupaFlow.client.rpc('set_call_link_options', params: {
        'p_call_id': widget.callId,
        'p_active': newActive,
        'p_requires_approval': newApproval,
      });
      if (!mounted) return;
      setState(() {
        _active = newActive;
        _approval = newApproval;
      });
      _say(active != null
          ? (newActive ? 'Link turned on' : 'Link turned off')
          : (newApproval
              ? 'People now need your approval to join'
              : 'People can join without approval'));
    } catch (e) {
      _say(_friendly(e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _create() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _note = '';
    });
    try {
      await SupaFlow.client.rpc('add_link_to_call', params: {
        'p_call_id': widget.callId,
        'p_channel': widget.channelName
      });
      await _load();
      _say('Link created');
    } catch (e) {
      _say(_friendly(e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copy() async {
    final text = _base.isEmpty
        ? 'Join my SchatzApp $_type call.\nCode: $_code'
        : 'Join my SchatzApp $_type call: $_base/$_code\nCode: $_code';
    await Clipboard.setData(ClipboardData(text: text));
    _say('Link copied');
  }

  String _expiryText() {
    final e = _expiresAt;
    if (e == null) return '';
    if (_expired) return 'This link has expired.';
    final left = e.difference(DateTime.now());
    if (left.inHours >= 1) return 'Expires in ${left.inHours} hours';
    return 'Expires in ${left.inMinutes < 1 ? 1 : left.inMinutes} minutes';
  }

  Widget _switchRow(String title, String sub, bool value, bool enabled,
      ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
                Text(sub, style: TextStyle(color: _soft, fontSize: 12.5)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: _purple,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
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
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Text('Call link',
                style: TextStyle(
                    color: _ink, fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator(color: _purple)),
              )
            else if (_block.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(_block,
                    style: TextStyle(color: _soft, fontSize: 14.5)),
              )
            else if (_noLink) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                    'This call has no invitation link yet. Create one so people can join by pasting it in SchatzApp.',
                    style: TextStyle(color: _soft, fontSize: 14.5)),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : _create,
                  icon: const Icon(Icons.link_rounded),
                  label: Text(_busy ? 'Creating...' : 'Create invitation link'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              if (_note.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_note,
                      style: TextStyle(
                          color: _noteIsError ? _red : const Color(0xFF2FBF71),
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
            ] else ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color:
                      _dark ? const Color(0xFF2A1F3F) : const Color(0xFFF2EEF8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Code  $_code',
                              style: TextStyle(
                                  color: _ink,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                  fontSize: 15)),
                          if (_expiryText().isNotEmpty)
                            Text(_expiryText(),
                                style: TextStyle(color: _soft, fontSize: 12.5)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: _purple),
                      onPressed: _copy,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _switchRow(
                  'Link is on',
                  'Turn off to stop anyone new joining with it',
                  _active && !_expired,
                  !_busy && !_expired,
                  (v) => _save(active: v)),
              _switchRow(
                  'Ask me before people join',
                  'You approve each person who uses the link',
                  _approval,
                  !_busy,
                  (v) => _save(approval: v)),
              if (_note.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_note,
                      style: TextStyle(
                          color: _noteIsError ? _red : const Color(0xFF2FBF71),
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
