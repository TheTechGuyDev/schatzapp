// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';

final Map<String, String?> _txAvatarCache = {};

class TransactionLeadIcon extends StatefulWidget {
  const TransactionLeadIcon({
    super.key,
    this.width,
    this.height,
    required this.type,
    this.metadata,
  });

  final double? width;
  final double? height;
  final String type;
  final dynamic metadata;

  @override
  State<TransactionLeadIcon> createState() => _TransactionLeadIconState();
}

class _TransactionLeadIconState extends State<TransactionLeadIcon> {
  String? _imageUrl;
  bool _isLogo = false;

  Map<String, dynamic> get _meta {
    final m = widget.metadata;
    if (m is Map) return Map<String, dynamic>.from(m);
    if (m is String && m.isNotEmpty) {
      try {
        final d = jsonDecode(m);
        if (d is Map) return Map<String, dynamic>.from(d);
      } catch (_) {}
    }
    return {};
  }

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant TransactionLeadIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type ||
        oldWidget.metadata != widget.metadata) {
      _imageUrl = null;
      _resolve();
    }
  }

  Future<void> _resolve() async {
    final meta = _meta;
    String? url;
    var logo = false;

    try {
      switch (widget.type) {
        case 'send_money_out':
        case 'send_money_in':
          final uid = (widget.type == 'send_money_out'
                  ? meta['recipientUserId']
                  : meta['senderUserId'])
              ?.toString();
          if (uid != null && uid.isNotEmpty) {
            if (_txAvatarCache.containsKey(uid)) {
              url = _txAvatarCache[uid];
            } else {
              final rows = await SupaFlow.client
                  .from('profiles')
                  .select('avatar_url')
                  .eq('id', uid)
                  .limit(1);
              url =
                  rows.isNotEmpty ? rows.first['avatar_url'] as String? : null;
              _txAvatarCache[uid] = url;
            }
          }
          break;
        case 'airtime':
        case 'data':
          logo = true;
          url = meta['logoUrl']?.toString();
          if (url == null || url.isEmpty) {
            final info = jsonDecode(await getBrandInfo(
                'operator', (meta['operatorId'] ?? '').toString()));
            url = info is Map ? info['logoUrl']?.toString() : null;
          }
          break;
        case 'giftcard_purchase':
          logo = true;
          url = meta['logoUrl']?.toString();
          if (url == null || url.isEmpty) {
            final info = jsonDecode(await getBrandInfo(
                'giftcard', (meta['productId'] ?? '').toString()));
            url = info is Map ? info['logoUrl']?.toString() : null;
          }
          break;
        default:
          break;
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _imageUrl = (url != null && url.isNotEmpty) ? url : null;
      _isLogo = logo;
    });
  }

  IconData get _fallbackIcon {
    switch (widget.type) {
      case 'send_money_out':
      case 'send_money_in':
        return Icons.person_rounded;
      case 'airtime':
        return Icons.phone_android_rounded;
      case 'data':
        return Icons.wifi_rounded;
      case 'giftcard_purchase':
      case 'giftcard_received':
        return Icons.card_giftcard_rounded;
      case 'topup':
        return Icons.account_balance_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.width ?? widget.height ?? 48.0;
    final fallback = Center(
      child:
          Icon(_fallbackIcon, size: size * 0.5, color: const Color(0xFF935CCC)),
    );

    Widget content = fallback;
    if (_imageUrl != null) {
      final src = _isLogo ? buildImageProxyUrl(_imageUrl!) : _imageUrl!;
      content = Padding(
        padding: EdgeInsets.all(_isLogo ? size * 0.14 : 0),
        child: ClipOval(
          child: Image.network(
            src,
            fit: _isLogo ? BoxFit.contain : BoxFit.cover,
            width: size,
            height: size,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => fallback,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE3E0EA), width: 1.5),
      ),
      child: ClipOval(child: content),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
