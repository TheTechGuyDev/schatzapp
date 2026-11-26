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
import 'package:flutter/foundation.dart' show kIsWeb;
import '/custom_code/actions/index.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;

class WriteStoryComposer extends StatefulWidget {
  const WriteStoryComposer({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
    required this.onClose,
    required this.onPosted,
    required this.onPhotoTap,
    required this.onWebImagesPicked,
  });

  final double? width;
  final double? height;
  final String currentUserId;
  final Future Function() onClose;
  final Future Function() onPosted;
  final Future Function() onPhotoTap;
  final Future Function() onWebImagesPicked;

  @override
  State<WriteStoryComposer> createState() => _WriteStoryComposerState();
}

class _WriteStoryComposerState extends State<WriteStoryComposer> {
  String _selectedTab = 'text';
  final TextEditingController _textController = TextEditingController();
  bool _posting = false;

  static const List<List<Color>> _bgGradients = [
    [Color(0xFFA1C4FD), Color(0xFFC2E9FB)],
    [Color(0xFFFBC2EB), Color(0xFFA6C1EE)],
    [Color(0xFFFDCBF1), Color(0xFFE6DEE9)],
    [Color(0xFFD4FC79), Color(0xFF96E6A1)],
    [Color(0xFFFFECD2), Color(0xFFFCB69F)],
    [Color(0xFF84FAB0), Color(0xFF8FD3F4)],
    [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
    [Color(0xFFFFDEE9), Color(0xFFB5FFFC)],
    [Color(0xFFF6D365), Color(0xFFFDA085)],
    [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
  ];

  static const List<String> _fontLabels = [
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Poppins',
    'Dancing Script',
    'Great Vibes',
    'Pacifico',
    'Sacramento',
    'Satisfy',
  ];

  int _bgGradientIndex = 0;
  int _fontIndex = 0;

  bool _friendsLoading = false;
  List<Map<String, dynamic>> _friends = [];
  Set<String> _taggedFriendIds = {};

  TextStyle _fontStyle(int index,
      {required double size, required Color color}) {
    switch (index) {
      case 0:
        return GoogleFonts.roboto(
            fontSize: size, color: color, fontWeight: FontWeight.bold);
      case 1:
        return GoogleFonts.openSans(
            fontSize: size, color: color, fontWeight: FontWeight.bold);
      case 2:
        return GoogleFonts.lato(
            fontSize: size, color: color, fontWeight: FontWeight.bold);
      case 3:
        return GoogleFonts.montserrat(
            fontSize: size, color: color, fontWeight: FontWeight.bold);
      case 4:
        return GoogleFonts.poppins(
            fontSize: size, color: color, fontWeight: FontWeight.w300);
      case 5:
        return GoogleFonts.dancingScript(
            fontSize: size, color: color, fontWeight: FontWeight.bold);
      case 6:
        return GoogleFonts.greatVibes(fontSize: size, color: color);
      case 7:
        return GoogleFonts.pacifico(fontSize: size, color: color);
      case 8:
        return GoogleFonts.sacramento(fontSize: size, color: color);
      case 9:
        return GoogleFonts.satisfy(fontSize: size, color: color);
      default:
        return GoogleFonts.roboto(
            fontSize: size, color: color, fontWeight: FontWeight.bold);
    }
  }

  String _gradientToHex(List<Color> gradient) {
    final first = '#${gradient.first.value.toRadixString(16).substring(2)}';
    final second = '#${gradient.last.value.toRadixString(16).substring(2)}';
    return '$first,$second';
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _cycleGradient() {
    setState(() {
      _bgGradientIndex = (_bgGradientIndex + 1) % _bgGradients.length;
    });
  }

  void _showFontPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: _fontLabels.length,
          itemBuilder: (context, i) {
            return ListTile(
              onTap: () {
                setState(() => _fontIndex = i);
                Navigator.pop(context);
              },
              title: Text(
                _fontLabels[i],
                style: _fontStyle(i, size: 20, color: Colors.white),
              ),
              trailing: i == _fontIndex
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
            );
          },
        );
      },
    );
  }

  Future<void> _showTagFriendsSheet() async {
    if (_friends.isEmpty) {
      setState(() => _friendsLoading = true);
      try {
        final rows = await SupaFlow.client
            .from('contacts')
            .select(
                'contact_user_id, profiles!contacts_contact_user_id_fkey(full_name, avatar_url)')
            .eq('owner_id', widget.currentUserId)
            .not('contact_user_id', 'is', null);

        _friends = rows
            .where((row) => row['profiles'] != null)
            .map((row) => {
                  'id': row['contact_user_id'] as String,
                  'fullName': (row['profiles']['full_name'] as String?) ?? '',
                  'avatarUrl': (row['profiles']['avatar_url'] as String?) ?? '',
                })
            .toList();
      } catch (_) {
        _friends = [];
      }
      if (!mounted) return;
      setState(() => _friendsLoading = false);
    }

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _friends
                .where((f) => (f['fullName'] as String)
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
                .toList();

            return Container(
              height: MediaQuery.sizeOf(context).height * 0.7,
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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        onChanged: (value) =>
                            setModalState(() => searchQuery = value),
                        decoration: const InputDecoration(
                          hintText: 'Search viewer...',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _friendsLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filtered.isEmpty
                            ? const Center(child: Text('No friends found'))
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                itemCount: filtered.length,
                                itemBuilder: (context, i) {
                                  final friend = filtered[i];
                                  final selected =
                                      _taggedFriendIds.contains(friend['id']);
                                  return ListTile(
                                    leading: CircleAvatar(
                                      radius: 22,
                                      backgroundImage: (friend['avatarUrl']
                                                  as String)
                                              .isNotEmpty
                                          ? cachedNetworkImageProvider(friend['avatarUrl'])
                                          : null,
                                    ),
                                    title: Text(friend['fullName']),
                                    trailing: selected
                                        ? const Icon(Icons.check_circle,
                                            color: Color(0xFF935CCC))
                                        : const Icon(Icons.circle_outlined,
                                            color: Colors.black26),
                                    onTap: () {
                                      setModalState(() {
                                        if (selected) {
                                          _taggedFriendIds.remove(friend['id']);
                                        } else {
                                          _taggedFriendIds.add(friend['id']);
                                        }
                                      });
                                      setState(() {});
                                    },
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _postTextStory() async {
    if (_textController.text.trim().isEmpty || _posting) return;
    setState(() {
      _posting = true;
    });

    try {
      final storySettings =
          await getOrCreateStorySettings(widget.currentUserId);
      await postStory(
        widget.currentUserId,
        '',
        'text',
        _textController.text.trim(),
        _gradientToHex(_bgGradients[_bgGradientIndex]),
        _taggedFriendIds.toList(),
        _fontIndex,
        storySettings.durationHours ?? 24,
        '',
      );

      final refreshed = await getMyStories(widget.currentUserId);
      FFAppState().myStoryGroup = refreshed;

      if (!mounted) return;
      widget.onPosted();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t post: $e')),
      );
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  Future<void> _showImagePicker() async {
    if (kIsWeb) {
      setState(() => _posting = true);
      try {
        final picked = await pickMultipleWebStoryImages();
        if (picked.isEmpty) {
          if (mounted) setState(() => _posting = false);
          return;
        }
        FFAppState().pendingWebStoryImages = picked;
        FFAppState().pendingStoryTaggedUserIds = _taggedFriendIds.toList();
        await widget.onWebImagesPicked();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Couldn\'t pick images: $e')),
        );
      } finally {
        if (mounted) setState(() => _posting = false);
      }
      return;
    }

    FFAppState().pendingStoryTaggedUserIds = _taggedFriendIds.toList();
    await widget.onPhotoTap();
  }

  Future<void> _postVoiceStory(String filePath, int durationSeconds) async {
    setState(() {
      _posting = true;
      _selectedTab = 'text';
    });

    try {
      final url = await uploadVoiceNote(filePath);
      if (url == null) {
        throw Exception('Upload failed');
      }

      final storySettings =
          await getOrCreateStorySettings(widget.currentUserId);
      await postStory(
        widget.currentUserId,
        url,
        'voice',
        '',
        '',
        _taggedFriendIds.toList(),
        0,
        storySettings.durationHours ?? 24,
        '',
      );

      final refreshed = await getMyStories(widget.currentUserId);
      FFAppState().myStoryGroup = refreshed;

      if (!mounted) return;
      widget.onPosted();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t post: $e')),
      );
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedTab == 'camera') {
      return custom_widgets.LiveCameraCapture(
        width: widget.width,
        height: widget.height,
        currentUserId: widget.currentUserId,
        taggedUserIds: _taggedFriendIds.toList(),
        onClose: () async {
          setState(() => _selectedTab = 'text');
        },
        onPosted: widget.onPosted,
      );
    }

    final showPostButton =
        _selectedTab == 'text' && _textController.text.trim().isNotEmpty;
    const textColor = Color(0xFF2D2D2D);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _bgGradients[_bgGradientIndex],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _pillIconButton(
                      icon: Icons.close,
                      onTap: () => widget.onClose(),
                    ),
                    Row(
                      children: [
                        _pillIconButton(label: 'Aa', onTap: _showFontPicker),
                        const SizedBox(width: 8),
                        _pillIconButton(
                            icon: Icons.palette_outlined,
                            onTap: _cycleGradient),
                        const SizedBox(width: 8),
                        _pillIconButton(
                          icon: Icons.people_outline,
                          trailingIcon: Icons.keyboard_arrow_down,
                          onTap: _showTagFriendsSheet,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _posting
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _selectedTab == 'voice'
                        ? Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: custom_widgets.VoiceRecorderBar(
                                  width: double.infinity,
                                  height: 64,
                                  onCancel: () async {
                                    setState(() => _selectedTab = 'text');
                                  },
                                  onSend: _postVoiceStory,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: TextField(
                                controller: _textController,
                                maxLines: null,
                                textAlign: TextAlign.center,
                                style: _fontStyle(_fontIndex,
                                    size: 26, color: textColor),
                                decoration: InputDecoration(
                                  hintText: 'Share a thought...',
                                  hintStyle: _fontStyle(_fontIndex,
                                      size: 26,
                                      color: textColor.withOpacity(0.55)),
                                  border: InputBorder.none,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ),
              ),
              if (showPostButton)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: InkWell(
                    onTap: _posting ? null : _postTextStory,
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: _posting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: textColor),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Post story',
                                    style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward,
                                    color: textColor, size: 18),
                              ],
                            ),
                    ),
                  ),
                ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _tabButton(Icons.text_fields, 'Aa', 'TEXT', 'text'),
                    _tabButton(Icons.mic_none, null, 'VOICE', 'voice'),
                    _tabButton(Icons.image_outlined, null, 'IMAGE', 'photo'),
                    _tabButton(
                        Icons.camera_alt_outlined, null, 'CAMERA', 'camera'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pillIconButton({
    IconData? icon,
    IconData? trailingIcon,
    String? label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 40,
        padding:
            EdgeInsets.symmetric(horizontal: trailingIcon != null ? 12 : 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(icon, color: const Color(0xFF2D2D2D), size: 18),
            if (label != null)
              Text(label,
                  style: const TextStyle(
                      color: Color(0xFF2D2D2D), fontWeight: FontWeight.bold)),
            if (trailingIcon != null)
              Icon(trailingIcon, color: const Color(0xFF2D2D2D), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(
      IconData icon, String? aaLabel, String label, String value) {
    final selected = _selectedTab == value;
    return InkWell(
      onTap: () {
        setState(() => _selectedTab = value);
        if (value == 'photo') _showImagePicker();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            aaLabel != null
                ? Text(aaLabel,
                    style: const TextStyle(
                        color: Color(0xFF2D2D2D), fontWeight: FontWeight.bold))
                : Icon(icon, color: const Color(0xFF2D2D2D), size: 20),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF2D2D2D),
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
