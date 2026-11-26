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

class UserAvatarWidget extends StatefulWidget {
  const UserAvatarWidget({
    super.key,
    this.width,
    this.height,
    this.avatarUrl,
    required this.displayName,
    this.radius,
    this.userId,
  });

  final double? width;
  final double? height;
  final String? avatarUrl;
  final String displayName;
  final double? radius;
  final String? userId;

  @override
  State<UserAvatarWidget> createState() => _UserAvatarWidgetState();
}

class _UserAvatarWidgetState extends State<UserAvatarWidget> {
  bool _blocked = false;

  @override
  void initState() {
    super.initState();
    _checkBlocked();
  }

  @override
  void didUpdateWidget(covariant UserAvatarWidget old) {
    super.didUpdateWidget(old);
    if (old.userId != widget.userId) _checkBlocked();
  }

  // A block in either direction shows the grey default picture.
  Future<void> _checkBlocked() async {
    final id = widget.userId;
    if (id == null || id.isEmpty) {
      if (_blocked) setState(() => _blocked = false);
      return;
    }
    try {
      final res =
          await SupaFlow.client.rpc('block_status', params: {'p_other': id});
      if (!mounted) return;
      final blocked = (res ?? 'none').toString() != 'none';
      if (blocked != _blocked) setState(() => _blocked = blocked);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.radius ?? 26;
    if (_blocked) {
      return CircleAvatar(
        radius: r,
        backgroundColor: const Color(0xFFE0E0E0),
        child:
            Icon(Icons.person, color: const Color(0xFF9E9E9E), size: r * 1.2),
      );
    }
    final url = (widget.avatarUrl ?? '').trim();
    // Stock placeholder links and bad values count as "no photo".
    final hasAvatar = url.toLowerCase().startsWith('http') &&
        !url.toLowerCase().contains('unsplash.com');
    if (!hasAvatar) {
      return CircleAvatar(
        radius: r,
        backgroundColor: const Color(0xFFEFEBF2),
        child: Icon(Icons.person_outline,
            color: const Color(0xFF935CCC), size: r * 1.1),
      );
    }
    return CircleAvatar(
      radius: r,
      backgroundColor: const Color(0xFFEFEBF2),
      backgroundImage: cachedNetworkImageProvider(url),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
