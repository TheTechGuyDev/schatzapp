import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'important_pages_list_model.dart';
export 'important_pages_list_model.dart';

class ImportantPagesListWidget extends StatefulWidget {
  const ImportantPagesListWidget({
    super.key,
    this.conversationId,
  });

  final String? conversationId;

  static String routeName = 'Important_pages_list';
  static String routePath = '/importantPagesList';

  @override
  State<ImportantPagesListWidget> createState() =>
      _ImportantPagesListWidgetState();
}

class _ImportantPagesListWidgetState extends State<ImportantPagesListWidget> {
  late ImportantPagesListModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImportantPagesListModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Title(
        title: 'Important_pages_list',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              child: custom_widgets.ChatImportantView(
                width: double.infinity,
                height: double.infinity,
                conversationId: widget.conversationId!,
                currentUserId: currentUserUid,
              ),
            ),
          ),
        ));
  }
}
