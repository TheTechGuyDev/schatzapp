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

class GroupAvatar extends StatelessWidget {
  const GroupAvatar({
    super.key,
    this.width,
    this.height,
    this.imageUrl,
    this.size,
  });

  final double? width;
  final double? height;
  final String? imageUrl;
  final double? size;

  static const Color _purple = Color(0xFF935CCC);

  @override
  Widget build(BuildContext context) {
    final s = size ?? width ?? height ?? 55.0;
    final url = (imageUrl ?? '').trim();
    final fallback = Container(
      width: s,
      height: s,
      alignment: Alignment.center,
      color: const Color(0xFFEFEBF2),
      child: Icon(Icons.groups, color: _purple, size: s * 0.58),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(s * 0.28),
      child: SizedBox(
        width: s,
        height: s,
        child: url.toLowerCase().startsWith('http')
            ? Image.network(
                url,
                width: s,
                height: s,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              )
            : fallback,
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
