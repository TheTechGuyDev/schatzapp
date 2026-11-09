import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'edit_post_image_model.dart';
export 'edit_post_image_model.dart';

class EditPostImageWidget extends StatefulWidget {
  const EditPostImageWidget({super.key});

  static String routeName = 'edit_post_image';
  static String routePath = '/editPostImage';

  @override
  State<EditPostImageWidget> createState() => _EditPostImageWidgetState();
}

class _EditPostImageWidgetState extends State<EditPostImageWidget> {
  late EditPostImageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditPostImageModel());

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
        title: 'edit_post_image',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: SafeArea(
              top: true,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: custom_widgets.MultiImageEditPost(
                  width: double.infinity,
                  height: double.infinity,
                  currentUserId: currentUserUid,
                  taggedUserIds: <String>[],
                  onClose: () async {
                    context.safePop();
                  },
                  onPosted: () async {
                    context.safePop();
                  },
                ),
              ),
            ),
          ),
        ));
  }
}
