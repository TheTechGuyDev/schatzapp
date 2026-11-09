import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'share_to_contact_model.dart';
export 'share_to_contact_model.dart';

class ShareToContactWidget extends StatefulWidget {
  const ShareToContactWidget({
    super.key,
    this.storyMediaUrl,
    this.storyMediaType,
  });

  final String? storyMediaUrl;
  final String? storyMediaType;

  @override
  State<ShareToContactWidget> createState() => _ShareToContactWidgetState();
}

class _ShareToContactWidgetState extends State<ShareToContactWidget> {
  late ShareToContactModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ShareToContactModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 80.0, 0.0, 0.0),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: custom_widgets.ShareToContact(
          width: double.infinity,
          height: double.infinity,
          currentUserId: currentUserUid,
          storyMediaUrl: widget.storyMediaUrl!,
          storyMediaType: widget.storyMediaType!,
          onDone: () async {
            context.safePop();
          },
        ),
      ),
    );
  }
}
