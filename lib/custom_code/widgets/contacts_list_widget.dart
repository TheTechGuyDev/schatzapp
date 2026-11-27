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

class ContactsListWidget extends StatefulWidget {
  const ContactsListWidget({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
    this.query,
  });

  final double? width;
  final double? height;
  final String currentUserId;
  final String? query;

  @override
  State<ContactsListWidget> createState() => _ContactsListWidgetState();
}

class _ContactsListWidgetState extends State<ContactsListWidget> {
  late Future<List<ContactsDirectoryRow>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  // Contacts you have blocked are left out of the list.
  Future<List<ContactsDirectoryRow>> _load() async {
    final rows = await ContactsDirectoryTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('owner_id', widget.currentUserId)
          .order('saved_name', ascending: true),
    );
    try {
      final blocked = await SupaFlow.client
          .from('blocked_users')
          .select('blocked_id')
          .eq('blocker_id', widget.currentUserId);
      final ids = <String>{
        for (final r in blocked as List) r['blocked_id'] as String
      };
      if (ids.isEmpty) return rows;
      return rows
          .where(
              (r) => r.contactUserId == null || !ids.contains(r.contactUserId))
          .toList();
    } catch (_) {
      return rows;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: widget.width,
      height: widget.height,
      child: FutureBuilder<List<ContactsDirectoryRow>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: SizedBox(
                width: 40.0,
                height: 40.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                ),
              ),
            );
          }

          final query = (widget.query ?? '').trim().toLowerCase();
          var rows = snapshot.data!;
          if (query.isNotEmpty) {
            rows = rows.where((row) {
              final name = (row.savedName ?? '').toLowerCase();
              final fullName = (row.fullName ?? '').toLowerCase();
              final phone = (row.phoneNumber ?? '').toLowerCase();
              return name.contains(query) ||
                  fullName.contains(query) ||
                  phone.contains(query);
            }).toList();
          }

          if (rows.isEmpty) {
            return Center(
              child: Text(
                query.isNotEmpty ? 'No contacts found' : 'No contacts yet',
                style: TextStyle(color: theme.secondaryText, fontSize: 14),
              ),
            );
          }

          final items = <Object>[];
          String? lastLetter;
          for (final row in rows) {
            final name = (row.savedName ?? '').trim();
            final letter = name.isNotEmpty ? name[0].toUpperCase() : '#';
            if (letter != lastLetter) {
              items.add(letter);
              lastLetter = letter;
            }
            items.add(row);
          }

          return ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              if (item is String) {
                return Container(
                  width: double.infinity,
                  color: theme.secondaryBackground,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: theme.secondaryText,
                    ),
                  ),
                );
              }

              final row = item as ContactsDirectoryRow;
              final isRegistered = row.contactUserId != null;

              return InkWell(
                onTap: isRegistered
                    ? () async {
                        final conversationId = await findOrCreateConversation(
                          widget.currentUserId,
                          row.contactUserId!,
                        );
                        if (!context.mounted) return;
                        context.pushNamed(
                          'chatpage',
                          queryParameters: {
                            'conversationId': serializeParam(
                              conversationId,
                              ParamType.String,
                            ),
                            'otherUserId': serializeParam(
                              row.contactUserId,
                              ParamType.String,
                            ),
                            'displayName': serializeParam(
                              row.fullName ?? row.savedName,
                              ParamType.String,
                            ),
                            'displayAvatar': serializeParam(
                              row.avatarUrl,
                              ParamType.String,
                            ),
                          }.withoutNulls,
                        );
                      }
                    : null,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.alternate,
                        ),
                        child: row.avatarUrl != null
                            ? Image.network(row.avatarUrl!, fit: BoxFit.cover)
                            : Icon(Icons.person,
                                color: theme.secondaryText, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (row.savedName?.isNotEmpty ?? false)
                                  ? row.savedName!
                                  : (row.phoneNumber ?? ''),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: theme.primaryText,
                              ),
                            ),
                            const SizedBox(height: 3),
                            if (isRegistered)
                              Text(
                                row.isOnline == true
                                    ? 'Online'
                                    : (row.phoneNumber ?? ''),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.secondaryText,
                                ),
                              )
                            else ...[
                              Text(
                                row.phoneNumber ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              InkWell(
                                onTap: () {
                                  Share.share(
                                    'Join me on SchatzApp! Download here: https://schatzapp.com/',
                                  );
                                },
                                child: Text(
                                  'Invite friend to SchatzApp',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
