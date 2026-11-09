import '/flutter_flow/flutter_flow_util.dart';
import 'giftcardpurchase_widget.dart' show GiftcardpurchaseWidget;
import 'package:flutter/material.dart';

class GiftcardpurchaseModel extends FlutterFlowModel<GiftcardpurchaseWidget> {
  ///  Local state fields for this page.

  String? productId;

  String? brandName;

  String? logoUrl;

  String currencyCode = ' ';

  String denominationType = ' ';

  List<double> fixedAmountsList = [];
  void addToFixedAmountsList(double item) => fixedAmountsList.add(item);
  void removeFromFixedAmountsList(double item) => fixedAmountsList.remove(item);
  void removeAtIndexFromFixedAmountsList(int index) =>
      fixedAmountsList.removeAt(index);
  void insertAtIndexInFixedAmountsList(int index, double item) =>
      fixedAmountsList.insert(index, item);
  void updateFixedAmountsListAtIndex(int index, Function(double) updateFn) =>
      fixedAmountsList[index] = updateFn(fixedAmountsList[index]);

  double minAmount = 0.0;

  double maxAmount = 0.0;

  String? redeemInstruction;

  double selectedAmount = 0.0;

  int quantity = 1;

  String recipientEmail = ' ';

  String? productCountryCode;

  bool isProcessing = false;

  String purchaseIdempotencyKey = ' ';

  bool pinVerifiedResult = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - generateUuid] action in Giftcardpurchase widget.
  String? uuidResult;
  // State field(s) for CustomAmountTextField widget.
  FocusNode? customAmountTextFieldFocusNode;
  TextEditingController? customAmountTextFieldTextController;
  String? Function(BuildContext, String?)?
      customAmountTextFieldTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    customAmountTextFieldFocusNode?.dispose();
    customAmountTextFieldTextController?.dispose();

    textFieldFocusNode?.dispose();
    textController2?.dispose();
  }
}
