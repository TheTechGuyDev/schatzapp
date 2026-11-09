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

String currencyForCountryCode(String isoCode) {
  const Map<String, String> currencyMap = {
    'NG': 'NGN',
    'GH': 'GHS',
    'KE': 'KES',
    'ZA': 'ZAR',
    'US': 'USD',
    'CA': 'CAD',
    'GB': 'GBP',
    'AU': 'AUD',
    'IN': 'INR',
    'AE': 'AED',
    'SA': 'SAR',
    'EG': 'EGP',
    'MA': 'MAD',
    'KW': 'KWD',
    'QA': 'QAR',
    'BR': 'BRL',
    'MX': 'MXN',
    'JP': 'JPY',
    'CN': 'CNY',
    'SG': 'SGD',
    'HK': 'HKD',
    'CH': 'CHF',
    'SE': 'SEK',
    'NO': 'NOK',
    'DK': 'DKK',
    'PL': 'PLN',
    'TR': 'TRY',
    'PK': 'PKR',
    'BD': 'BDT',
    'PH': 'PHP',
    'ID': 'IDR',
    'MY': 'MYR',
    'TH': 'THB',
    'VN': 'VND',
    'NZ': 'NZD',
    'DE': 'EUR',
    'FR': 'EUR',
    'IT': 'EUR',
    'ES': 'EUR',
    'PT': 'EUR',
    'NL': 'EUR',
    'BE': 'EUR',
    'IE': 'EUR',
    'AT': 'EUR',
    'FI': 'EUR',
    'GR': 'EUR',
    'LU': 'EUR',
  };

  return currencyMap[isoCode.toUpperCase()] ?? 'USD';
}
