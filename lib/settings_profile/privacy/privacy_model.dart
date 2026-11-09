import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'privacy_widget.dart' show PrivacyWidget;
import 'package:flutter/material.dart';

class PrivacyModel extends FlutterFlowModel<PrivacyWidget> {
  ///  Local state fields for this page.

  PrivacySettingsRow? privacySettingsNew;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getOrCreatePrivacySettings] action in Privacy widget.
  PrivacySettingsRow? privacySettings;
  // State field(s) for Switch widget.
  bool? switchValue1;
  // State field(s) for Switch widget.
  bool? switchValue2;
  // State field(s) for Switch widget.
  bool? switchValue3;
  // Stores action output result for [Custom Action - setFullGhostMode] action in Switch widget.
  PrivacySettingsRow? setFullGhostMode;
  // Stores action output result for [Custom Action - setFullGhostMode] action in Switch widget.
  PrivacySettingsRow? setFullGhostMode2;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
