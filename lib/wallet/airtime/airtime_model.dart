import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'airtime_widget.dart' show AirtimeWidget;
import 'package:flutter/material.dart';

class AirtimeModel extends FlutterFlowModel<AirtimeWidget> {
  ///  Local state fields for this page.

  String operatorId = '0';

  String operatorName = 'Select  network';

  String operatorLogoUrl = '0';

  String operatorCurrency = '0';

  String operatorAmountsJson = '0';

  List<double> amountsList = [];
  void addToAmountsList(double item) => amountsList.add(item);
  void removeFromAmountsList(double item) => amountsList.remove(item);
  void removeAtIndexFromAmountsList(int index) => amountsList.removeAt(index);
  void insertAtIndexInAmountsList(int index, double item) =>
      amountsList.insert(index, item);
  void updateAmountsListAtIndex(int index, Function(double) updateFn) =>
      amountsList[index] = updateFn(amountsList[index]);

  double selectedAmount = 0.0;

  String? denominationType;

  double? minAmount = 0.0;

  double maxAmount = 0.0;

  String recipientCountryIsoCode = ' ';

  String recipientCountryName = ' ';

  bool isProcessing = false;

  String purchaseIdempotencyKey = ' ';

  bool pinVerifiedResult = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - generateUuid] action in Airtime widget.
  String? uuidResult;
  // Stores action output result for [Custom Action - checkHasPin] action in Airtime widget.
  bool? hasPinResultAirtime;
  // State field(s) for PhoneTextField widget.
  FocusNode? phoneTextFieldFocusNode;
  TextEditingController? phoneTextFieldTextController;
  String? Function(BuildContext, String?)?
      phoneTextFieldTextControllerValidator;
  // Stores action output result for [Custom Action - detectReloadlyOperator] action in PhoneTextField widget.
  String? operatorResult;
  // State field(s) for CustomAmountTextField widget.
  FocusNode? customAmountTextFieldFocusNode;
  TextEditingController? customAmountTextFieldTextController;
  String? Function(BuildContext, String?)?
      customAmountTextFieldTextControllerValidator;
  // Stores action output result for [Custom Action - purchaseAirtime] action in Button widget.
  String? purchaseResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    phoneTextFieldFocusNode?.dispose();
    phoneTextFieldTextController?.dispose();

    customAmountTextFieldFocusNode?.dispose();
    customAmountTextFieldTextController?.dispose();
  }
}
