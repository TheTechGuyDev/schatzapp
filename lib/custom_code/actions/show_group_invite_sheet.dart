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
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

Future<void> showGroupInviteSheet(
  String conversationId,
  String groupName,
  bool showQr,
) async {
  final ctx = appNavigatorKey.currentContext;
  if (ctx == null) return;
  await showModalBottomSheet<void>(
    context: ctx,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _GroupInviteSheet(
      conversationId: conversationId,
      groupName: groupName,
      showQr: showQr,
    ),
  );
}

class _GroupInviteSheet extends StatefulWidget {
  const _GroupInviteSheet({
    required this.conversationId,
    required this.groupName,
    required this.showQr,
  });

  final String conversationId;
  final String groupName;
  final bool showQr;

  @override
  State<_GroupInviteSheet> createState() => _GroupInviteSheetState();
}

class _GroupInviteSheetState extends State<_GroupInviteSheet> {
  static const Color _purple = Color(0xFF935CCC);
  static const String _base = 'https://web.schatzapp.com/joinGroupPage?code=';

  bool _loading = true;
  String _link = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final code = await SupaFlow.client.rpc('get_group_invite_code',
          params: {'p_conversation': widget.conversationId});
      if (code != null && code.toString().isNotEmpty) {
        _link = '$_base$code';
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _toast(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 24 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.showQr ? 'Group QR Code' : 'Invite via link',
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(widget.groupName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 18),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(),
            )
          else if (_link.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Could not create the invite link. Try again.'),
            )
          else ...[
            if (widget.showQr)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE9DDF5)),
                ),
                child: QrImageView(
                  data: _link,
                  size: 210,
                  backgroundColor: Colors.white,
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EEFA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(_link,
                    style: const TextStyle(fontSize: 13, color: _purple)),
              ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: _link));
                      _toast('Link copied');
                    },
                    icon: const Icon(Icons.copy, size: 18, color: _purple),
                    label: const Text('Copy', style: TextStyle(color: _purple)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        foregroundColor: Colors.white),
                    onPressed: () => Share.share(
                        'Join my group "${widget.groupName}" on SchatzApp: $_link'),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
