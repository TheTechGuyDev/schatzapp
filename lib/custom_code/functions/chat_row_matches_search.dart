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

bool chatRowMatchesSearch(
  String name,
  String query,
  String filter,
  int unreadCount,
  String type,
  bool isArchived,
) {
  if (filter == 'archived' && !isArchived) return false;
  if (filter != 'archived' && isArchived) return false;
  if (filter == 'unread' && unreadCount == 0) return false;
  if (filter == 'groups' && type != 'group') return false;
  if (query.isEmpty) return true;
  return name.toLowerCase().contains(query.toLowerCase());
}
