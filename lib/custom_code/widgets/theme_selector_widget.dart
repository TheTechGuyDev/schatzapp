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

import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;

class _ThemeBundle {
  const _ThemeBundle({
    required this.senderColor,
    required this.receiverColor,
    required this.wallpaperUrl,
  });
  final Color senderColor;
  final Color receiverColor;
  final String wallpaperUrl;
}

class ThemeSelectorWidget extends StatefulWidget {
  const ThemeSelectorWidget({
    super.key,
    this.width,
    this.height,
    required this.conversationId,
    required this.currentUserId,
  });

  final double? width;
  final double? height;
  final String conversationId;
  final String currentUserId;

  @override
  State<ThemeSelectorWidget> createState() => _ThemeSelectorWidgetState();
}

class _ThemeSelectorWidgetState extends State<ThemeSelectorWidget> {
  static const List<String> _themeKeys = [
    'theme1',
    'theme2',
    'theme3',
    'theme4',
    'theme5',
  ];

  static const Map<String, _ThemeBundle> _themeBundles = {
    'theme1': _ThemeBundle(
      senderColor: Color(0xFFED50E4),
      receiverColor: Color(0xFFF1F5F9),
      wallpaperUrl:
          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/nexu-xidy5i/assets/hs3ncoawy90q/schatzapp_wallpaper..png',
    ),
    'theme2': _ThemeBundle(
      senderColor: Color(0xFFED50E4),
      receiverColor: Color(0xFFF1F5F9),
      wallpaperUrl:
          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/nexu-xidy5i/assets/okzb2earxxuk/.4.png',
    ),
    'theme3': _ThemeBundle(
      senderColor: Color(0xFF3B82F6),
      receiverColor: Color(0xFFFFFFFF),
      wallpaperUrl:
          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/nexu-xidy5i/assets/pt8bmcae9po5/schatzapp_wallpaper.3.png',
    ),
    'theme4': _ThemeBundle(
      senderColor: Color(0xFF0E8BAB),
      receiverColor: Color(0xFFE2E8F0),
      wallpaperUrl:
          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/nexu-xidy5i/assets/f3oes5poj8fa/schatzapp_wallpaper.2.png',
    ),
    'theme5': _ThemeBundle(
      senderColor: Color(0xFF935CCC),
      receiverColor: Color(0xFFF0F0F0),
      wallpaperUrl:
          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/nexu-xidy5i/assets/f62pmt3pghhs/schatzapp_wallpaper.png',
    ),
  };

  String? _selectedTheme;
  String? _wallpaperUrl;
  bool _loading = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
    _loadSelection();
  }

  void _showToast(String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 110,
        left: 40,
        right: 40,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 1400), () {
      entry.remove();
    });
  }

  Future<void> _loadSelection() async {
    final row = await SupaFlow.client
        .from('conversation_participants')
        .select('chat_theme, chat_wallpaper_url')
        .eq('conversation_id', widget.conversationId)
        .eq('user_id', widget.currentUserId)
        .maybeSingle();

    if (!mounted) return;
    setState(() {
      _selectedTheme = row?['chat_theme'] as String?;
      _wallpaperUrl = row?['chat_wallpaper_url'] as String?;
      _loading = false;
    });
  }

  Future<void> _selectTheme(String themeKey) async {
    setState(() {
      _selectedTheme = themeKey;
      _wallpaperUrl = null;
    });
    await SupaFlow.client
        .from('conversation_participants')
        .update({'chat_theme': themeKey, 'chat_wallpaper_url': null})
        .eq('conversation_id', widget.conversationId)
        .eq('user_id', widget.currentUserId);

    if (!mounted) return;
    _showToast('Background changed');
  }

  Future<void> _pickCustomPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _uploading = true);

    try {
      final rawBytes = await pickedFile.readAsBytes();
      final compressedBytes = await FlutterImageCompress.compressWithList(
        rawBytes,
        minWidth: 600,
        minHeight: 900,
        quality: 82,
        format: CompressFormat.jpeg,
      );

      final fileName =
          '${widget.currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'wallpapers/${widget.conversationId}/$fileName';

      await SupaFlow.client.storage.from('chat-themes').uploadBinary(
            path,
            compressedBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final url =
          SupaFlow.client.storage.from('chat-themes').getPublicUrl(path);

      await SupaFlow.client
          .from('conversation_participants')
          .update({'chat_wallpaper_url': url})
          .eq('conversation_id', widget.conversationId)
          .eq('user_id', widget.currentUserId);

      if (!mounted) return;
      setState(() {
        _wallpaperUrl = url;
        _uploading = false;
      });
      _showToast('Background changed');
    } catch (e) {
      debugPrint('Wallpaper upload failed: $e');
      if (!mounted) return;
      setState(() => _uploading = false);
    }
  }

  Widget _themeTile(String themeKey) {
    final bundle = _themeBundles[themeKey]!;
    final isSelected = _selectedTheme == themeKey ||
        (_selectedTheme == null && themeKey == 'theme5');

    return Expanded(
      child: GestureDetector(
        onTap: () => _selectTheme(themeKey),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 110,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(bundle.wallpaperUrl),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: isSelected ? bundle.senderColor : Colors.transparent,
                    width: 2,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 18,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: bundle.senderColor,
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 32,
                        height: 18,
                        decoration: BoxDecoration(
                          color: bundle.receiverColor,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: Colors.black12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -6,
                left: -6,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? bundle.senderColor : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? bundle.senderColor
                          : const Color(0xFFCBC5D6),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isSelected
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: widget.width,
      height: widget.height ?? 400,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(14),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Themes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.secondaryText,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: _themeKeys.map((key) => _themeTile(key)).toList(),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: _uploading ? null : _pickCustomPhoto,
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: theme.alternate, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.photo_library_outlined,
                                color: theme.primaryText, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              _uploading
                                  ? 'Uploading...'
                                  : _wallpaperUrl != null
                                      ? 'Change Background Photo'
                                      : 'Choose from Photo',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: theme.primaryText,
                              ),
                            ),
                          ],
                        ),
                        if (_uploading)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else if (_wallpaperUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(_wallpaperUrl!,
                                width: 32, height: 32, fit: BoxFit.cover),
                          )
                        else
                          Icon(Icons.keyboard_arrow_right,
                              color: theme.secondaryText, size: 22),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Each theme sets your bubble colors and background together. Choose a photo to use your own background instead.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: theme.secondaryText),
                ),
              ],
            ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
