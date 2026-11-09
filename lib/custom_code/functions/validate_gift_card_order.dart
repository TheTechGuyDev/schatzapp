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

String validateGiftCardOrder(
  String denominationType,
  double selectedAmount,
  double minAmount,
  double maxAmount,
  String recipientEmail,
) {
  if (selectedAmount <= 0) {
    return 'Please select or enter an amount';
  }
  if (denominationType == 'RANGE') {
    if (selectedAmount < minAmount || selectedAmount > maxAmount) {
      return 'Amount must be between the minimum and maximum allowed';
    }
  }
  if (recipientEmail.trim().isEmpty) {
    return 'Please enter a recipient email';
  }
  return '';
}
