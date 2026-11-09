import '/flutter_flow/flutter_flow_util.dart';
import 'send_giftcard_to_friends_widget.dart' show SendGiftcardToFriendsWidget;
import 'package:flutter/material.dart';

class SendGiftcardToFriendsModel
    extends FlutterFlowModel<SendGiftcardToFriendsWidget> {
  ///  Local state fields for this component.

  String? selectedContactUserId;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - purchaseSchatzGiftCard] action in Container widget.
  String? purchaseResult;
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
