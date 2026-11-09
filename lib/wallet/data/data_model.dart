import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'data_widget.dart' show DataWidget;
import 'package:flutter/material.dart';

class DataModel extends FlutterFlowModel<DataWidget> {
  ///  Local state fields for this page.

  String? operatorId;

  String? operatorName;

  String operatorLogoUrl = ' ';

  String? operatorCurrency;

  String? operatorAmountsJson;

  String? operatorDescriptionsJson;

  List<double> amountsList = [];
  void addToAmountsList(double item) => amountsList.add(item);
  void removeFromAmountsList(double item) => amountsList.remove(item);
  void removeAtIndexFromAmountsList(int index) => amountsList.removeAt(index);
  void insertAtIndexInAmountsList(int index, double item) =>
      amountsList.insert(index, item);
  void updateAmountsListAtIndex(int index, Function(double) updateFn) =>
      amountsList[index] = updateFn(amountsList[index]);

  List<String> bundleLabelsList = [];
  void addToBundleLabelsList(String item) => bundleLabelsList.add(item);
  void removeFromBundleLabelsList(String item) => bundleLabelsList.remove(item);
  void removeAtIndexFromBundleLabelsList(int index) =>
      bundleLabelsList.removeAt(index);
  void insertAtIndexInBundleLabelsList(int index, String item) =>
      bundleLabelsList.insert(index, item);
  void updateBundleLabelsListAtIndex(int index, Function(String) updateFn) =>
      bundleLabelsList[index] = updateFn(bundleLabelsList[index]);

  double selectedAmount = 0.0;

  String? denominationType;

  double minAmount = 0.0;

  double maxAmount = 0.0;

  double fxRateToEur = 0.0;

  String selectedPlanLabel = ' ';

  bool isProcessing = false;

  String purchaseIdempotencyKey = ' ';

  bool pinVerifiedResult = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - generateUuid] action in Data widget.
  String? uuidResult;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Custom Action - detectReloadlyDataOperator] action in TextField widget.
  String? dataOperatorResult;
  // Stores action output result for [Custom Action - callFxRate] action in TextField widget.
  double? fxRateToEurResult;
  // Stores action output result for [Custom Action - purchaseData] action in Button widget.
  String? dataPurchaseResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
