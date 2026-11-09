import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '/flutter_flow/custom_functions.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/uploaded_file.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/backend/supabase/supabase.dart';
import '/auth/supabase_auth/auth_util.dart';

List<int> filterIndicesByQuery(
  List<String> items,
  String query,
) {
  final lowerQuery = query.trim().toLowerCase();
  if (lowerQuery.isEmpty) {
    return List<int>.generate(items.length, (i) => i);
  }
  final result = <int>[];
  for (var i = 0; i < items.length; i++) {
    if (items[i].toLowerCase().contains(lowerQuery)) {
      result.add(i);
    }
  }
  return result;
}
