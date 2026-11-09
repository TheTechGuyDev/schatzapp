import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'active_call_screen_model.dart';
export 'active_call_screen_model.dart';

class ActiveCallScreenWidget extends StatefulWidget {
  const ActiveCallScreenWidget({
    super.key,
    this.callId,
    this.conversationId,
    this.calleeName,
    this.calleeAvatar,
    this.callType,
    this.agoraChannelName,
    this.agoraToken,
    this.agoraUid,
  });

  final String? callId;
  final String? conversationId;
  final String? calleeName;
  final String? calleeAvatar;
  final String? callType;
  final String? agoraChannelName;
  final String? agoraToken;
  final int? agoraUid;

  static String routeName = 'ActiveCallScreen';
  static String routePath = '/activeCallScreen';

  @override
  State<ActiveCallScreenWidget> createState() => _ActiveCallScreenWidgetState();
}

class _ActiveCallScreenWidgetState extends State<ActiveCallScreenWidget> {
  late ActiveCallScreenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ActiveCallScreenModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.joinResult = await actions.joinAgoraCall(
        'a7f7c3f7f8f6427a96f33e4808423324',
        widget.agoraChannelName!,
        widget.agoraToken!,
        widget.agoraUid!,
        widget.callType == 'video',
      );
      _model.agoraDebugStatus = _model.joinResult;
      safeSetState(() {});
    });

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
        title: 'ActiveCallScreen',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: Color(0xFDF6F6FB),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              child: custom_widgets.ModernCallView(
                width: double.infinity,
                height: double.infinity,
                callId: widget.callId!,
                conversationId: widget.conversationId!,
                otherUserName: widget.calleeName!,
                otherUserAvatar: widget.calleeAvatar!,
                callType: widget.callType!,
                agoraChannelName: widget.agoraChannelName!,
                connected: false,
              ),
            ),
          ),
        ));
  }
}
