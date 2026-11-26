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

class ContactAvatar extends StatefulWidget {
  const ContactAvatar({
    super.key,
    this.width,
    this.height,
    this.userId,
    this.imageUrl,
    this.name,
    this.size,
  });

  final double? width;
  final double? height;
  final String? userId;
  final String? imageUrl;
  final String? name;
  final double? size;

  @override
  State<ContactAvatar> createState() => _ContactAvatarState();
}

class _ContactAvatarState extends State<ContactAvatar> {
  static const Color _purple = Color(0xFF935CCC);
  String _url = '';

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant ContactAvatar old) {
    super.didUpdateWidget(old);
    if (old.imageUrl != widget.imageUrl || old.userId != widget.userId) {
      _resolve();
    }
  }

  Future<void> _resolve() async {
    final given = (widget.imageUrl ?? '').trim();
    if (given.toLowerCase().startsWith('http')) {
      if (mounted) setState(() => _url = given);
      return;
    }
    if (mounted) setState(() => _url = '');
    final uid = (widget.userId ?? '').trim();
    final isUuid = RegExp(
            r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
        .hasMatch(uid);
    if (!isUuid) return;
    try {
      final rows = await SupaFlow.client
          .from('profiles')
          .select('avatar_url')
          .eq('id', uid)
          .limit(1);
      if (rows.isNotEmpty && mounted) {
        setState(
            () => _url = ((rows.first['avatar_url'] as String?) ?? '').trim());
      }
    } catch (_) {}
  }

  Widget _fallback(double s) => Container(
        width: s,
        height: s,
        alignment: Alignment.center,
        color: const Color(0xFFEFEBF2),
        child: Icon(Icons.person_outline, color: _purple, size: s * 0.55),
      );

  @override
  Widget build(BuildContext context) {
    final s = widget.size ?? widget.width ?? widget.height ?? 55.0;
    return ClipOval(
      child: SizedBox(
        width: s,
        height: s,
        child: _url.isEmpty
            ? _fallback(s)
            : cachedNetworkImage(
                _url,
                width: s,
                height: s,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(s),
                loadingBuilder: (c, child, p) => p == null
                    ? child
                    : Container(color: _purple.withOpacity(0.08)),
              ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
