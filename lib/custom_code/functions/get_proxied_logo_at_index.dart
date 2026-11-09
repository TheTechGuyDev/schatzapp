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

String getProxiedLogoAtIndex(
  List<String> items,
  int index,
) {
  if (index < 0 || index >= items.length) {
    return '';
  }
  final rawUrl = items[index];
  if (rawUrl.isEmpty) {
    return '';
  }
  final encoded = Uri.encodeComponent(rawUrl);
  return 'https://hkcykdxiinvmepxebdsm.supabase.co/functions/v1/image-proxy?url=$encoded';
}
