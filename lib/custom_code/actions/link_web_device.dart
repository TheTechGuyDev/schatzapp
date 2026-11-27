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

import '/flutter_flow/nav/nav.dart';

// Calls the web-login Edge Function and returns {ok, code, message, ...}.
Future<Map<String, dynamic>> _callWebLogin(String action, String qr) async {
  try {
    final response = await SupaFlow.client.functions.invoke(
      'web-login',
      method: HttpMethod.post,
      body: {'action': action, 'qr': qr},
    );
    final data = response.data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'ok': false, 'message': 'Unexpected response. Please try again.'};
  } on FunctionException catch (e) {
    final details = e.details;
    if (details is Map) return Map<String, dynamic>.from(details);
    return {
      'ok': false,
      'message': 'Could not link this device. Please try again.'
    };
  } catch (_) {
    return {
      'ok': false,
      'message': 'No internet connection. Please try again.'
    };
  }
}

void _toast(String text) {
  final ctx = appNavigatorKey.currentContext;
  if (ctx == null) return;
  ScaffoldMessenger.maybeOf(ctx)?.showSnackBar(SnackBar(content: Text(text)));
}

String _formatTime(dynamic iso) {
  final t = DateTime.tryParse('${iso ?? ''}')?.toLocal();
  if (t == null) return '';
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final m = t.minute.toString().padLeft(2, '0');
  final ap = t.hour >= 12 ? 'PM' : 'AM';
  return '$h:$m $ap';
}

// Scanned QR text -> device details -> Link / Cancel. Returns true when the
// web browser was approved.
Future<bool> linkWebDevice(String qr) async {
  final code = qr.trim();
  if (code.isEmpty) return false;
  if (!code.startsWith('schatzapp://link-device')) {
    _toast('This is not a SchatzApp QR code.');
    return false;
  }

  final info = await _callWebLogin('inspect', code);
  if (info['ok'] != true) {
    _toast('${info['message'] ?? 'Could not read this QR code.'}');
    return false;
  }

  final ctx = appNavigatorKey.currentContext;
  if (ctx == null) return false;

  final device = '${info['device_name'] ?? 'Unknown device'}';
  final location = '${info['location'] ?? ''}';
  final time = _formatTime(info['requested_at']);
  final active = info['active_devices'] ?? 0;
  final max = info['max_devices'] ?? 7;

  final approve = await showDialog<bool>(
    context: ctx,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Link this device?',
          style: TextStyle(fontWeight: FontWeight.w600)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(device,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Location: $location'),
          ],
          if (time.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Requested at $time'),
          ],
          const SizedBox(height: 4),
          Text('Linked devices: $active of $max'),
          const SizedBox(height: 12),
          const Text(
            'Only link a device that you are using right now. This device will be able to see your chats and wallet.',
            style: TextStyle(fontSize: 13, color: Color(0xFF667781)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child:
              const Text('Cancel', style: TextStyle(color: Color(0xFF667781))),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Link device',
              style: TextStyle(
                  color: Color(0xFF935CCC), fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );

  if (approve == true) {
    final res = await _callWebLogin('approve', code);
    if (res['ok'] == true) {
      _toast('Device linked. Signing you in on the computer.');
      return true;
    }
    _toast('${res['message'] ?? 'Could not link this device.'}');
    return false;
  }

  await _callWebLogin('reject', code);
  _toast('Link request declined.');
  return false;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
