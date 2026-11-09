import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'media_links_file_model.dart';
export 'media_links_file_model.dart';

class MediaLinksFileWidget extends StatefulWidget {
  const MediaLinksFileWidget({
    super.key,
    this.conversationId,
  });

  final String? conversationId;

  static String routeName = 'Media_links_file';
  static String routePath = '/mediaLinksFile';

  @override
  State<MediaLinksFileWidget> createState() => _MediaLinksFileWidgetState();
}

class _MediaLinksFileWidgetState extends State<MediaLinksFileWidget> {
  late MediaLinksFileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MediaLinksFileModel());

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
        title: 'Media_links_file',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            body: SafeArea(
              top: true,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: custom_widgets.MediaLinksFilesView(
                  width: double.infinity,
                  height: double.infinity,
                  conversationId: widget.conversationId!,
                  currentUserId: currentUserUid,
                ),
              ),
            ),
          ),
        ));
  }
}
