import '/flutter_flow/flutter_flow_util.dart';
import 'redeem_your_schatz_giftcard_widget.dart'
    show RedeemYourSchatzGiftcardWidget;
import 'package:flutter/material.dart';

class RedeemYourSchatzGiftcardModel
    extends FlutterFlowModel<RedeemYourSchatzGiftcardWidget> {
  ///  Local state fields for this page.

  String giftCardCode = ' ';

  String redeemStatus = 'idle';

  ///  State fields for stateful widgets in this page.

  // State field(s) for EnterYourGifcardCode widget.
  FocusNode? enterYourGifcardCodeFocusNode;
  TextEditingController? enterYourGifcardCodeTextController;
  String? Function(BuildContext, String?)?
      enterYourGifcardCodeTextControllerValidator;
  // Stores action output result for [Custom Action - redeemSchatzGiftCard] action in Container widget.
  String? redeemResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    enterYourGifcardCodeFocusNode?.dispose();
    enterYourGifcardCodeTextController?.dispose();
  }
}
