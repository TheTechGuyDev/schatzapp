import '/flutter_flow/flutter_flow_util.dart';
import 'buy_giftcard_final_widget.dart' show BuyGiftcardFinalWidget;
import 'package:flutter/material.dart';

class BuyGiftcardFinalModel extends FlutterFlowModel<BuyGiftcardFinalWidget> {
  ///  Local state fields for this component.

  String transferIdempotencyKey = ' ';

  bool isProcessing = false;

  bool pinVerifiedResult = false;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - purchaseGiftCard] action in Row widget.
  String? giftcardPurchaseResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
