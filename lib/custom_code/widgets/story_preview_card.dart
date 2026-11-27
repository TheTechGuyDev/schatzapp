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

import 'package:google_fonts/google_fonts.dart';

class StoryPreviewCard extends StatefulWidget {
  const StoryPreviewCard({
    super.key,
    this.width,
    this.height,
    required this.item,
  });

  final double? width;
  final double? height;
  final StoryItemStruct item;

  @override
  State<StoryPreviewCard> createState() => _StoryPreviewCardState();
}

class _StoryPreviewCardState extends State<StoryPreviewCard> {
  TextStyle _fontStyle(int index,
      {required double size, required Color color}) {
    switch (index) {
      case 0:
        return GoogleFonts.roboto(
            fontSize: size, color: color, fontWeight: FontWeight.w600);
      case 1:
        return GoogleFonts.openSans(
            fontSize: size, color: color, fontWeight: FontWeight.w600);
      case 2:
        return GoogleFonts.lato(
            fontSize: size, color: color, fontWeight: FontWeight.w600);
      case 3:
        return GoogleFonts.montserrat(
            fontSize: size, color: color, fontWeight: FontWeight.w600);
      case 4:
        return GoogleFonts.poppins(
            fontSize: size, color: color, fontWeight: FontWeight.w300);
      case 5:
        return GoogleFonts.dancingScript(
            fontSize: size, color: color, fontWeight: FontWeight.w600);
      case 6:
        return GoogleFonts.greatVibes(fontSize: size, color: color);
      case 7:
        return GoogleFonts.pacifico(fontSize: size, color: color);
      case 8:
        return GoogleFonts.sacramento(fontSize: size, color: color);
      case 9:
        return GoogleFonts.satisfy(fontSize: size, color: color);
      default:
        return GoogleFonts.roboto(
            fontSize: size, color: color, fontWeight: FontWeight.w600);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (widget.item.mediaType == 'text') {
      content = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _parseGradientColors(widget.item.backgroundColor),
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: Text(
          widget.item.caption,
          textAlign: TextAlign.center,
          style:
              _fontStyle(widget.item.fontIndex, size: 14, color: Colors.white),
        ),
      );
    } else if (widget.item.mediaType == 'video') {
      content = Stack(
        alignment: Alignment.center,
        children: [
          Container(color: Colors.black87),
          const Icon(Icons.play_circle_fill, color: Colors.white70, size: 40),
        ],
      );
    } else {
      content = widget.item.mediaUrl.isNotEmpty
          ? Image.network(widget.item.mediaUrl, fit: BoxFit.cover)
          : Container(color: Colors.black26);
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: content,
    );
  }

  List<Color> _parseGradientColors(String? hex) {
    if (hex == null || hex.isEmpty) {
      return [Colors.deepPurple, Colors.deepPurple];
    }
    final parts = hex.split(',');
    Color parseOne(String h) {
      var value = h.trim().replaceAll('#', '');
      if (value.length == 6) value = 'FF$value';
      try {
        return Color(int.parse(value, radix: 16));
      } catch (_) {
        return Colors.deepPurple;
      }
    }

    if (parts.length >= 2) {
      return [parseOne(parts[0]), parseOne(parts[1])];
    }
    final single = parseOne(parts[0]);
    return [single, single];
  }
}
