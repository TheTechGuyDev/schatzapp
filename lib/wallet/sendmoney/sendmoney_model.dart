import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'sendmoney_widget.dart' show SendmoneyWidget;
import 'package:flutter/material.dart';

class SendmoneyModel extends FlutterFlowModel<SendmoneyWidget> {
  ///  Local state fields for this page.

  String recipientAccountNumber = ' ';

  String recipientUserId = ' ';

  String recipientName = ' ';

  String recipientAvatarUrl = ' ';

  bool recipientFound = false;

  double sfzAmount = 0.0;

  String noteText = ' ';

  String recipientCurrency = ' ';

  String senderCurrency = ' ';

  double senderFxRate = 0.0;

  bool recipientLookupAttempted = false;

  bool recipientInvalid = false;

  String senderName = ' ';

  String recipientMatchType = ' ';

  String recipientUsername = ' ';

  String usernameLookupResult = ' ';

  String recipientKycStatus = ' ';

  bool exceedsTopUpLimit = false;

  String senderKycStatus = ' ';

  bool exceedsSenderLimit = false;

  bool exceedsBalance = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getOwnWalletCurrency] action in Sendmoney widget.
  String? getOwnWalletCurrencyOutput;
  // Stores action output result for [Custom Action - callFxRate] action in Sendmoney widget.
  double? callFxRateNewResult;
  // Stores action output result for [Custom Action - getOwnProfileName] action in Sendmoney widget.
  String? getOwnProfileNameResult;
  // Stores action output result for [Custom Action - checkHasPin] action in Sendmoney widget.
  bool? hasPinResult;
  // Stores action output result for [Backend Call - Query Rows] action in Sendmoney widget.
  List<WalletsRow>? senderWalletQuery;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // Stores action output result for [Custom Action - lookupRecipientByAccountNumber] action in TextField widget.
  String? recipientLookupResult;
  // Stores action output result for [Backend Call - Query Rows] action in TextField widget.
  List<WalletsRow>? recipientWalletQueryNew;
  // Stores action output result for [Custom Action - lookupRecipientByUsername] action in TextField widget.
  String? usernameLookupResultNew;
  // Stores action output result for [Backend Call - Query Rows] action in TextField widget.
  List<WalletsRow>? recipientWalletQuery;
  // State field(s) for AmountTextField widget.
  FocusNode? amountTextFieldFocusNode;
  TextEditingController? amountTextFieldTextController;
  String? Function(BuildContext, String?)?
      amountTextFieldTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    amountTextFieldFocusNode?.dispose();
    amountTextFieldTextController?.dispose();

    textFieldFocusNode2?.dispose();
    textController3?.dispose();
  }
}
