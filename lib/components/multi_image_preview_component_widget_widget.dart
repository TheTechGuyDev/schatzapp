import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'multi_image_preview_component_widget_model.dart';
export 'multi_image_preview_component_widget_model.dart';

class MultiImagePreviewComponentWidgetWidget extends StatefulWidget {
  const MultiImagePreviewComponentWidgetWidget({
    super.key,
    this.conversationId,
    this.senderId,
    this.mediaIdentifiers,
    this.initialCaption,
    this.replyToMessageId,
    this.replyToContent,
    bool? replyToIsOwn,
    this.onDone,
  }) : this.replyToIsOwn = replyToIsOwn ?? false;

  final String? conversationId;
  final String? senderId;
  final List<String>? mediaIdentifiers;
  final String? initialCaption;
  final String? replyToMessageId;
  final String? replyToContent;
  final bool replyToIsOwn;
  final Future Function()? onDone;

  @override
  State<MultiImagePreviewComponentWidgetWidget> createState() =>
      _MultiImagePreviewComponentWidgetWidgetState();
}

class _MultiImagePreviewComponentWidgetWidgetState
    extends State<MultiImagePreviewComponentWidgetWidget> {
  late MultiImagePreviewComponentWidgetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model =
        createModel(context, () => MultiImagePreviewComponentWidgetModel());

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
      child: custom_widgets.MultiImagePreviewScreen(
        width: double.infinity,
        height: double.infinity,
        conversationId: widget.conversationId!,
        senderId: widget.senderId!,
        initialCaption: widget.initialCaption!,
        replyToMessageId: widget.replyToMessageId,
        replyToContent: widget.replyToContent,
        replyToIsOwn: widget.replyToIsOwn,
        mediaIdentifiers: widget.mediaIdentifiers!,
        onDone: () async {
          await widget.onDone?.call();
        },
      ),
    );
  }
}
