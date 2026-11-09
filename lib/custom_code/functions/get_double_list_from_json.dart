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

List<double> getDoubleListFromJson(
  String response,
  String jsonPath,
) {
  if (response.isEmpty) {
    return [];
  }
  final data = jsonDecode(response);
  if (data is! Map) {
    return [];
  }
  final key = jsonPath.replaceFirst('\$.', '');
  final value = data[key];
  if (value is! List) {
    return [];
  }
  return value.map((v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }).toList();
}
