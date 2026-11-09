import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'media_library_sheet_component_model.dart';
export 'media_library_sheet_component_model.dart';

class MediaLibrarySheetComponentWidget extends StatefulWidget {
  const MediaLibrarySheetComponentWidget({
    super.key,
    this.currentSelection,
    this.onSelectionChanged,
    this.onClose,
    this.onSend,
  });

  final List<String>? currentSelection;
  final Future Function(List<String> selectedPaths)? onSelectionChanged;
  final Future Function()? onClose;
  final Future Function(List<String> selectedPaths, String caption)? onSend;

  @override
  State<MediaLibrarySheetComponentWidget> createState() =>
      _MediaLibrarySheetComponentWidgetState();
}

class _MediaLibrarySheetComponentWidgetState
    extends State<MediaLibrarySheetComponentWidget> {
  late MediaLibrarySheetComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MediaLibrarySheetComponentModel());

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
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Container(
          width: double.infinity,
          height: 500.0,
          child: custom_widgets.MediaLibrarySheet(
            width: double.infinity,
            height: 500.0,
            existingSelectedPaths: widget.currentSelection!,
            onSelectionChanged: (selectedPaths) async {
              await widget.onSelectionChanged?.call(
                selectedPaths,
              );
            },
            onClose: () async {
              await widget.onClose?.call();
            },
            onSend: (selectedPaths, caption) async {
              await widget.onSend?.call(
                selectedPaths,
                caption,
              );
            },
          ),
        ),
      ),
    );
  }
}
