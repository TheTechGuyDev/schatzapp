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

class TagFriendsPicker extends StatefulWidget {
  const TagFriendsPicker({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
    required this.onDone,
  });

  final double? width;
  final double? height;
  final String currentUserId;
  final Future Function() onDone;

  @override
  State<TagFriendsPicker> createState() => _TagFriendsPickerState();
}

class _TagFriendsPickerState extends State<TagFriendsPicker> {
  bool _loading = true;
  List<Map<String, dynamic>> _friends = [];
  Set<String> _selectedIds = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedIds = FFAppState().pendingStoryTaggedUserIds.toSet();
    _load();
  }

  Future<void> _load() async {
    final rows = await SupaFlow.client
        .from('contacts')
        .select(
            'contact_user_id, profiles!contacts_contact_user_id_fkey(full_name, avatar_url)')
        .eq('owner_id', widget.currentUserId)
        .not('contact_user_id', 'is', null);

    // People the viewer locked are hidden from normal lists.
    final lockedIds = <String>{};
    try {
      final lockedRows = await SupaFlow.client
          .from('chat_list_view')
          .select('other_user_id')
          .eq('is_locked', true)
          .neq('type', 'group');
      for (final r in lockedRows) {
        final id = r['other_user_id'] as String?;
        if (id != null) lockedIds.add(id);
      }
    } catch (_) {}

    final friends = rows
        .where((row) => row['profiles'] != null)
        .where((row) => !lockedIds.contains(row['contact_user_id']))
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

  void _toggle(String friendId) {
    setState(() {
      if (_selectedIds.contains(friendId)) {
        _selectedIds.remove(friendId);
      } else {
        _selectedIds.add(friendId);
      }
    });
    FFAppState().pendingStoryTaggedUserIds = _selectedIds.toList();
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
                  Text('Tag people (${_selectedIds.length})',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  InkWell(
                    onTap: () async {
                      await widget.onDone();
                    },
                    child: const Icon(Icons.check_circle,
                        color: Color(0xFF935CCC)),
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
                            final selected = _selectedIds.contains(id);
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 22,
                                backgroundImage:
                                    (friend['avatarUrl'] as String).isNotEmpty
                                        ? cachedNetworkImageProvider(friend['avatarUrl'])
                                        : null,
                              ),
                              title: Text(friend['fullName']),
                              trailing: Checkbox(
                                value: selected,
                                activeColor: const Color(0xFF935CCC),
                                onChanged: (_) => _toggle(id),
                              ),
                              onTap: () => _toggle(id),
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
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
