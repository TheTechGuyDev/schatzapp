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

class HideFromPicker extends StatefulWidget {
  const HideFromPicker({
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
  State<HideFromPicker> createState() => _HideFromPickerState();
}

class _HideFromPickerState extends State<HideFromPicker> {
  bool _loading = true;
  List<Map<String, dynamic>> _friends = [];
  Set<String> _hiddenIds = {};
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

    final hiddenList = await getHiddenFromList(widget.currentUserId);

    if (!mounted) return;
    setState(() {
      _friends = friends;
      _hiddenIds = hiddenList.map((h) => h.id).toSet();
      _loading = false;
    });
  }

  Future<void> _toggle(String friendId) async {
    final isHidden = _hiddenIds.contains(friendId);
    setState(() {
      if (isHidden) {
        _hiddenIds.remove(friendId);
      } else {
        _hiddenIds.add(friendId);
      }
    });

    if (isHidden) {
      await unhideStatusFrom(widget.currentUserId, friendId);
    } else {
      await hideStatusFrom(widget.currentUserId, friendId);
    }

    final refreshed = await getHiddenFromList(widget.currentUserId);
    FFAppState().hiddenList = refreshed;
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
                  const Text('Hide status from',
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
                            final hidden = _hiddenIds.contains(friend['id']);
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 22,
                                backgroundImage:
                                    (friend['avatarUrl'] as String).isNotEmpty
                                        ? cachedNetworkImageProvider(friend['avatarUrl'])
                                        : null,
                              ),
                              title: Text(friend['fullName']),
                              trailing: Switch(
                                value: hidden,
                                activeColor: const Color(0xFF935CCC),
                                onChanged: (_) => _toggle(friend['id']),
                              ),
                              onTap: () => _toggle(friend['id']),
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
