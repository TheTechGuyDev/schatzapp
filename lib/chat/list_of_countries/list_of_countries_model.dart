import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'list_of_countries_widget.dart' show ListOfCountriesWidget;
import 'package:flutter/material.dart';

class ListOfCountriesModel extends FlutterFlowModel<ListOfCountriesWidget> {
  ///  Local state fields for this component.

  List<CountryStruct> allCountries = [];
  void addToAllCountries(CountryStruct item) => allCountries.add(item);
  void removeFromAllCountries(CountryStruct item) => allCountries.remove(item);
  void removeAtIndexFromAllCountries(int index) => allCountries.removeAt(index);
  void insertAtIndexInAllCountries(int index, CountryStruct item) =>
      allCountries.insert(index, item);
  void updateAllCountriesAtIndex(int index, Function(CountryStruct) updateFn) =>
      allCountries[index] = updateFn(allCountries[index]);

  List<CountryStruct> filteredCountries = [];
  void addToFilteredCountries(CountryStruct item) =>
      filteredCountries.add(item);
  void removeFromFilteredCountries(CountryStruct item) =>
      filteredCountries.remove(item);
  void removeAtIndexFromFilteredCountries(int index) =>
      filteredCountries.removeAt(index);
  void insertAtIndexInFilteredCountries(int index, CountryStruct item) =>
      filteredCountries.insert(index, item);
  void updateFilteredCountriesAtIndex(
          int index, Function(CountryStruct) updateFn) =>
      filteredCountries[index] = updateFn(filteredCountries[index]);

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - getCountriesList] action in ListOfCountries widget.
  List<CountryStruct>? countriesResult;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Custom Action - filterCountries] action in TextField widget.
  List<CountryStruct>? filterResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
