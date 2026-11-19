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

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AutoGallerySaver extends StatefulWidget {
  const AutoGallerySaver({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
  });

  final double? width;
  final double? height;
  final String currentUserId;

  @override
  State<AutoGallerySaver> createState() => _AutoGallerySaverState();
}

class _AutoGallerySaverState extends State<AutoGallerySaver> {
  RealtimeChannel? _channel;
  final Set<String> _done = {};

  @override
  void initState() {
    super.initState();
    // Browsers cannot save into a phone gallery.
    if (kIsWeb) return;
    _listen();
  }

  void _listen() {
    try {
      _channel = SupaFlow.client
          .channel('auto-gallery-${widget.currentUserId}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'messages',
            callback: (payload) => _handle(payload.newRecord),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'messages',
            callback: (payload) => _handle(payload.newRecord),
          )
          .subscribe();
    } catch (_) {}
  }

  Future<void> _handle(Map<String, dynamic> m) async {
    try {
      if (m['sender_id']?.toString() == widget.currentUserId) return;
      if (m['is_deleted'] == true) return;
      final type = (m['message_type'] ?? '').toString();
      if (type != 'image' && type != 'image_group' && type != 'video') return;

      final urls = <String>[];
      final single = (m['media_url'] ?? '').toString();
      if (single.startsWith('http')) urls.add(single);
      final many = m['media_urls'];
      if (many is List) {
        for (final u in many) {
          final s = u.toString();
          if (s.startsWith('http') && !urls.contains(s)) urls.add(s);
        }
      }
      if (urls.isEmpty) return;

      final id = (m['id'] ?? '').toString();
      final fresh = urls.where((u) => !_done.contains('$id|$u')).toList();
      if (fresh.isEmpty) return;
      // Claim them now so a second event cannot save the same file twice.
      for (final u in fresh) {
        _done.add('$id|$u');
      }

      // The person's own setting for this chat, and whether they locked it.
      final rows = await SupaFlow.client
          .from('conversation_participants')
          .select('save_to_gallery, private_lock, left_at')
          .eq('conversation_id', m['conversation_id'])
          .eq('user_id', widget.currentUserId)
          .limit(1);
      final list = rows as List;
      if (list.isEmpty) return;
      final p = list.first;
      if (p['left_at'] != null) return;
      if (p['save_to_gallery'] == false) return;
      if (p['private_lock'] == true) return;

      var allowed = await Gal.hasAccess();
      if (!allowed) allowed = await Gal.requestAccess();
      if (!allowed) return;

      for (final url in fresh) {
        await _saveOne(url, isVideo: type == 'video');
      }
    } catch (_) {}
  }

  Future<void> _saveOne(String url, {required bool isVideo}) async {
    File? file;
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200 || res.bodyBytes.isEmpty) return;
      if (res.bodyBytes.length > 150 * 1024 * 1024) return;

      final clean = url.split('?').first.toLowerCase();
      String ext = isVideo ? 'mp4' : 'jpg';
      final dot = clean.lastIndexOf('.');
      if (dot != -1 && clean.length - dot <= 5) {
        ext = clean.substring(dot + 1);
      }
      final dir = await getTemporaryDirectory();
      file = File(
          '${dir.path}/schatz_${DateTime.now().microsecondsSinceEpoch}.$ext');
      await file.writeAsBytes(res.bodyBytes);

      if (isVideo) {
        await Gal.putVideo(file.path);
      } else {
        await Gal.putImage(file.path);
      }
    } catch (_) {
    } finally {
      try {
        await file?.delete();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    final ch = _channel;
    if (ch != null) {
      try {
        SupaFlow.client.removeChannel(ch);
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
