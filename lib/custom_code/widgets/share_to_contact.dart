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

import '/custom_code/actions/index.dart';

class ShareToContact extends StatefulWidget {
  const ShareToContact({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
    required this.storyMediaUrl,
    required this.storyMediaType,
    required this.onDone,
  });

  final double? width;
  final double? height;
  final String currentUserId;
  final String storyMediaUrl;
  final String storyMediaType;
  final Future Function() onDone;

  @override
  State<ShareToContact> createState() => _ShareToContactState();
}

class _ShareToContactState extends State<ShareToContact> {
  bool _loading = true;
  List<Map<String, dynamic>> _friends = [];
  Set<String> _sentIds = {};
  Set<String> _sendingIds = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await SupaFlow.client
        .from('contacts')
        .select(
            'contact_user_id, profiles!contacts_contact_user_id_fkey(full_name, avatar_url)')
        .eq('owner_id', widget.currentUserId)
        .not('contact_user_id', 'is', null);

    final friends = rows
        .where((row) => row['profiles'] != null)
        .map((row) => {
              'id': row['contact_user_id'] as String,
              'fullName': (row['profiles']['full_name'] as String?) ?? '',
              'avatarUrl': (row['profiles']['avatar_url'] as String?) ?? '',
            })
        .toList();

    if (!mounted) return;
    setState(() {
      _friends = friends;
      _loading = false;
    });
  }

  Future<void> _send(String contactId) async {
    if (_sentIds.contains(contactId) || _sendingIds.contains(contactId)) {
      return;
    }
    setState(() => _sendingIds.add(contactId));

    try {
      await shareStoryToContact(
        widget.currentUserId,
        contactId,
        widget.storyMediaUrl,
        widget.storyMediaType,
      );
      if (!mounted) return;
      setState(() {
        _sendingIds.remove(contactId);
        _sentIds.add(contactId);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _sendingIds.remove(contactId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t share: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _friends
        .where((f) => (f['fullName'] as String)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Share status to',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  InkWell(
                    onTap: () async {
                      await widget.onDone();
                    },
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: const InputDecoration(
                    hintText: 'Search contacts...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const Center(child: Text('No contacts found'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final friend = filtered[i];
                            final id = friend['id'] as String;
                            final sent = _sentIds.contains(id);
                            final sending = _sendingIds.contains(id);
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 22,
                                backgroundImage:
                                    (friend['avatarUrl'] as String).isNotEmpty
                                        ? NetworkImage(friend['avatarUrl'])
                                        : null,
                              ),
                              title: Text(friend['fullName']),
                              trailing: sending
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : sent
                                      ? const Icon(Icons.check_circle,
                                          color: Color(0xFF2FFB4B))
                                      : const Icon(Icons.send_outlined,
                                          color: Color(0xFF935CCC)),
                              onTap: () => _send(id),
                            );
                          },
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
