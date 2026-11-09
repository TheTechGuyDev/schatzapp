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

import '/auth/supabase_auth/auth_util.dart';
import '/custom_code/actions/index.dart' as actions;
import 'dart:convert';
import 'package:intl/intl.dart';

final Map<String, String> _walletListNameCache = {};

class WalletTransactionsList extends StatefulWidget {
  const WalletTransactionsList({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<WalletTransactionsList> createState() => _WalletTransactionsListState();
}

class _WalletTransactionsListState extends State<WalletTransactionsList> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  bool _failed = false;
  String _filter = 'all';
  // -1 = all time, 0 = this month, 1 = last month, 2 = two months ago, ...
  int _monthOffset = -1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await SupaFlow.client
          .from('wallet_transactions')
          .select(
              'id, reference, type, status, amount, currency, metadata, created_at')
          .eq('user_id', currentUserUid)
          .order('created_at', ascending: false)
          .limit(200);
      if (!mounted) return;
      setState(() {
        _rows = List<Map<String, dynamic>>.from(data as List);
        _loading = false;
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  Map<String, dynamic> _meta(dynamic m) {
    if (m is Map) return Map<String, dynamic>.from(m);
    if (m is String && m.isNotEmpty) {
      try {
        final d = jsonDecode(m);
        if (d is Map) return Map<String, dynamic>.from(d);
      } catch (_) {}
    }
    return {};
  }

  String _label(String t) {
    switch (t) {
      case 'send_money_out':
        return 'Money Sent';
      case 'send_money_in':
        return 'Money Received';
      case 'airtime_purchase':
      case 'airtime':
        return 'Airtime';
      case 'data_purchase':
      case 'data':
        return 'Data';
      case 'giftcard_purchase':
        return 'Gift Card';
      case 'giftcard_received':
        return 'Gift Card Received';
      case 'topup':
        return 'Wallet Top Up';
      default:
        return t.replaceAll('_', ' ');
    }
  }

  bool _matches(String type) {
    switch (_filter) {
      case 'transfers':
        return type == 'send_money_out' || type == 'send_money_in';
      case 'bills':
        return type.startsWith('airtime') ||
            type.startsWith('data') ||
            type.startsWith('giftcard');
      case 'topups':
        return type == 'topup';
      default:
        return true;
    }
  }

  DateTime _monthAt(int offset) {
    final now = DateTime.now();
    return DateTime(now.year, now.month - offset, 1);
  }

  String _monthLabel(int offset) {
    if (offset < 0) return 'All time';
    if (offset == 0) return 'This month';
    if (offset == 1) return 'Last month';
    final m = _monthAt(offset);
    final sameYear = m.year == DateTime.now().year;
    return DateFormat(sameYear ? 'MMMM' : 'MMM yyyy').format(m);
  }

  bool _inMonth(DateTime? created) {
    if (_monthOffset < 0) return true;
    if (created == null) return false;
    final m = _monthAt(_monthOffset);
    return created.year == m.year && created.month == m.month;
  }

  Widget _monthChip(int offset) {
    final on = _monthOffset == offset;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(_monthLabel(offset)),
        selected: on,
        onSelected: (_) => setState(() => _monthOffset = offset),
        selectedColor: FlutterFlowTheme.of(context).primary,
        labelStyle: TextStyle(
          color: on ? Colors.white : const Color(0xFF111827),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _chip(String key, String text) {
    final on = _filter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(text),
        selected: on,
        onSelected: (_) => setState(() => _filter = key),
        selectedColor: FlutterFlowTheme.of(context).primary,
        labelStyle: TextStyle(
          color: on ? Colors.white : const Color(0xFF111827),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        showCheckmark: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_failed) {
      return Center(
        child: TextButton(
          onPressed: () {
            setState(() => _loading = true);
            _load();
          },
          child: const Text('Could not load transactions. Tap to retry'),
        ),
      );
    }
    final shown = _rows.where((r) {
      if (!_matches((r['type'] ?? '').toString())) return false;
      final created =
          DateTime.tryParse((r['created_at'] ?? '').toString())?.toLocal();
      return _inMonth(created);
    }).toList();
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
          child: Row(
            children: [
              _chip('all', 'All'),
              _chip('transfers', 'Transfers'),
              _chip('bills', 'Airtime, Data & Gift Cards'),
              _chip('topups', 'Top Ups'),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
          child: Row(
            children: [
              for (final o in [-1, 0, 1, 2, 3, 4, 5]) _monthChip(o),
            ],
          ),
        ),
        Expanded(
          child: shown.isEmpty
              ? const Center(
                  child: Text('No transactions yet',
                      style: TextStyle(color: Color(0xFF6B7280))))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: shown.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    itemBuilder: (context, i) {
                      final r = shown[i];
                      final type = (r['type'] ?? '').toString();
                      final meta = _meta(r['metadata']);
                      final created =
                          DateTime.tryParse((r['created_at'] ?? '').toString())
                              ?.toLocal();
                      return InkWell(
                        onTap: () {
                          context.pushNamed(
                            'TransactionDetails',
                            queryParameters: {
                              'transactionId': (r['id'] ?? '').toString(),
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: TransactionLeadIcon(
                                  width: 48,
                                  height: 48,
                                  type: type,
                                  metadata: meta,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _label(type),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF111827)),
                                    ),
                                    const SizedBox(height: 3),
                                    _Subtitle(type: type, meta: meta),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 150,
                                height: 40,
                                child: TransactionAmountTime(
                                  width: 150,
                                  height: 40,
                                  type: type,
                                  amount:
                                      (r['amount'] as num?)?.toDouble() ?? 0,
                                  currency: (r['currency'] ?? '').toString(),
                                  createdAt: created,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _Subtitle extends StatefulWidget {
  const _Subtitle({required this.type, required this.meta});
  final String type;
  final Map<String, dynamic> meta;

  @override
  State<_Subtitle> createState() => _SubtitleState();
}

class _SubtitleState extends State<_Subtitle> {
  String _text = '';

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final t = widget.type;
    final m = widget.meta;
    String text = '';
    if (t == 'send_money_out' || t == 'send_money_in') {
      final id =
          (m[t == 'send_money_out' ? 'recipientUserId' : 'senderUserId'] ?? '')
              .toString();
      if (id.isNotEmpty) {
        text = _walletListNameCache[id] ?? '';
        if (text.isEmpty) {
          try {
            text = await actions.getResolvedDisplayName(currentUserUid, id);
            _walletListNameCache[id] = text;
          } catch (_) {}
        }
        text = (t == 'send_money_out' ? 'To ' : 'From ') + text;
        if (text.trim() == 'To' || text.trim() == 'From') text = '';
      }
    } else if (t == 'giftcard_purchase') {
      text = (m['productName'] ?? '').toString();
    } else if (t.startsWith('airtime') || t.startsWith('data')) {
      final op = (m['operatorName'] ?? '').toString();
      final ph = (m['recipientPhone'] ?? '').toString();
      text = [op, ph].where((e) => e.isNotEmpty).join(' ');
    }
    if (!mounted) return;
    setState(() => _text = text);
  }

  @override
  Widget build(BuildContext context) {
    if (_text.isEmpty) return const SizedBox.shrink();
    return Text(
      _text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
