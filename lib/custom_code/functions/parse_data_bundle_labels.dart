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

List<String> parseDataBundleLabels(
  String amountsJson,
  String descriptionsJson,
  String currencyCode,
) {
  if (amountsJson.isEmpty) {
    return [];
  }
  final decodedAmounts = jsonDecode(amountsJson);
  if (decodedAmounts is! List) {
    return [];
  }
  Map<String, dynamic> descMap = {};
  if (descriptionsJson.isNotEmpty) {
    final decodedDesc = jsonDecode(descriptionsJson);
    if (decodedDesc is Map) {
      descMap = decodedDesc.cast<String, dynamic>();
    }
  }
  return decodedAmounts.map((a) {
    final amountValue = (a as num).toDouble();
    final lookupKey = amountValue.toStringAsFixed(2);
    final priceLabel = '$currencyCode${a.toString()}';
    final desc = descMap[lookupKey];
    if (desc != null && desc.toString().trim().isNotEmpty) {
      return '$priceLabel - ${desc.toString()}';
    }
    return priceLabel;
  }).toList();
}
