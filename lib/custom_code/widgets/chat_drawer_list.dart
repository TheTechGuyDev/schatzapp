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
import 'package:go_router/go_router.dart';

// The drawer's chat list: the same list and the same filters as the
// Chats tab on the home page.
class ChatDrawerList extends StatefulWidget {
  const ChatDrawerList({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
  });

  final double? width;
  final double? height;
  final String currentUserId;

  @override
  State<ChatDrawerList> createState() => _ChatDrawerListState();
}

class _ChatDrawerListState extends State<ChatDrawerList> {
  static const Color _accent = Color(0xFFD239EF);
  String _filter = 'all';

  Widget _chip(String label, String value) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = value),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? _accent : Colors.grey.withOpacity(0.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openChat(String conversationId, String otherUserId,
      String displayName, String displayAvatar) async {
    // Close the drawer, then open the chat the same way the home page does.
    Navigator.of(context).pop();
    if (otherUserId.isEmpty) {
      context.pushNamed('Group_chatpage', queryParameters: {
        'groupConversationId': conversationId,
        'groupNameParam': displayName,
        'groupAvatarParam': displayAvatar,
        'displayName': displayName,
        'conversationId': conversationId,
        'displayAvatar': displayAvatar,
      });
    } else {
      context.pushNamed('chatpage', queryParameters: {
        'conversationId': conversationId,
        'otherUserId': otherUserId,
        'displayName': displayName,
        'displayAvatar': displayAvatar,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            child: Row(
              children: [
                _chip('All', 'all'),
                _chip('Unread', 'unread'),
                _chip('Groups', 'groups'),
                _chip('Archived', 'archived'),
              ],
            ),
          ),
          Expanded(
            child: ChatListPanel(
              width: double.infinity,
              height: double.infinity,
              currentUserId: widget.currentUserId,
              filter: _filter,
              onOpenChat: _openChat,
              onAddFriend: () async {
                Navigator.of(context).pop();
                context.pushNamed('Addfriends');
              },
            ),
          ),
        ],
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
