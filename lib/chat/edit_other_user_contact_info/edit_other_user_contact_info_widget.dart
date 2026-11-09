import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'edit_other_user_contact_info_model.dart';
export 'edit_other_user_contact_info_model.dart';

class EditOtherUserContactInfoWidget extends StatefulWidget {
  const EditOtherUserContactInfoWidget({
    super.key,
    this.otherUserId,
  });

  final String? otherUserId;

  @override
  State<EditOtherUserContactInfoWidget> createState() =>
      _EditOtherUserContactInfoWidgetState();
}

class _EditOtherUserContactInfoWidgetState
    extends State<EditOtherUserContactInfoWidget> {
  late EditOtherUserContactInfoModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditOtherUserContactInfoModel());

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
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Container(
            width: double.infinity,
            height: 360.0,
            child: custom_widgets.EditContactSheet(
              width: double.infinity,
              height: 360.0,
              currentUserId: currentUserUid,
              otherUserId: widget.otherUserId!,
            ),
          ),
        ),
      ),
    );
  }
}
