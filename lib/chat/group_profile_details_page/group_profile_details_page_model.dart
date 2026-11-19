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

  bool groupIsPrivate = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - isGroupPrivate] action in Group_profile_Details_page widget.
  bool? privateResult;
  // Stores action output result for [Custom Action - isGroupAdmin] action in Group_profile_Details_page widget.
  bool? adminResult;
  // Stores action output result for [Custom Action - changeGroupAvatar] action in IconButton widget.
  bool? avatarChanged;
  // State field(s) for Switch widget.
  bool? switchValue1;
  // Stores action output result for [Custom Action - convertGroupToPrivate] action in Switch widget.
  bool? convert2;
  // Stores action output result for [Custom Action - removePrivateGroup] action in Switch widget.
  bool? removed3;
  // Stores action output result for [Custom Action - removePrivateGroup] action in Switch widget.
  bool? removed4;
  // State field(s) for Switch widget.
  bool? switchValue2;
  // State field(s) for Switch widget.
  bool? switchValue3;
  // State field(s) for Switch widget.
  bool? switchValue4;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
