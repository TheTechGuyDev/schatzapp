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

import 'dart:convert';

final Map<String, String> _brandInfoCache = {};

/// kind: 'operator' (airtime / data network) or 'giftcard' (product).
/// Returns JSON text: {"name": ..., "logoUrl": ...}  or "{}" when unknown.
Future<String> getBrandInfo(String kind, String id) async {
  if (id.isEmpty || id == '0') return '{}';
  final key = '$kind:$id';
  final cached = _brandInfoCache[key];
  if (cached != null) return cached;

  try {
    final isGift = kind == 'giftcard';
    final raw = await callReloadly(
      isGift ? 'giftcards' : 'topups',
      isGift ? '/products/$id' : '/operators/$id',
      'GET',
      '',
    );
    final d = jsonDecode(raw);
    if (d is! Map || d.containsKey('error')) return '{}';

    final logos = d['logoUrls'];
    final logo = (logos is List && logos.isNotEmpty) ? logos[0] : null;

    String? name;
    if (isGift) {
      final brand = d['brand'];
      name = (brand is Map ? brand['brandName'] : null) ??
          d['productName']?.toString();
    } else {
      name = d['name']?.toString();
    }

    final out = jsonEncode({'name': name, 'logoUrl': logo});
    _brandInfoCache[key] = out;
    return out;
  } catch (_) {
    return '{}';
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
