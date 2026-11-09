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

Future<List<GroupMemberStructStruct>> toggleGroupMemberSelection(
  List<GroupMemberStructStruct> currentSelection,
  String memberId,
  String memberName,
  String memberAvatar,
) async {
  final updated = List<GroupMemberStructStruct>.from(currentSelection);
  final existingIndex = updated.indexWhere((m) => m.memberId == memberId);

  if (existingIndex >= 0) {
    // already selected -> remove
    updated.removeAt(existingIndex);
  } else {
    // not selected -> add
    updated.add(GroupMemberStructStruct(
      memberId: memberId,
      memberName: memberName,
      memberAvatar: memberAvatar,
    ));
  }

  return updated;
}
