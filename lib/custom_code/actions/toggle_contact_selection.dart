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

Future<List<GroupMemberStructStruct>> toggleContactSelection(
  List<GroupMemberStructStruct> currentSelection,
  ContactsDirectoryRow contact,
) async {
  final memberId = contact.contactUserId;
  if (memberId == null || memberId.isEmpty) return currentSelection;

  final saved = (contact.savedName ?? '').trim();
  final memberName = saved.isNotEmpty ? saved : 'Unknown';
  final memberAvatar = contact.avatarUrl ?? '';

  final updated = List<GroupMemberStructStruct>.from(currentSelection);
  final existingIndex = updated.indexWhere((m) => m.memberId == memberId);

  if (existingIndex >= 0) {
    updated.removeAt(existingIndex);
  } else {
    updated.add(GroupMemberStructStruct(
      memberId: memberId,
      memberName: memberName,
      memberAvatar: memberAvatar,
    ));
  }

  return updated;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
