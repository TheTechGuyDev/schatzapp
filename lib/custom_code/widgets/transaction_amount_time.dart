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

import 'package:intl/intl.dart';

class TransactionAmountTime extends StatelessWidget {
  const TransactionAmountTime({
    super.key,
    this.width,
    this.height,
    required this.type,
    required this.amount,
    this.currency,
    this.createdAt,
  });

  final double? width;
  final double? height;
  final String type;
  final double amount;
  final String? currency;
  final DateTime? createdAt;

  bool get _isIncoming =>
      type == 'send_money_in' || type == 'giftcard_received' || type == 'topup';

  bool get _isTransfer => type == 'send_money_in' || type == 'send_money_out';

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final amountStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: _isIncoming ? const Color(0xFF1E9E4A) : theme.primaryText,
    );

    final when = createdAt == null
        ? ''
        : '${DateFormat('dd MMM yyyy').format(createdAt!.toLocal())}  •  '
            '${DateFormat('h:mm a').format(createdAt!.toLocal())}';

    return Container(
      width: width,
      constraints: const BoxConstraints(maxWidth: 190),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_isIncoming ? '+' : '-', style: amountStyle),
                if (_isTransfer)
                  Icon(const IconData(0xe900, fontFamily: 'Icomoon'),
                      size: 13,
                      color: _isIncoming
                          ? const Color(0xFF1E9E4A)
                          : theme.primaryText)
                else
                  Text('${currency ?? ''} ', style: amountStyle),
                Text(NumberFormat('#,##0.00').format(amount),
                    style: amountStyle),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            when,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: theme.secondaryText),
          ),
        ],
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
