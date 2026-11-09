import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'add_card_widget.dart' show AddCardWidget;
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class AddCardModel extends FlutterFlowModel<AddCardWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for CardNumberTextField widget.
  FocusNode? cardNumberTextFieldFocusNode;
  TextEditingController? cardNumberTextFieldTextController;
  late MaskTextInputFormatter cardNumberTextFieldMask;
  String? Function(BuildContext, String?)?
      cardNumberTextFieldTextControllerValidator;
  String? _cardNumberTextFieldTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        'x78ql9fn' /* 1111222233334444 is required */,
      );
    }

    return null;
  }

  // State field(s) for ExpDateextField widget.
  FocusNode? expDateextFieldFocusNode;
  TextEditingController? expDateextFieldTextController;
  late MaskTextInputFormatter expDateextFieldMask;
  String? Function(BuildContext, String?)?
      expDateextFieldTextControllerValidator;
  String? _expDateextFieldTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        '6p8kucj4' /* 12/24 is required */,
      );
    }

    return null;
  }

  // State field(s) for CvvTextField widget.
  FocusNode? cvvTextFieldFocusNode;
  TextEditingController? cvvTextFieldTextController;
  String? Function(BuildContext, String?)? cvvTextFieldTextControllerValidator;
  String? _cvvTextFieldTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        'r1fl5xiq' /* 123 is required */,
      );
    }

    if (val.length < 3) {
      return FFLocalizations.of(context).getText(
        '2ixhox66' /* 3 digits */,
      );
    }
    if (val.length > 3) {
      return FFLocalizations.of(context).getText(
        'pymighrq' /* 3 digits */,
      );
    }

    return null;
  }

  // State field(s) for FirstNameTextField widget.
  FocusNode? firstNameTextFieldFocusNode;
  TextEditingController? firstNameTextFieldTextController;
  String? Function(BuildContext, String?)?
      firstNameTextFieldTextControllerValidator;
  String? _firstNameTextFieldTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        'mdnvvn2o' /* Required is required */,
      );
    }

    return null;
  }

  // State field(s) for LastNameTextField widget.
  FocusNode? lastNameTextFieldFocusNode;
  TextEditingController? lastNameTextFieldTextController;
  String? Function(BuildContext, String?)?
      lastNameTextFieldTextControllerValidator;
  String? _lastNameTextFieldTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        'qxne93o5' /* Required is required */,
      );
    }

    return null;
  }

  // State field(s) for AddressTextField widget.
  FocusNode? addressTextFieldFocusNode;
  TextEditingController? addressTextFieldTextController;
  String? Function(BuildContext, String?)?
      addressTextFieldTextControllerValidator;
  String? _addressTextFieldTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        'q4i5cojq' /* Street address is required */,
      );
    }

    return null;
  }

  // State field(s) for CityTextField widget.
  FocusNode? cityTextFieldFocusNode;
  TextEditingController? cityTextFieldTextController;
  String? Function(BuildContext, String?)? cityTextFieldTextControllerValidator;
  String? _cityTextFieldTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        'nang01it' /* City or Town is required */,
      );
    }

    return null;
  }

  // State field(s) for StateTextField widget.
  FocusNode? stateTextFieldFocusNode;
  TextEditingController? stateTextFieldTextController;
  String? Function(BuildContext, String?)?
      stateTextFieldTextControllerValidator;
  String? _stateTextFieldTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        'b14ss2up' /* State or region is required */,
      );
    }

    return null;
  }

  // State field(s) for PostalCodeTextField widget.
  FocusNode? postalCodeTextFieldFocusNode;
  TextEditingController? postalCodeTextFieldTextController;
  String? Function(BuildContext, String?)?
      postalCodeTextFieldTextControllerValidator;
  String? _postalCodeTextFieldTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        'ine90dey' /* Postcode is required */,
      );
    }

    return null;
  }

  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // Stores action output result for [Custom Action - saveCard] action in Container widget.
  String? cardSaved;

  @override
  void initState(BuildContext context) {
    cardNumberTextFieldTextControllerValidator =
        _cardNumberTextFieldTextControllerValidator;
    expDateextFieldTextControllerValidator =
        _expDateextFieldTextControllerValidator;
    cvvTextFieldTextControllerValidator = _cvvTextFieldTextControllerValidator;
    firstNameTextFieldTextControllerValidator =
        _firstNameTextFieldTextControllerValidator;
    lastNameTextFieldTextControllerValidator =
        _lastNameTextFieldTextControllerValidator;
    addressTextFieldTextControllerValidator =
        _addressTextFieldTextControllerValidator;
    cityTextFieldTextControllerValidator =
        _cityTextFieldTextControllerValidator;
    stateTextFieldTextControllerValidator =
        _stateTextFieldTextControllerValidator;
    postalCodeTextFieldTextControllerValidator =
        _postalCodeTextFieldTextControllerValidator;
  }

  @override
  void dispose() {
    cardNumberTextFieldFocusNode?.dispose();
    cardNumberTextFieldTextController?.dispose();

    expDateextFieldFocusNode?.dispose();
    expDateextFieldTextController?.dispose();

    cvvTextFieldFocusNode?.dispose();
    cvvTextFieldTextController?.dispose();

    firstNameTextFieldFocusNode?.dispose();
    firstNameTextFieldTextController?.dispose();

    lastNameTextFieldFocusNode?.dispose();
    lastNameTextFieldTextController?.dispose();

    addressTextFieldFocusNode?.dispose();
    addressTextFieldTextController?.dispose();

    cityTextFieldFocusNode?.dispose();
    cityTextFieldTextController?.dispose();

    stateTextFieldFocusNode?.dispose();
    stateTextFieldTextController?.dispose();

    postalCodeTextFieldFocusNode?.dispose();
    postalCodeTextFieldTextController?.dispose();
  }
}
