// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class _PresenceObserver with WidgetsBindingObserver {
  _PresenceObserver._();
  static final _PresenceObserver instance = _PresenceObserver._();

  String? _userId;
  bool _attached = false;

  void attach(String userId) {
    _userId = userId;
    if (!_attached) {
      WidgetsBinding.instance.addObserver(this);
      _attached = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final id = _userId;
    if (id == null) return;
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.paused) {
      _push(id);
    }
  }

  Future<void> _push(String userId) async {
    try {
      final privacyRows = await SupaFlow.client
          .from('privacy_settings')
          .select('last_seen_visibility')
          .eq('user_id', userId)
          .limit(1);

      final hidden = privacyRows.isNotEmpty &&
          privacyRows.first['last_seen_visibility'] == 'nobody';
      if (hidden) return;

      await SupaFlow.client.from('profiles').update({
        'is_online': true,
        'last_seen_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', userId);
    } catch (_) {}
  }
}

Future<void> setUserOnline(String userId) async {
  _PresenceObserver.instance.attach(userId);
  await _PresenceObserver.instance._push(userId);
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
