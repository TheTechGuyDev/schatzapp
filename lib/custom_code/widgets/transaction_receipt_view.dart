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
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class TransactionReceiptView extends StatefulWidget {
  const TransactionReceiptView({
    super.key,
    this.width,
    this.height,
    required this.transactionId,
  });

  final double? width;
  final double? height;
  final String transactionId;

  @override
  State<TransactionReceiptView> createState() => _TransactionReceiptViewState();
}

class _TransactionReceiptViewState extends State<TransactionReceiptView> {
  final GlobalKey _shotKey = GlobalKey();
  Map<String, dynamic>? _tx;
  Map<String, dynamic> _meta = {};
  String _title = '';
  String _name = '';
  String _account = '';
  String _senderName = '';
  String _senderAccount = '';
  String _senderUsername = '';
  String _recipientName = '';
  String _recipientHandle = '';
  String _logoUrl = '';
  String _avatarUrl = '';
  bool _loading = true;
  bool _busy = false;
  String? _error;

  static const _ok = Color(0xFF1FA45B);
  Color get _green => FlutterFlowTheme.of(context).primary;
  static const _ink = Color(0xFF111827);
  static const _muted = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant TransactionReceiptView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactionId != widget.transactionId) {
      setState(() => _loading = true);
      _load();
    }
  }

  String _fmtAcc(String a) {
    final v = a.trim();
    if (v.isEmpty) return '';
    return v.toUpperCase().startsWith('SFZ') ? v : 'SFZ$v';
  }

  // Returns {'account': 'SFZ...', 'username': '@name'} (either can be empty).
  // Uses the get_party_identity function first (it can read the other
  // person's wallet), then falls back to direct reads.
  Future<Map<String, String>> _identityOf(String userId) async {
    String account = '';
    String username = '';
    try {
      final r = await SupaFlow.client
          .rpc('get_party_identity', params: {'p_user_id': userId});
      if (r is Map) {
        account = (r['account'] ?? '').toString();
        username = (r['username'] ?? '').toString();
      }
    } catch (_) {}
    if (account.isEmpty) {
      try {
        final w = await SupaFlow.client
            .from('wallets')
            .select('schatz_account_number')
            .eq('user_id', userId)
            .maybeSingle();
        account = (w?['schatz_account_number'] ?? '').toString();
      } catch (_) {}
    }
    if (username.isEmpty) {
      try {
        final p = await SupaFlow.client
            .from('profiles')
            .select('username')
            .eq('id', userId)
            .maybeSingle();
        username = (p?['username'] ?? '').toString();
      } catch (_) {}
    }
    username = username.trim().replaceFirst(RegExp(r'^@+'), '');
    return {
      'account': _fmtAcc(account),
      'username': username.isEmpty ? '' : '@$username',
    };
  }

  Future<String> _fullNameOf(String userId) async {
    try {
      final p = await SupaFlow.client
          .from('profiles')
          .select('full_name')
          .eq('id', userId)
          .maybeSingle();
      return (p?['full_name'] ?? '').toString().trim();
    } catch (_) {
      return '';
    }
  }

  String _typeLabel(String t) {
    switch (t) {
      case 'send_money_out':
        return 'Money Sent';
      case 'send_money_in':
        return 'Money Received';
      case 'airtime_purchase':
      case 'airtime':
        return 'Airtime Purchase';
      case 'data_purchase':
      case 'data':
        return 'Data Purchase';
      case 'giftcard_purchase':
        return 'Gift Card Purchase';
      case 'giftcard_received':
        return 'Gift Card Received';
      case 'topup':
        return 'Wallet Top Up';
      default:
        return t.replaceAll('_', ' ').split(' ').map((w) {
          if (w.isEmpty) return w;
          return w[0].toUpperCase() + w.substring(1);
        }).join(' ');
    }
  }

  Future<void> _load() async {
    try {
      final isUuid = RegExp(
              r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
          .hasMatch(widget.transactionId);
      var row = isUuid
          ? await SupaFlow.client
              .from('wallet_transactions')
              .select()
              .eq('id', widget.transactionId)
              .maybeSingle()
          : null;
      row ??= await SupaFlow.client
          .from('wallet_transactions')
          .select()
          .eq('reference', widget.transactionId)
          .maybeSingle();
      if (row == null) {
        if (!mounted) return;
        setState(() {
          _error = 'Transaction not found';
          _loading = false;
        });
        return;
      }
      final tx = Map<String, dynamic>.from(row);
      final m = tx['metadata'];
      Map<String, dynamic> meta = {};
      if (m is Map) {
        meta = Map<String, dynamic>.from(m);
      } else if (m is String && m.isNotEmpty) {
        try {
          final d = jsonDecode(m);
          if (d is Map) meta = Map<String, dynamic>.from(d);
        } catch (_) {}
      }
      final type = (tx['type'] ?? '').toString();
      String name = '';
      String account = '';
      String logo = '';
      String avatar = '';
      String senderName = '';
      String senderAccount = '';
      String senderUsername = '';
      String recipientName = '';
      String recipientHandle = '';

      String? otherId;
      if (type == 'send_money_out') {
        otherId = meta['recipientUserId']?.toString();
      } else if (type == 'send_money_in') {
        otherId = meta['senderUserId']?.toString();
      }
      if (otherId != null && otherId.isNotEmpty) {
        try {
          name = await actions.getResolvedDisplayName(currentUserUid, otherId);
        } catch (_) {}
        try {
          final p = await SupaFlow.client
              .from('profiles')
              .select('avatar_url')
              .eq('id', otherId)
              .maybeSingle();
          avatar = (p?['avatar_url'] ?? '').toString();
        } catch (_) {}
        final otherIdent = await _identityOf(otherId);
        account = otherIdent['account'] ?? '';
        final meId = (tx['user_id'] ?? currentUserUid).toString();
        final otherAcc = _fmtAcc(account);
        final otherUser = otherIdent['username'] ?? '';
        final myName = await _fullNameOf(meId);
        final meIdent = await _identityOf(meId);
        final myAcc = meIdent['account'] ?? '';
        final myUser = meIdent['username'] ?? '';
        // How the recipient was found decides what is shown for BOTH
        // people: account number search shows account numbers, username
        // search shows usernames. Same on the sender and recipient side.
        final saved = (meta['recipientHandle'] ?? '').toString().trim();
        final recipAcc = type == 'send_money_out' ? otherAcc : myAcc;
        final recipUser = type == 'send_money_out' ? otherUser : myUser;
        String norm(String s) =>
            s.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toLowerCase();
        final byAccount = saved.isEmpty ||
            (recipAcc.isNotEmpty && norm(saved) == norm(recipAcc));
        final senderAcc = type == 'send_money_out' ? myAcc : otherAcc;
        final senderUser = type == 'send_money_out' ? myUser : otherUser;
        final senderShown = byAccount ? senderAcc : senderUser;
        final recipShown =
            byAccount ? recipAcc : (recipUser.isNotEmpty ? recipUser : saved);
        if (type == 'send_money_out') {
          senderName = myName;
          recipientName = name;
        } else {
          senderName = name;
          recipientName = myName;
        }
        senderAccount = senderShown;
        senderUsername = '';
        recipientHandle = recipShown;
      } else if (type == 'airtime' ||
          type == 'airtime_purchase' ||
          type == 'data' ||
          type == 'data_purchase' ||
          type == 'giftcard_purchase') {
        final isGift = type == 'giftcard_purchase';
        name = (meta[isGift ? 'productName' : 'operatorName'] ?? '').toString();
        account =
            (meta['recipientPhone'] ?? meta['recipientEmail'] ?? '').toString();
        logo = (meta['logoUrl'] ?? '').toString();
        if (logo.isEmpty) {
          final id =
              (meta[isGift ? 'productId' : 'operatorId'] ?? '').toString();
          if (id.isNotEmpty) {
            try {
              final info = jsonDecode(await actions.getBrandInfo(
                  isGift ? 'giftcard' : 'operator', id));
              if (info is Map) {
                logo = (info['logoUrl'] ?? '').toString();
                if (name.isEmpty) name = (info['name'] ?? '').toString();
              }
            } catch (_) {}
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _tx = tx;
        _meta = meta;
        _title = _typeLabel(type);
        _name = name;
        _account = account;
        _senderName = senderName;
        _senderAccount = senderAccount;
        _senderUsername = senderUsername;
        _recipientName = recipientName;
        _recipientHandle = recipientHandle;
        _logoUrl = logo;
        _avatarUrl = avatar;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load this receipt';
        _loading = false;
      });
    }
  }

  Future<Uint8List?> _capture() async {
    final ctx = _shotKey.currentContext;
    if (ctx == null) return null;
    final boundary = ctx.findRenderObject() as RenderRepaintBoundary;
    final img = await boundary.toImage(pixelRatio: 3.0);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _download() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await _capture();
      if (bytes == null) {
        _toast('Could not create the receipt image');
      } else if (kIsWeb) {
        // Browsers have no gallery: upload the image and download the file.
        final stamp = DateTime.now().millisecondsSinceEpoch;
        final path = 'receipts/${currentUserUid}_$stamp.png';
        await SupaFlow.client.storage.from('chat-media').uploadBinary(
              path,
              bytes,
              fileOptions:
                  const FileOptions(upsert: true, contentType: 'image/png'),
            );
        final url =
            SupaFlow.client.storage.from('chat-media').getPublicUrl(path);
        await launchUrl(
          Uri.parse('$url?download=schatz_receipt_$stamp.png'),
          mode: LaunchMode.externalApplication,
        );
        _toast('Receipt downloaded');
      } else {
        await Gal.putImageBytes(bytes);
        _toast('Receipt saved to your gallery');
      }
    } catch (e) {
      _toast('Could not save the receipt. Check photo permission.');
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _send() async {
    if (_busy) return;
    final picked = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FriendPickerSheet(),
    );
    if (picked == null || picked.isEmpty) return;
    setState(() => _busy = true);
    try {
      final bytes = await _capture();
      if (bytes == null) {
        _toast('Could not create the receipt image');
        if (mounted) setState(() => _busy = false);
        return;
      }
      final path =
          'receipts/${currentUserUid}_${DateTime.now().millisecondsSinceEpoch}.png';
      await SupaFlow.client.storage.from('chat-media').uploadBinary(
            path,
            bytes,
            fileOptions:
                const FileOptions(upsert: true, contentType: 'image/png'),
          );
      final url = SupaFlow.client.storage.from('chat-media').getPublicUrl(path);
      for (final friendId in picked) {
        final convId =
            await actions.findOrCreateConversation(currentUserUid, friendId);
        await SupaFlow.client.from('messages').insert({
          'conversation_id': convId,
          'sender_id': currentUserUid,
          'message_type': 'image',
          'media_url': url,
          'content': 'Receipt',
        });
      }
      _toast(picked.length == 1
          ? 'Receipt sent'
          : 'Receipt sent to ${picked.length} friends');
    } catch (e) {
      _toast('Could not send the receipt');
    }
    if (mounted) setState(() => _busy = false);
  }

  Widget _partyRow(String label, String name, String handle,
      {String extra = ''}) {
    if (name.trim().isEmpty && handle.trim().isEmpty && extra.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: _muted)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (name.trim().isNotEmpty)
                  Text(
                    name,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 13, color: _ink, fontWeight: FontWeight.w700),
                  ),
                if (handle.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      handle,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 12, color: _muted),
                    ),
                  ),
                if (extra.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      extra,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 12, color: _muted),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: _muted)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                color: _ink,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lead() {
    final raw = _avatarUrl.isNotEmpty ? _avatarUrl : _logoUrl;
    final url = raw.isEmpty ? '' : buildImageProxyUrl(raw);
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF3F4F6),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isEmpty
          ? Icon(Icons.receipt_long_rounded, color: _green, size: 30)
          : cachedNetworkImage(
              url,
              fit: _avatarUrl.isNotEmpty ? BoxFit.cover : BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.receipt_long_rounded, color: _green, size: 30),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _tx == null) {
      return Center(
        child: Text(_error ?? 'Transaction not found',
            style: const TextStyle(color: _muted)),
      );
    }
    final tx = _tx!;
    final type = (tx['type'] ?? '').toString();
    final status = (tx['status'] ?? 'completed').toString();
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0;
    final currency = (tx['currency'] ?? '').toString();
    final created =
        DateTime.tryParse((tx['created_at'] ?? '').toString())?.toLocal();
    final dateStr =
        created == null ? '' : DateFormat('dd MMMM yyyy').format(created);
    final timeStr = created == null ? '' : DateFormat('h:mm a').format(created);
    final positive = type == 'send_money_in' ||
        type == 'giftcard_received' ||
        type == 'topup';
    final isTransfer = type == 'send_money_out' || type == 'send_money_in';
    const amountStyle =
        TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _ink);
    final ok = status == 'completed' || status == 'success';
    final statusColor = ok
        ? _ok
        : (status == 'pending'
            ? const Color(0xFFF59E0B)
            : const Color(0xFFDC2626));
    final nameLabel = type == 'send_money_in'
        ? 'Sender'
        : (type == 'send_money_out' ? 'Recipient' : 'Provider');
    final accLabel = isTransfer
        ? 'Account number'
        : (type == 'giftcard_purchase' ? 'Delivered to' : 'Phone number');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        children: [
          RepaintBoundary(
            key: _shotKey,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  Text('SchatzApp',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _green,
                          letterSpacing: 0.4)),
                  const SizedBox(height: 14),
                  _lead(),
                  const SizedBox(height: 10),
                  Text(_title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _ink)),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(positive ? '+' : '-', style: amountStyle),
                        if (isTransfer)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2),
                            child: Icon(IconData(0xe900, fontFamily: 'Icomoon'),
                                size: 24, color: _ink),
                          )
                        else
                          Text('$currency ', style: amountStyle),
                        Text(NumberFormat('#,##0.00').format(amount),
                            style: amountStyle),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.isEmpty
                          ? ''
                          : status[0].toUpperCase() + status.substring(1),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusColor),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 6),
                  if (isTransfer) ...[
                    _partyRow('Sender', _senderName, _senderAccount,
                        extra: _senderUsername),
                    _partyRow('Recipient', _recipientName, _recipientHandle),
                  ] else ...[
                    _row(nameLabel, _name, bold: true),
                    _row(accLabel, _account),
                  ],
                  _row('Date', dateStr),
                  _row('Time', timeStr),
                  _row('Reference', (tx['reference'] ?? '').toString()),
                  _row('Transaction ID', (tx['id'] ?? '').toString()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _download,
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: const Text('Download'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _green,
                    side: BorderSide(color: _green),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : _send,
                  icon: _busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Send Receipt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FriendPickerSheet extends StatefulWidget {
  const _FriendPickerSheet();

  @override
  State<_FriendPickerSheet> createState() => _FriendPickerSheetState();
}

class _FriendPickerSheetState extends State<_FriendPickerSheet> {
  List<Map<String, dynamic>> _friends = [];
  final Set<String> _selected = {};
  bool _loading = true;
  String _q = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await SupaFlow.client
          .from('contacts')
          .select('saved_name, contact_user_id')
          .eq('owner_id', currentUserUid)
          .not('contact_user_id', 'is', null)
          .order('saved_name');
      final list = List<Map<String, dynamic>>.from(rows as List);
      final ids = list.map((e) => e['contact_user_id'].toString()).toList();
      final avatars = <String, String>{};
      if (ids.isNotEmpty) {
        final ps = await SupaFlow.client
            .from('profiles')
            .select('id, avatar_url')
            .inFilter('id', ids);
        for (final p in (ps as List)) {
          avatars[p['id'].toString()] = (p['avatar_url'] ?? '').toString();
        }
      }
      for (final f in list) {
        f['avatar'] = avatars[f['contact_user_id'].toString()] ?? '';
      }
      if (!mounted) return;
      setState(() {
        _friends = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shown = _friends
        .where((f) => (f['saved_name'] ?? '')
            .toString()
            .toLowerCase()
            .contains(_q.toLowerCase()))
        .toList();
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2))),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Send receipt to',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              onChanged: (v) => setState(() => _q = v),
              decoration: InputDecoration(
                hintText: 'Search friends',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : shown.isEmpty
                    ? const Center(
                        child: Text('No SchatzApp friends found',
                            style: TextStyle(color: Color(0xFF6B7280))))
                    : ListView.builder(
                        itemCount: shown.length,
                        itemBuilder: (_, i) {
                          final f = shown[i];
                          final id = f['contact_user_id'].toString();
                          final name = (f['saved_name'] ?? '').toString();
                          final avatar = (f['avatar'] ?? '').toString();
                          final on = _selected.contains(id);
                          return ListTile(
                            onTap: () => setState(() =>
                                on ? _selected.remove(id) : _selected.add(id)),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFE5E7EB),
                              backgroundImage: avatar.isEmpty
                                  ? null
                                  : cachedNetworkImageProvider(buildImageProxyUrl(avatar)),
                              child: avatar.isEmpty
                                  ? Text(name.isEmpty
                                      ? '?'
                                      : name[0].toUpperCase())
                                  : null,
                            ),
                            title: Text(name),
                            trailing: Icon(
                              on
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: on
                                  ? FlutterFlowTheme.of(context).primary
                                  : const Color(0xFF9CA3AF),
                            ),
                          );
                        },
                      ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selected.isEmpty
                      ? null
                      : () => Navigator.pop(context, _selected.toList()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_selected.isEmpty
                      ? 'Select friends'
                      : 'Send to ${_selected.length}'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
