import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'tag_friends_picker_widget_model.dart';
export 'tag_friends_picker_widget_model.dart';

class TagFriendsPickerWidgetWidget extends StatefulWidget {
  const TagFriendsPickerWidgetWidget({super.key});

  @override
  State<TagFriendsPickerWidgetWidget> createState() =>
      _TagFriendsPickerWidgetWidgetState();
}

class _TagFriendsPickerWidgetWidgetState
    extends State<TagFriendsPickerWidgetWidget> {
  late TagFriendsPickerWidgetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TagFriendsPickerWidgetModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            context.pop();
          },
          child: Container(
            width: double.infinity,
            height: 90.0,
            decoration: BoxDecoration(),
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: custom_widgets.TagFriendsPicker(
                width: double.infinity,
                height: double.infinity,
                currentUserId: currentUserUid,
                onDone: () async {
                  context.safePop();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
