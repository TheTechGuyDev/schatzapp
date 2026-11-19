import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'group_profile_details_page_widget.dart'
    show GroupProfileDetailsPageWidget;
import 'package:flutter/material.dart';

class GroupProfileDetailsPageModel
    extends FlutterFlowModel<GroupProfileDetailsPageWidget> {
  ///  Local state fields for this page.

  String? groupNameDetail;

  String? groupDescriptionDetail;

  String? groupAvatarDetail;

  String? groupCreatorName;

  bool isAdmin = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - isGroupAdmin] action in Group_profile_Details_page widget.
  bool? adminResult;
  // Stores action output result for [Custom Action - changeGroupAvatar] action in IconButton widget.
  bool? avatarChanged;
  // State field(s) for Switch widget.
  bool? switchValue1;
  // State field(s) for Switch widget.
  bool? switchValue2;
  // State field(s) for Switch widget.
  bool? switchValue3;
  // State field(s) for Switch widget.
  bool? switchValue4;
  // Stores action output result for [Custom Action - convertGroupToPrivate] action in Row widget.
  bool? convert;
  // Stores action output result for [Custom Action - removePrivateGroup] action in Row widget.
  bool? removed2;
  // Stores action output result for [Custom Action - removePrivateGroup] action in Row widget.
  bool? removed;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
