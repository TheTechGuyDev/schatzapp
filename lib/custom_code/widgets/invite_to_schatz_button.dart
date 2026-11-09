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

import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class InviteToSchatzButton extends StatelessWidget {
  const InviteToSchatzButton({
    super.key,
    this.width,
    this.height,
    required this.contactName,
  });

  final double? width;
  final double? height;
  final String contactName;

  static const Color _purple = Color(0xFF935CCC);
  static const String _link = 'https://schatzapp.com/';

  String get _first {
    final n = contactName.trim();
    if (n.isEmpty) return 'your contact';
    return n.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: width,
      height: height ?? 56,
      child: Material(
        color: dark ? const Color(0xFF2A1C42) : const Color(0xFFF1E8FB),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Share.share(
              'Hi $_first, I am on SchatzApp. Join me! Download it here: $_link',
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add_alt_1_rounded,
                    color: _purple, size: 22),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'Invite $_first to join SchatzApp',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _purple,
                    ),
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
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
