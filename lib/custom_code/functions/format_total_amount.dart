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

String formatTotalAmount(
  String currencyCode,
  double amount,
  int quantity,
) {
  final total = amount * quantity;
  final formattedTotal = total == total.roundToDouble()
      ? total.toInt().toString()
      : total.toStringAsFixed(2);
  return '$currencyCode $formattedTotal';
}
