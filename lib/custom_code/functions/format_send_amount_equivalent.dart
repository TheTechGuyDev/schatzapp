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

String formatSendAmountEquivalent(
  double sfzAmount,
  String currencyCode,
  double fxRate,
) {
  final eurAmount = sfzAmount / 100;
  final localAmount = eurAmount * fxRate;
  String symbol;
  switch (currencyCode) {
    case 'NGN':
      symbol = '₦';
      break;
    case 'GHS':
      symbol = '₵';
      break;
    case 'USD':
      symbol = '\$';
      break;
    case 'EUR':
      symbol = '€';
      break;
    default:
      symbol = '$currencyCode ';
  }
  final formatted = localAmount.toStringAsFixed(2);
  return '~$symbol$formatted';
}
