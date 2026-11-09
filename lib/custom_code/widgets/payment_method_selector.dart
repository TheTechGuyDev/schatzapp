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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class _SavedCard {
  const _SavedCard({
    required this.id,
    required this.brand,
    required this.lastFour,
    required this.isDefault,
  });

  final String id;
  final String brand;
  final String lastFour;
  final bool isDefault;
}

class PaymentMethodSelector extends StatefulWidget {
  const PaymentMethodSelector({
    super.key,
    this.width,
    this.height,
    required this.sfzAmount,
  });

  final double? width;
  final double? height;
  final double sfzAmount;

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  late Future<List<_SavedCard>> _cardsFuture;
  String? _selectedCardId;

  @override
  void initState() {
    super.initState();
    _cardsFuture = _loadCards();
  }

  Future<List<_SavedCard>> _loadCards() async {
    final rows = await SupaFlow.client
        .from('saved_cards')
        .select()
        .eq('user_id', currentUserUid)
        .order('created_at', ascending: false);

    final cards = rows
        .map((r) => _SavedCard(
              id: r['id'] as String,
              brand: (r['card_brand'] as String?) ?? 'Card',
              lastFour: (r['card_last_four'] as String?) ?? '----',
              isDefault: (r['is_default'] as bool?) ?? false,
            ))
        .toList();

    if (cards.isNotEmpty && _selectedCardId == null) {
      final defaultCard = cards.firstWhere(
        (c) => c.isDefault,
        orElse: () => cards.first,
      );
      _selectedCardId = defaultCard.id;
      FFAppState().update(() {
        FFAppState().selectedCardId = defaultCard.id;
      });
    }

    return cards;
  }

  Future<void> _refresh() async {
    final future = _loadCards();
    setState(() {
      _cardsFuture = future;
    });
  }

  Future<bool> _confirmDelete(_SavedCard card) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete card'),
        content: Text('Remove the card ending in ${card.lastFour}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      await SupaFlow.client.from('saved_cards').delete().eq('id', card.id);
      if (_selectedCardId == card.id) {
        _selectedCardId = null;
        FFAppState().update(() {
          FFAppState().selectedCardId = '';
        });
      }
      if (mounted) {
        await _refresh();
      }
      return true;
    }
    return false;
  }

  Widget _brandIcon(String brand) {
    switch (brand) {
      case 'Visa':
        return const FaIcon(
          FaIconData(IconData(
            0xf1f0,
            fontFamily: 'FontAwesomeBrands',
            fontPackage: 'font_awesome_flutter',
          )),
          color: Color(0xFF935CCC),
          size: 35.0,
        );
      case 'Mastercard':
        return const FaIcon(
          FaIconData(IconData(
            0xf1f1,
            fontFamily: 'FontAwesomeBrands',
            fontPackage: 'font_awesome_flutter',
          )),
          color: Color(0xFF935CCC),
          size: 35.0,
        );
      default:
        return const Text(
          'VERVE',
          style: TextStyle(
            color: Color(0xFF935CCC),
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }

  Widget _cardRow(_SavedCard card) {
    final theme = FlutterFlowTheme.of(context);
    final selected = _selectedCardId == card.id;

    return Dismissible(
      key: ValueKey(card.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(card),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        margin: const EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            setState(() {
              _selectedCardId = card.id;
            });
            FFAppState().update(() {
              FFAppState().selectedCardId = card.id;
            });
          },
          onLongPress: () => _confirmDelete(card),
          child: Container(
            width: double.infinity,
            height: 65.0,
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0x2F935CCC)
                  : theme.secondaryBackground,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color: selected
                    ? const Color(0xFF935CCC)
                    : const Color(0x2F935CCC),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: const BoxDecoration(
                          color: Color(0x2F935CCC),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Center(child: _brandIcon(card.brand)),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        '•••• •••• •••• ${card.lastFour}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.primaryText,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF935CCC)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF935CCC),
                        width: 2.0,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 14.0)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _addCardRow() {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        await context.pushNamed('AddCard');
        if (mounted) {
          await _refresh();
        }
      },
      child: Container(
        width: double.infinity,
        height: 65.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: const Color(0x2F935CCC)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: const BoxDecoration(
                      color: Color(0x2F935CCC),
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.credit_card,
                        color: Color(0xFF935CCC),
                        size: 35.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Text(
                    'Add Debit / Credit Card',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.primaryText,
                    ),
                  ),
                ],
              ),
              Container(
                width: 20.0,
                height: 20.0,
                decoration: const BoxDecoration(
                  color: Color(0xFF935CCC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              'Payment Method',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.0,
                color: theme.secondaryText,
              ),
            ),
          ),
          FutureBuilder<List<_SavedCard>>(
            future: _cardsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    'Error loading cards: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red, fontSize: 11.0),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              final cards = snapshot.data!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...cards.map(_cardRow),
                  if (cards.length < 2) _addCardRow(),
                ],
              );
            },
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (isIOS)
                _PayButtonConst(
                  icon: const IconData(0xf415,
                      fontFamily: 'FontAwesomeBrands',
                      fontPackage: 'font_awesome_flutter'),
                  sfzAmount: widget.sfzAmount,
                )
              else
                _PayButtonConst(
                  icon: const IconData(0xe079,
                      fontFamily: 'FontAwesomeBrands',
                      fontPackage: 'font_awesome_flutter'),
                  sfzAmount: widget.sfzAmount,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayButtonConst extends StatelessWidget {
  const _PayButtonConst({required this.icon, required this.sfzAmount});

  final IconData icon;
  final double sfzAmount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: InkWell(
          onTap: () async {
            await actions.executeTopUpViaPayButton(context, sfzAmount);
          },
          child: Container(
            width: double.infinity,
            height: 50.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryText,
              borderRadius: BorderRadius.circular(25.0),
              border: Border.all(color: const Color(0x2F935CCC)),
            ),
            child: Center(
              child: FaIcon(
                FaIconData(icon),
                color: FlutterFlowTheme.of(context).secondaryBackground,
                size: 45.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
