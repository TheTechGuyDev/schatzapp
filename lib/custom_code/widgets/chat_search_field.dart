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

import 'package:flutter/material.dart';

class ChatSearchField extends StatefulWidget {
  const ChatSearchField({
    super.key,
    this.width,
    this.height,
    required this.onQueryChanged,
    required this.onClose,
  });

  final double? width;
  final double? height;
  final Future Function(String query) onQueryChanged;
  final Future Function() onClose;

  @override
  State<ChatSearchField> createState() => _ChatSearchFieldState();
}

class _ChatSearchFieldState extends State<ChatSearchField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _close() {
    _controller.clear();
    _focus.unfocus();
    widget.onQueryChanged('');
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height ?? 45,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black26),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.search, color: Colors.black54, size: 24),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                maxLength: 150,
                textInputAction: TextInputAction.search,
                onChanged: (v) => widget.onQueryChanged(v),
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                decoration: const InputDecoration(
                  isDense: true,
                  counterText: '',
                  border: InputBorder.none,
                  hintText: 'Search messages',
                ),
              ),
            ),
            GestureDetector(
              onTap: _close,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black12,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
