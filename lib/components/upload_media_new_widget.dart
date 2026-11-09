import '/components/attachment_item_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'upload_media_new_model.dart';
export 'upload_media_new_model.dart';

class UploadMediaNewWidget extends StatefulWidget {
  const UploadMediaNewWidget({super.key});

  @override
  State<UploadMediaNewWidget> createState() => _UploadMediaNewWidgetState();
}

class _UploadMediaNewWidgetState extends State<UploadMediaNewWidget> {
  late UploadMediaNewModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UploadMediaNewModel());

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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.0),
          topRight: Radius.circular(32.0),
        ),
        shape: BoxShape.rectangle,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(24.0, 32.0, 24.0, 48.0),
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
                child: Container(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Container(
                    width: 40.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).alternate,
                      borderRadius: BorderRadius.circular(9999.0),
                      shape: BoxShape.rectangle,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  wrapWithModel(
                    model: _model.attachmentItemModel1,
                    updateCallback: () => safeSetState(() {}),
                    child: AttachmentItemWidget(
                      icon: Icon(
                        Icons.photo_library_rounded,
                        color: Color(0xFF4285F4),
                        size: 24.0,
                      ),
                      label: 'Photos',
                      tone: Color(0xFF4285F4),
                    ),
                  ),
                  wrapWithModel(
                    model: _model.attachmentItemModel2,
                    updateCallback: () => safeSetState(() {}),
                    child: AttachmentItemWidget(
                      icon: Icon(
                        Icons.photo_camera_rounded,
                        color: Color(0xFF1A2CE4),
                        size: 24.0,
                      ),
                      label: 'Camera',
                      tone: FlutterFlowTheme.of(context).onPrimary,
                    ),
                  ),
                  wrapWithModel(
                    model: _model.attachmentItemModel3,
                    updateCallback: () => safeSetState(() {}),
                    child: AttachmentItemWidget(
                      icon: Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFF24C52C),
                        size: 24.0,
                      ),
                      label: 'Location',
                      tone: Color(0xFF34A853),
                    ),
                  ),
                  wrapWithModel(
                    model: _model.attachmentItemModel4,
                    updateCallback: () => safeSetState(() {}),
                    child: AttachmentItemWidget(
                      icon: Icon(
                        Icons.account_circle_rounded,
                        color: Color(0xFFCB0B15),
                        size: 24.0,
                      ),
                      label: 'Contact',
                      tone: Color(0xFF9AA0A6),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  wrapWithModel(
                    model: _model.attachmentItemModel5,
                    updateCallback: () => safeSetState(() {}),
                    child: AttachmentItemWidget(
                      icon: Icon(
                        Icons.description_rounded,
                        color: Color(0xFFA9950A),
                        size: 24.0,
                      ),
                      label: 'Document',
                      tone: Colors.blue,
                    ),
                  ),
                  wrapWithModel(
                    model: _model.attachmentItemModel6,
                    updateCallback: () => safeSetState(() {}),
                    child: AttachmentItemWidget(
                      icon: Icon(
                        Icons.bar_chart_rounded,
                        color: Color(0xFFE7501D),
                        size: 24.0,
                      ),
                      label: 'Poll',
                      tone: Color(0xFFFBBC04),
                    ),
                  ),
                  wrapWithModel(
                    model: _model.attachmentItemModel7,
                    updateCallback: () => safeSetState(() {}),
                    child: AttachmentItemWidget(
                      icon: Icon(
                        Icons.calendar_today_rounded,
                        color: Color(0xFF4285F4),
                        size: 24.0,
                      ),
                      label: 'Event',
                      tone: Color(0xFFEA4335),
                    ),
                  ),
                  wrapWithModel(
                    model: _model.attachmentItemModel8,
                    updateCallback: () => safeSetState(() {}),
                    child: AttachmentItemWidget(
                      icon: Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFF4285F4),
                        size: 24.0,
                      ),
                      label: 'AI Images',
                      tone: Color(0xFF8AB4F8),
                    ),
                  ),
                ],
              ),
            ].divide(SizedBox(height: 24.0)),
          ),
        ),
      ),
    );
  }
}
