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

class ProfileLinksList extends StatefulWidget {
  const ProfileLinksList({
    super.key,
    this.width,
    this.height,
    required this.userId,
  });

  final double? width;
  final double? height;
  final String userId;

  @override
  State<ProfileLinksList> createState() => _ProfileLinksListState();
}

class _ProfileLinksListState extends State<ProfileLinksList> {
  static const Color _purple = Color(0xFF935CCC);
  List<Map<String, dynamic>> _links = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ProfileLinksList old) {
    super.didUpdateWidget(old);
    if (old.userId != widget.userId) _load();
  }

  Future<void> _load() async {
    if (widget.userId.isEmpty) return;
    try {
      final res = await SupaFlow.client
          .rpc('get_user_links', params: {'p_user': widget.userId});
      if (!mounted) return;
      setState(() => _links = (res as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_links.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text('Links',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF8A8A8A))),
          ),
          ..._links.take(3).map((l) {
            final title = (l['title'] ?? '').toString();
            final url = (l['url'] ?? '').toString();
            return InkWell(
              onTap: () => launchURL(url),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                          color: Color(0xFFEFEBF2), shape: BoxShape.circle),
                      child: const Icon(Icons.link, color: _purple, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          Text(url,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: _purple, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          Divider(
              thickness: 1.0, color: FlutterFlowTheme.of(context).alternate),
        ],
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
