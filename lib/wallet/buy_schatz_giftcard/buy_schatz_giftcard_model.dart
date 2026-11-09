import '/flutter_flow/flutter_flow_util.dart';
import 'buy_schatz_giftcard_widget.dart' show BuySchatzGiftcardWidget;
import 'package:flutter/material.dart';

class BuySchatzGiftcardModel extends FlutterFlowModel<BuySchatzGiftcardWidget> {
  ///  Local state fields for this page.

  int selectedSchatzAmount = 1000;

  String selectedDeliveryMethod = 'self';

  ///  State fields for stateful widgets in this page.

  // State field(s) for CustomAmount widget.
  FocusNode? customAmountFocusNode;
  TextEditingController? customAmountTextController;
  String? Function(BuildContext, String?)? customAmountTextControllerValidator;
  // State field(s) for Checkbox widget.
  bool? checkboxValue1;
  // State field(s) for Checkbox widget.
  bool? checkboxValue2;
  // Stores action output result for [Custom Action - purchaseSchatzGiftCard] action in Container widget.
  String? purchaseResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    customAmountFocusNode?.dispose();
    customAmountTextController?.dispose();
  }
}
