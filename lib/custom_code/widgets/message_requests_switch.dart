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

class MessageRequestsSwitch extends StatefulWidget {
  const MessageRequestsSwitch({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<MessageRequestsSwitch> createState() => _MessageRequestsSwitchState();
}

class _MessageRequestsSwitchState extends State<MessageRequestsSwitch> {
  static const Color _purple = Color(0xFF935CCC);
  bool _on = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final rows = await SupaFlow.client
          .from('profiles')
          .select('message_requests_enabled')
          .eq('id', uid)
          .limit(1);
      if (!mounted) return;
      setState(() {
        _on = rows.isNotEmpty && rows.first['message_requests_enabled'] == true;
        _ready = true;
      });
    } catch (_) {
      if (mounted) setState(() => _ready = true);
    }
  }

  Future<void> _set(bool v) async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) return;
    setState(() => _on = v);
    try {
      await SupaFlow.client
          .from('profiles')
          .update({'message_requests_enabled': v}).eq('id', uid);
    } catch (_) {
      if (!mounted) return;
      setState(() => _on = !v);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save. Try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                color: Color(0xFFEFEBF2), shape: BoxShape.circle),
            child: const Icon(Icons.mark_email_unread_outlined,
                color: _purple, size: 20),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Message requests',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                SizedBox(height: 2),
                Text(
                  'When on, people who are not in your contacts must send a request first.',
                  style: TextStyle(fontSize: 11.5, color: Colors.black54),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _on,
            activeColor: _purple,
            onChanged: _ready ? _set : null,
          ),
        ],
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
