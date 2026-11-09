import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'story_settings_model.dart';
export 'story_settings_model.dart';

class StorySettingsWidget extends StatefulWidget {
  const StorySettingsWidget({super.key});

  static String routeName = 'story_settings';
  static String routePath = '/storySettings';

  @override
  State<StorySettingsWidget> createState() => _StorySettingsWidgetState();
}

class _StorySettingsWidgetState extends State<StorySettingsWidget> {
  late StorySettingsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StorySettingsModel());

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
        title: 'story_settings',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              child: custom_widgets.StorySettingsPage(
                width: double.infinity,
                height: double.infinity,
                currentUserId: currentUserUid,
              ),
            ),
          ),
        ));
  }
}
