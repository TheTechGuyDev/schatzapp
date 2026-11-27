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

class JoinGroupView extends StatefulWidget {
  const JoinGroupView({
    super.key,
    this.width,
    this.height,
    required this.code,
  });

  final double? width;
  final double? height;
  final String code;

  @override
  State<JoinGroupView> createState() => _JoinGroupViewState();
}

class _JoinGroupViewState extends State<JoinGroupView> {
  static const Color _purple = Color(0xFF935CCC);

  bool _loading = true;
  bool _joining = false;
  String _convId = '';
  String _name = '';
  String _avatar = '';
  int _count = 0;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await SupaFlow.client
          .rpc('get_group_invite_preview', params: {'p_code': widget.code});
      final list = (r as List?) ?? [];
      if (list.isEmpty) {
        _error = 'This invite link is invalid or has expired.';
      } else {
        final m = Map<String, dynamic>.from(list.first as Map);
        _convId = (m['conversation_id'] ?? '').toString();
        _name = (m['name'] ?? 'Group').toString();
        _avatar = (m['avatar_url'] ?? '').toString();
        _count = int.tryParse((m['member_count'] ?? '0').toString()) ?? 0;
      }
    } catch (_) {
      _error = 'Could not load this invite. Try again.';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _join() async {
    if (_joining) return;
    setState(() => _joining = true);
    try {
      final r = await SupaFlow.client
          .rpc('join_group_by_code', params: {'p_code': widget.code});
      final id = (r ?? '').toString();
      if (id.isEmpty) {
        if (mounted) {
          setState(() {
            _joining = false;
            _error = 'This invite link is invalid or has expired.';
          });
        }
        return;
      }
      if (!mounted) return;
      context.pushNamed('Group_chatpage',
          queryParameters: {
            'groupConversationId': serializeParam(id, ParamType.String),
            'groupNameParam': serializeParam(_name, ParamType.String),
            'groupAvatarParam': serializeParam(_avatar, ParamType.String),
            'displayName': serializeParam(_name, ParamType.String),
            'conversationId': serializeParam(id, ParamType.String),
            'displayAvatar': serializeParam(_avatar, ParamType.String),
          }.withoutNulls);
    } catch (_) {
      if (mounted) {
        setState(() {
          _joining = false;
          _error = 'Could not join. Try again.';
        });
      }
    }
  }

  Widget _groupIcon() {
    final has = _avatar.trim().isNotEmpty;
    return Container(
      width: 110,
      height: 110,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFE9DDF5),
        borderRadius: BorderRadius.circular(28),
      ),
      child: has
          ? Image.network(_avatar,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.groups, size: 56, color: _purple))
          : const Icon(Icons.groups, size: 56, color: _purple),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_convId.isNotEmpty) ...[
                      _groupIcon(),
                      const SizedBox(height: 18),
                      Text(_name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text('$_count members',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black54)),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 220,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _purple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                          ),
                          onPressed: _joining ? null : _join,
                          child: _joining
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Join group'),
                        ),
                      ),
                    ],
                    if (_error.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(_error,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
