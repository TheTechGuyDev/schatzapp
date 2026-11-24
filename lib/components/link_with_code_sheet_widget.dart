import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'link_with_code_sheet_model.dart';
export 'link_with_code_sheet_model.dart';

class LinkWithCodeSheetWidget extends StatefulWidget {
  const LinkWithCodeSheetWidget({super.key});

  @override
  State<LinkWithCodeSheetWidget> createState() =>
      _LinkWithCodeSheetWidgetState();
}

class _LinkWithCodeSheetWidgetState extends State<LinkWithCodeSheetWidget> {
  late LinkWithCodeSheetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LinkWithCodeSheetModel());

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
      height: 420.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 360.0,
              height: 360.0,
              child: custom_widgets.LinkWithCodeView(
                width: 360.0,
                height: 360.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
