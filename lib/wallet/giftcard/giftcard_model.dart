import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'giftcard_widget.dart' show GiftcardWidget;
import 'package:flutter/material.dart';

class GiftcardModel extends FlutterFlowModel<GiftcardWidget> {
  ///  Local state fields for this page.

  String? giftcardCountryCode;

  String? giftcardProductsJson;

  List<String> brandNamesList = [];
  void addToBrandNamesList(String item) => brandNamesList.add(item);
  void removeFromBrandNamesList(String item) => brandNamesList.remove(item);
  void removeAtIndexFromBrandNamesList(int index) =>
      brandNamesList.removeAt(index);
  void insertAtIndexInBrandNamesList(int index, String item) =>
      brandNamesList.insert(index, item);
  void updateBrandNamesListAtIndex(int index, Function(String) updateFn) =>
      brandNamesList[index] = updateFn(brandNamesList[index]);

  List<String> brandLogoUrlsList = [];
  void addToBrandLogoUrlsList(String item) => brandLogoUrlsList.add(item);
  void removeFromBrandLogoUrlsList(String item) =>
      brandLogoUrlsList.remove(item);
  void removeAtIndexFromBrandLogoUrlsList(int index) =>
      brandLogoUrlsList.removeAt(index);
  void insertAtIndexInBrandLogoUrlsList(int index, String item) =>
      brandLogoUrlsList.insert(index, item);
  void updateBrandLogoUrlsListAtIndex(int index, Function(String) updateFn) =>
      brandLogoUrlsList[index] = updateFn(brandLogoUrlsList[index]);

  List<String> productIdsList = [];
  void addToProductIdsList(String item) => productIdsList.add(item);
  void removeFromProductIdsList(String item) => productIdsList.remove(item);
  void removeAtIndexFromProductIdsList(int index) =>
      productIdsList.removeAt(index);
  void insertAtIndexInProductIdsList(int index, String item) =>
      productIdsList.insert(index, item);
  void updateProductIdsListAtIndex(int index, Function(String) updateFn) =>
      productIdsList[index] = updateFn(productIdsList[index]);

  List<int> filteredIndexList = [];
  void addToFilteredIndexList(int item) => filteredIndexList.add(item);
  void removeFromFilteredIndexList(int item) => filteredIndexList.remove(item);
  void removeAtIndexFromFilteredIndexList(int index) =>
      filteredIndexList.removeAt(index);
  void insertAtIndexInFilteredIndexList(int index, int item) =>
      filteredIndexList.insert(index, item);
  void updateFilteredIndexListAtIndex(int index, Function(int) updateFn) =>
      filteredIndexList[index] = updateFn(filteredIndexList[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - checkHasPin] action in Giftcard widget.
  bool? hasPinResultGiftCard;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // Stores action output result for [Custom Action - fetchGiftCardProducts] action in DropDown widget.
  String? giftcardFetchResult;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
