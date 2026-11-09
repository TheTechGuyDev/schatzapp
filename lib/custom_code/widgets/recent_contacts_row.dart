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

import '/app_state.dart';

class RecentContactsRow extends StatefulWidget {
  const RecentContactsRow({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
    required this.onSelect,
  });

  final double? width;
  final double? height;
  final String currentUserId;
  final Future Function() onSelect;

  @override
  State<RecentContactsRow> createState() => _RecentContactsRowState();
}

class _RecentContactsRowState extends State<RecentContactsRow> {
  bool _loading = true;
  List<_RecentContact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Numbers are compared on their last 10 digits, so 0812..., 812... and
  // 234812... all count as the same number.
  String _key(String raw) {
    var d = raw.replaceAll(RegExp(r'[^0-9]'), '');
    d = d.replaceFirst(RegExp(r'^0+'), '');
    return d.length > 10 ? d.substring(d.length - 10) : d;
  }

  Future<void> _load() async {
    try {
      final ownProfile = await SupaFlow.client
          .from('profiles')
          .select('id, phone_number, full_name, avatar_url')
          .eq('id', widget.currentUserId)
          .maybeSingle();
      final ownKey = _key((ownProfile?['phone_number'] ?? '').toString());

      final txRows = await SupaFlow.client
          .from('wallet_transactions')
          .select('metadata, type')
          .eq('user_id', widget.currentUserId)
          .inFilter('type', ['airtime', 'data'])
          .order('created_at', ascending: false)
          .limit(200);

      // Most recent first. Keep the number exactly as it was typed.
      final rawByKey = <String, String>{};
      final order = <String>[];
      for (final row in List<Map<String, dynamic>>.from(txRows)) {
        final metadata = row['metadata'];
        if (metadata is! Map) continue;
        final raw = (metadata['recipientPhone'] ?? '').toString().trim();
        if (raw.isEmpty) continue;
        final k = _key(raw);
        if (k.length < 7) continue;
        if (!rawByKey.containsKey(k)) {
          rawByKey[k] = raw;
          order.add(k);
        }
        if (order.length >= 8) break;
      }

      // Find registered users for these numbers (match on the last digits).
      final profileByKey = <String, Map<String, dynamic>>{};
      if (order.isNotEmpty) {
        try {
          final filter = order.map((k) => 'phone_number.ilike.%$k').join(',');
          final found = await SupaFlow.client
              .from('profiles')
              .select('id, full_name, avatar_url, phone_number')
              .or(filter);
          for (final p in List<Map<String, dynamic>>.from(found)) {
            final k = _key((p['phone_number'] ?? '').toString());
            if (k.isNotEmpty) profileByKey[k] = p;
          }
        } catch (_) {}
      }

      final resolved = <_RecentContact>[];
      for (final k in order) {
        final raw = rawByKey[k]!;
        if (ownKey.isNotEmpty && k == ownKey) {
          resolved.add(_RecentContact(
            phoneNumber: raw,
            displayName: 'Me',
            avatarUrl: (ownProfile?['avatar_url'] ?? '').toString(),
          ));
          continue;
        }
        final match = profileByKey[k];
        if (match != null) {
          var name = (match['full_name'] ?? '').toString();
          try {
            final resolvedName = await getResolvedDisplayName(
                widget.currentUserId, (match['id'] ?? '').toString());
            if (resolvedName.trim().isNotEmpty) name = resolvedName;
          } catch (_) {}
          resolved.add(_RecentContact(
            phoneNumber: raw,
            displayName: name,
            avatarUrl: (match['avatar_url'] ?? '').toString(),
          ));
        } else {
          // Not on SchatzApp: show the number itself.
          resolved.add(_RecentContact(
            phoneNumber: raw,
            displayName: raw,
            avatarUrl: '',
            isUnknown: true,
          ));
        }
      }

      if (!mounted) return;
      setState(() {
        _contacts = resolved;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _handleTap(String phone) {
    FFAppState().update(() {
      FFAppState().recentContactSelectedPhone = phone;
    });
    widget.onSelect();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _contacts.isEmpty) {
      return const SizedBox.shrink();
    }
    final accent = FlutterFlowTheme.of(context).primary;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _contacts.map((contact) {
            return Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 15.0, 0.0),
              child: GestureDetector(
                onTap: () => _handleTap(contact.phoneNumber),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 24.5,
                      backgroundColor: accent.withOpacity(0.15),
                      backgroundImage: contact.avatarUrl.isNotEmpty
                          ? NetworkImage(contact.avatarUrl)
                          : null,
                      child: contact.avatarUrl.isEmpty
                          ? (contact.isUnknown
                              ? Icon(Icons.person_rounded, color: accent)
                              : Text(
                                  contact.displayName.isNotEmpty
                                      ? contact.displayName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(color: accent),
                                ))
                          : null,
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 72,
                      child: Text(
                        contact.displayName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: contact.isUnknown ? 11 : 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _RecentContact {
  _RecentContact({
    required this.phoneNumber,
    required this.displayName,
    required this.avatarUrl,
    this.isUnknown = false,
  });

  final String phoneNumber;
  final String displayName;
  final String avatarUrl;
  final bool isUnknown;
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
