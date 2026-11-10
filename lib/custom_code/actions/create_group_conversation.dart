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

Future<String?> createGroupConversation(
  String groupName,
  String? groupAvatarUrl,
  String creatorId,
  List<GroupMemberStructStruct> members,
  bool isPrivateGroup,
) async {
  final trimmedName = groupName.trim();
  if (trimmedName.isEmpty || members.isEmpty) {
    return null;
  }

  // 1. Create the conversation row
  final conversationResponse = await SupaFlow.client
      .from('conversations')
      .insert({
        'type': 'group',
        'name': trimmedName,
        'avatar_url': groupAvatarUrl,
        'created_by': creatorId,
        'is_private_group': isPrivateGroup,
      })
      .select()
      .single();

  final conversationId = conversationResponse['id'] as String;

  // 2. Creator becomes admin, everyone else is a member
  final participantRows = <Map<String, dynamic>>[
    {
      'conversation_id': conversationId,
      'user_id': creatorId,
      'role': 'admin',
    },
    ...members.map((m) => {
          'conversation_id': conversationId,
          'user_id': m.memberId,
          'role': 'member',
        }),
  ];

  await SupaFlow.client
      .from('conversation_participants')
      .insert(participantRows);

  return conversationId;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
