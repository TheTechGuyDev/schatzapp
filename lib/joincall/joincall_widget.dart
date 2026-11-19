import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'joincall_model.dart';
export 'joincall_model.dart';

class JoincallWidget extends StatefulWidget {
  const JoincallWidget({
    super.key,
    this.code,
  });

  final String? code;

  static String routeName = 'joincall';
  static String routePath = '/call/:code';

  @override
  State<JoincallWidget> createState() => _JoincallWidgetState();
}

class _JoincallWidgetState extends State<JoincallWidget> {
  late JoincallModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => JoincallModel());

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
        title: 'joincall',
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
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: custom_widgets.JoinCallView(
                          width: double.infinity,
                          height: double.infinity,
                          code: widget.code!,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
