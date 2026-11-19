import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'join_group_page_model.dart';
export 'join_group_page_model.dart';

class JoinGroupPageWidget extends StatefulWidget {
  const JoinGroupPageWidget({
    super.key,
    this.code,
  });

  final String? code;

  static String routeName = 'JoinGroupPage';
  static String routePath = '/joinGroupPage';

  @override
  State<JoinGroupPageWidget> createState() => _JoinGroupPageWidgetState();
}

class _JoinGroupPageWidgetState extends State<JoinGroupPageWidget> {
  late JoinGroupPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => JoinGroupPageModel());

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
        title: 'JoinGroupPage',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            appBar: AppBar(
              backgroundColor: Color(0xFF935CCC),
              automaticallyImplyLeading: false,
              title: Text(
                FFLocalizations.of(context).getText(
                  '77651bll' /* Page Title */,
                ),
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .fontWeight,
                        fontStyle: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .fontStyle,
                      ),
                      color: Colors.white,
                      fontSize: 22.0,
                      letterSpacing: 0.0,
                      fontWeight: FlutterFlowTheme.of(context)
                          .headlineMedium
                          .fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                    ),
              ),
              actions: [],
              centerTitle: false,
              elevation: 2.0,
            ),
            body: SafeArea(
              top: true,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 400.0,
                    height: 600.0,
                    child: custom_widgets.JoinGroupView(
                      width: 400.0,
                      height: 600.0,
                      code: widget.code!,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
