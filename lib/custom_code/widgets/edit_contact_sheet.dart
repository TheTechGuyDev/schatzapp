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

class EditContactSheet extends StatefulWidget {
  const EditContactSheet({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
    required this.otherUserId,
  });

  final double? width;
  final double? height;
  final String currentUserId;
  final String otherUserId;

  @override
  State<EditContactSheet> createState() => _EditContactSheetState();
}

class _EditContactSheetState extends State<EditContactSheet> {
  static const Color _purple = Color(0xFF935CCC);

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _contactRowId;
  String _origPhone = '';
  String _username = '';
  bool _showPhone = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String _key(String phone) {
    final d = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return d.length > 10 ? d.substring(d.length - 10) : d;
  }

  Future<void> _load() async {
    try {
      final rows = await SupaFlow.client
          .from('contacts')
          .select('id, saved_name, phone_number')
          .eq('owner_id', widget.currentUserId)
          .eq('contact_user_id', widget.otherUserId)
          .limit(1);
      final prof = await SupaFlow.client
          .from('profiles')
          .select('full_name, username')
          .eq('id', widget.otherUserId)
          .limit(1);
      if (prof.isNotEmpty) {
        _username = ((prof.first['username'] as String?) ?? '').trim();
      }
      if (rows.isNotEmpty) {
        _contactRowId = rows.first['id'] as String?;
        _nameCtrl.text = ((rows.first['saved_name'] as String?) ?? '').trim();
        _origPhone = ((rows.first['phone_number'] as String?) ?? '').trim();
        _phoneCtrl.text = _origPhone;
      } else if (prof.isNotEmpty) {
        _nameCtrl.text = ((prof.first['full_name'] as String?) ?? '').trim();
      }
      // Contacts saved by username only: show the username, not a number.
      _showPhone = _origPhone.isNotEmpty || _username.isEmpty;
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _toast(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _save() async {
    if (_saving) return;
    final name = _nameCtrl.text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty) {
      _toast('Enter a name');
      return;
    }
    if (_showPhone && phone.isNotEmpty && _key(phone).length < 7) {
      _toast('Enter a valid phone number');
      return;
    }
    setState(() => _saving = true);
    try {
      // The number must not already belong to another saved contact.
      if (_showPhone && phone.isNotEmpty && _key(phone) != _key(_origPhone)) {
        final taken = await SupaFlow.client
            .from('contacts')
            .select('id, saved_name')
            .eq('owner_id', widget.currentUserId)
            .ilike('phone_number', '%${_key(phone)}')
            .limit(1);
        if (taken.isNotEmpty && taken.first['id'] != _contactRowId) {
          _toast(
              'This number is already saved as ${taken.first['saved_name']}');
          setState(() => _saving = false);
          return;
        }
      }
      // Only the current user's own contact entry is changed. The other
      // person's profile is never touched.
      final data = <String, dynamic>{'saved_name': name};
      if (_showPhone) data['phone_number'] = phone.isEmpty ? null : phone;
      if (_contactRowId != null) {
        await SupaFlow.client
            .from('contacts')
            .update(data)
            .eq('id', _contactRowId!)
            .eq('owner_id', widget.currentUserId);
      } else {
        await SupaFlow.client.from('contacts').insert({
          'owner_id': widget.currentUserId,
          'contact_user_id': widget.otherUserId,
          ...data,
        });
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _toast('Could not save. Please try again.');
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _dec(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      );

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 14),
        child: Text(t,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w600)),
      );

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      // The bottom sheet already lifts itself above the keyboard, so no
      // extra keyboard padding here (it was applied twice and left no room
      // for the content, which made the sheet go blank).
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Edit contact',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 19, fontWeight: FontWeight.w700)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                  _label('Name'),
                  TextField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: _dec('Contact name', Icons.person_outline),
                  ),
                  if (_showPhone) ...[
                    _label('Phone number'),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: _dec('Phone number', Icons.phone_outlined),
                    ),
                  ] else ...[
                    _label('Username'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.alternate_email,
                              size: 20, color: Colors.grey.shade600),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(_username,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                          ),
                          Icon(Icons.lock_outline,
                              size: 18, color: Colors.grey.shade600),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('Only the owner can change their username.',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                    ),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text('Save',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
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
