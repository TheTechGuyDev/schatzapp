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

String parseDataPlanField(
  String label,
  String field,
) {
  final parts = label.split(' - ');
  final pricePart = parts.isNotEmpty ? parts[0] : '';
  final desc = parts.length > 1 ? parts.sublist(1).join(' - ') : '';

  final priceMatch = RegExp(r'[\d.]+').firstMatch(pricePart);
  final price = priceMatch != null ? priceMatch.group(0)! : '';

  final sizeMatch =
      RegExp(r'(\d+(\.\d+)?\s?(MB|GB))', caseSensitive: false).firstMatch(desc);
  final size = sizeMatch != null ? sizeMatch.group(0)! : '';

  final validityMatch =
      RegExp(r'(Daily|Weekly|Monthly|\d+\s?-?\s?Day(s)?)', caseSensitive: false)
          .firstMatch(desc);
  final validity = validityMatch != null ? validityMatch.group(0)! : '';

  String extra = '';
  if (desc.toLowerCase().contains('youtube')) {
    final idx = desc.toLowerCase().indexOf('youtube');
    extra = desc.substring(idx);
  }

  switch (field) {
    case 'price':
      return price;
    case 'size':
      return size;
    case 'validity':
      return validity;
    case 'extra':
      return extra;
    default:
      return '';
  }
}
