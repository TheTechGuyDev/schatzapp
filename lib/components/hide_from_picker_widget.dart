import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'hide_from_picker_model.dart';
export 'hide_from_picker_model.dart';

class HideFromPickerWidget extends StatefulWidget {
  const HideFromPickerWidget({super.key});

  @override
  State<HideFromPickerWidget> createState() => _HideFromPickerWidgetState();
}

class _HideFromPickerWidgetState extends State<HideFromPickerWidget> {
  late HideFromPickerModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HideFromPickerModel());

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
      height: 300.0,
      child: custom_widgets.HideFromPicker(
        width: double.infinity,
        height: 300.0,
        currentUserId: currentUserUid,
        onDone: () async {
          Navigator.pop(context);
        },
      ),
    );
  }
}
