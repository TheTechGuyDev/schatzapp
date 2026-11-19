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

class _FavContact {
  const _FavContact({
    required this.otherUserId,
    required this.displayName,
    required this.avatarUrl,
    required this.isOnline,
    required this.hasActiveStatus,
    required this.hasUnviewedStatus,
  });

  final String otherUserId;
  final String displayName;
  final String avatarUrl;
  final bool isOnline;
  final bool hasActiveStatus;
  final bool hasUnviewedStatus;
}

class FavoritesRowWidget extends StatefulWidget {
  const FavoritesRowWidget({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
  });

  final double? width;
  final double? height;
  final String currentUserId;

  @override
  State<FavoritesRowWidget> createState() => _FavoritesRowWidgetState();
}

class _FavoritesRowWidgetState extends State<FavoritesRowWidget> {
  static const int _maxContacts = 8;

  bool _hasPhoto(String u) =>
      u.toLowerCase().startsWith('http') &&
      !u.toLowerCase().contains('unsplash.com');

  Future<List<_FavContact>> _load() async {
    final chatRows = await SupaFlow.client
        .from('chat_list_view')
        .select()
        .eq('type', 'direct')
        .order('last_message_at', ascending: false);

    var blocked = <String>{};
    try {
      final b = await SupaFlow.client.rpc('blocked_peers');
      blocked = {for (final x in (b as List)) x.toString()};
    } catch (_) {}

    final filtered = chatRows
        .where((r) =>
            !blocked.contains('${r['other_user_id']}') &&
            r['is_archived'] != true &&
            r['other_user_id'] != null &&
            r['last_message_at'] != null)
        .take(_maxContacts)
        .toList();

    if (filtered.isEmpty) return [];

    final otherIds =
        filtered.map((r) => r['other_user_id'] as String).toSet().toList();

    final storyRows = await SupaFlow.client
        .from('story_ring_view')
        .select('user_id, has_unviewed')
        .inFilter('user_id', otherIds);

    final statusByUser = <String, bool>{
      for (final row in storyRows)
        row['user_id'] as String: (row['has_unviewed'] as bool?) ?? false,
    };

    return filtered.map((r) {
      final id = r['other_user_id'] as String;
      return _FavContact(
        otherUserId: id,
        displayName: (r['display_name'] as String?) ?? '',
        avatarUrl: (r['display_avatar'] as String?) ?? '',
        isOnline: r['is_online'] == true,
        hasActiveStatus: statusByUser.containsKey(id),
        hasUnviewedStatus: statusByUser[id] ?? false,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return FutureBuilder<List<_FavContact>>(
      future: _load(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final contacts = snapshot.data!;
        if (contacts.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                child: Text(
                  'Favorites',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: theme.secondaryText,
                  ),
                ),
              ),
              SizedBox(
                height: 75,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: contacts.map((c) {
                      final hasStatus = c.hasActiveStatus;
                      final ringColor = hasStatus
                          ? (c.hasUnviewedStatus
                              ? theme.primary
                              : const Color(0xFF3F4A52))
                          : Colors.transparent;

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Stack(
                          alignment: AlignmentDirectional.bottomEnd,
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                final conversationId =
                                    await findOrCreateConversation(
                                  widget.currentUserId,
                                  c.otherUserId,
                                );
                                if (!context.mounted) return;
                                context.pushNamed(
                                  'chatpage',
                                  queryParameters: {
                                    'conversationId': serializeParam(
                                        conversationId, ParamType.String),
                                    'otherUserId': serializeParam(
                                        c.otherUserId, ParamType.String),
                                    'displayName': serializeParam(
                                        c.displayName, ParamType.String),
                                    'displayAvatar': serializeParam(
                                        c.avatarUrl, ParamType.String),
                                  }.withoutNulls,
                                );
                              },
                              child: Container(
                                width: 65,
                                height: 65,
                                decoration: BoxDecoration(
                                  color: theme.secondaryBackground,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ringColor,
                                    width: 2.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Container(
                                    width: 55,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFEBF2),
                                      shape: BoxShape.circle,
                                      image: _hasPhoto(c.avatarUrl)
                                          ? DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(c.avatarUrl),
                                            )
                                          : null,
                                    ),
                                    alignment: Alignment.center,
                                    child: _hasPhoto(c.avatarUrl)
                                        ? null
                                        : const Icon(Icons.person_outline,
                                            color: Color(0xFF935CCC), size: 30),
                                  ),
                                ),
                              ),
                            ),
                            if (c.isOnline)
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 3, bottom: 5),
                                child: Container(
                                  width: 13,
                                  height: 13,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2FFB4B),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.secondaryBackground,
                                      width: 3.0,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
