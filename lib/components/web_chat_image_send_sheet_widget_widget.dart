import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'web_chat_image_send_sheet_widget_model.dart';
export 'web_chat_image_send_sheet_widget_model.dart';

class WebChatImageSendSheetWidgetWidget extends StatefulWidget {
  const WebChatImageSendSheetWidgetWidget({
    super.key,
    this.conversationId,
    this.senderId,
    this.replyToMessageId,
    this.replyToContent,
    this.replyToIsOwn,
  });

  final String? conversationId;
  final String? senderId;
  final String? replyToMessageId;
  final String? replyToContent;
  final bool? replyToIsOwn;

  @override
  State<WebChatImageSendSheetWidgetWidget> createState() =>
      _WebChatImageSendSheetWidgetWidgetState();
}

class _WebChatImageSendSheetWidgetWidgetState
    extends State<WebChatImageSendSheetWidgetWidget> {
  late WebChatImageSendSheetWidgetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WebChatImageSendSheetWidgetModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: custom_widgets.WebChatImageSendSheet(
        width: double.infinity,
        height: double.infinity,
        conversationId: widget.conversationId!,
        senderId: widget.senderId!,
        replyToMessageId: widget.replyToMessageId,
        replyToContent: widget.replyToContent,
        replyToIsOwn: widget.replyToIsOwn!,
        onDone: () async {
          context.safePop();
        },
      ),
    );
  }
}
