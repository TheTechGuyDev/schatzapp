import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'connected_call_screen_model.dart';
export 'connected_call_screen_model.dart';

class ConnectedCallScreenWidget extends StatefulWidget {
  const ConnectedCallScreenWidget({
    super.key,
    this.callId,
    this.conversationId,
    this.otherUserName,
    this.otherUserAvatar,
    this.callType,
    this.agoraChannelName,
  });

  final String? callId;
  final String? conversationId;
  final String? otherUserName;
  final String? otherUserAvatar;
  final String? callType;
  final String? agoraChannelName;

  static String routeName = 'ConnectedCallScreen';
  static String routePath = '/connectedCallScreen';

  @override
  State<ConnectedCallScreenWidget> createState() =>
      _ConnectedCallScreenWidgetState();
}

class _ConnectedCallScreenWidgetState extends State<ConnectedCallScreenWidget> {
  late ConnectedCallScreenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ConnectedCallScreenModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.isVideoCallDisplay = widget.callType == 'video';
      safeSetState(() {});
      await actions.ensureAgoraJoined(
        widget.agoraChannelName!,
        widget.callType == 'video',
      );
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
        title: 'ConnectedCallScreen',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              child: custom_widgets.ModernCallView(
                width: double.infinity,
                height: double.infinity,
                callId: widget.callId!,
                conversationId: widget.conversationId!,
                otherUserName: widget.otherUserName!,
                otherUserAvatar: widget.otherUserAvatar!,
                callType: widget.callType!,
                agoraChannelName: widget.agoraChannelName!,
                connected: true,
              ),
            ),
          ),
        ));
  }
}
