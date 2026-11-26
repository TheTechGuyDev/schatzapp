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

class ProfilePhotoEditor extends StatefulWidget {
  const ProfilePhotoEditor({
    super.key,
    this.width,
    this.height,
    required this.userId,
    this.avatarUrl,
  });

  final double? width;
  final double? height;
  final String userId;
  final String? avatarUrl;

  @override
  State<ProfilePhotoEditor> createState() => _ProfilePhotoEditorState();
}

class _ProfilePhotoEditorState extends State<ProfilePhotoEditor> {
  static const Color _purple = Color(0xFF935CCC);
  static const Color _soft = Color(0xFFEFEBF2);

  String _url = '';
  bool _busy = false;

  bool get _hasPhoto => _url.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _url = _clean(widget.avatarUrl);
  }

  @override
  void didUpdateWidget(covariant ProfilePhotoEditor old) {
    super.didUpdateWidget(old);
    if (old.avatarUrl != widget.avatarUrl && !_busy) {
      setState(() => _url = _clean(widget.avatarUrl));
    }
  }

  String _clean(String? v) {
    final s = (v ?? '').trim();
    return (s.isEmpty || s == 'null') ? '' : s;
  }

  void _toast(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _change() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final picked = await pickAndUploadGroupAvatar();
      if (picked != null && picked.isNotEmpty) {
        await SupaFlow.client
            .from('profiles')
            .update({'avatar_url': picked}).eq('id', widget.userId);
        if (mounted) setState(() => _url = picked);
      }
    } catch (_) {
      _toast('Could not update your photo, please try again');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await SupaFlow.client
          .from('profiles')
          .update({'avatar_url': null}).eq('id', widget.userId);
      if (mounted) setState(() => _url = '');
    } catch (_) {
      _toast('Could not remove your photo, please try again');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: _purple),
              title: const Text('Change Profile Image'),
              onTap: () {
                Navigator.pop(sheetContext);
                _change();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Profile Image',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(sheetContext);
                _delete();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double size = 125;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Center(
        child: SizedBox(
          width: size + 20,
          height: size + 20,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: _soft,
                    shape: BoxShape.circle,
                    image: _hasPhoto
                        ? DecorationImage(
                            fit: BoxFit.cover, image: cachedNetworkImageProvider(_url))
                        : null,
                  ),
                  child: _hasPhoto
                      ? null
                      : const Icon(Icons.person_outline_rounded,
                          size: 64, color: _purple),
                ),
              ),
              InkWell(
                onTap: _busy ? null : (_hasPhoto ? _openMenu : _change),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: _purple,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: _busy
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(
                          _hasPhoto
                              ? Icons.edit_outlined
                              : Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
