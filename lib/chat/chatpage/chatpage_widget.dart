import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/components/media_library_sheet_component_widget.dart';
import '/components/web_chat_image_send_sheet_widget_widget.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:async';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'chatpage_model.dart';
export 'chatpage_model.dart';

class ChatpageWidget extends StatefulWidget {
  const ChatpageWidget({
    super.key,
    required this.conversationId,
    this.otherUserId,
    required this.displayName,
    required this.displayAvatar,
    this.initialTargetMessageId,
    this.replyingToMessageId,
    this.replyToContent,
    this.replyingToIsOwn,
    bool? startSearch,
  }) : this.startSearch = startSearch ?? false;

  final String? conversationId;
  final String? otherUserId;
  final String? displayName;
  final String? displayAvatar;
  final String? initialTargetMessageId;
  final String? replyingToMessageId;
  final String? replyToContent;
  final bool? replyingToIsOwn;
  final bool startSearch;

  static String routeName = 'chatpage';
  static String routePath = '/chatpage';

  @override
  State<ChatpageWidget> createState() => _ChatpageWidgetState();
}

class _ChatpageWidgetState extends State<ChatpageWidget> {
  late ChatpageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatpageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await actions.showGlobalCallBanner();
      await actions.markConversationAsRead(
        widget.conversationId!,
        currentUserUid,
      );
      _model.lockResult = await actions.isPrivateLocked(
        widget.conversationId!,
      );
      _model.isPrivateLocked = _model.lockResult!;
      safeSetState(() {});
      _model.otherUserProfileResult = await ProfilesTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'id',
          widget.otherUserId,
        ),
      );
      _model.otherUserProfile =
          _model.otherUserProfileResult?.elementAtOrNull(0);
      safeSetState(() {});
      if (widget.startSearch == true) {
        _model.isSearching = true;
        safeSetState(() {});
      }
    });

    _model.textFieldMessageMoodTextController ??= TextEditingController();
    _model.textFieldMessageMoodFocusNode ??= FocusNode();
    _model.textFieldMessageMoodFocusNode!.addListener(
      () async {
        if ((_model.textFieldMessageMoodFocusNode?.hasFocus ?? false) == true) {
          _model.showMediaPicker = false;
          safeSetState(() {});
          safeSetState(() {});
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Title(
        title: 'chatpage',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            drawer: Drawer(
              elevation: 16.0,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(15.0, 20.0, 15.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 20.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GradientText(
                            FFLocalizations.of(context).getText(
                              'ct1gmsne' /* SchatzApp */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontSize: 32.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                            colors: [
                              Color(0xFFD239EF),
                              FlutterFlowTheme.of(context).secondary
                            ],
                            gradientDirection: GradientDirection.ltr,
                            gradientType: GradientType.linear,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: custom_widgets.ChatDrawerList(
                          width: double.infinity,
                          height: double.infinity,
                          currentUserId: currentUserUid,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          20.0, 15.0, 20.0, 25.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment:
                            (FFMainAxisAlignment.center).flutterValue,
                        children: [
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.goNamed(
                                HomePageWidget.routeName,
                                extra: <String, dynamic>{
                                  '__transition_info__': TransitionInfo(
                                    hasTransition: true,
                                    transitionType: PageTransitionType.fade,
                                    duration: Duration(milliseconds: 0),
                                  ),
                                },
                              );
                            },
                            child: FaIcon(
                              FaIconData(const IconData(/* comment */ 0xf075,
                                  fontFamily: 'FontAwesomeRegular',
                                  fontPackage: 'font_awesome_flutter')),
                              color: FlutterFlowTheme.of(context).primary,
                              size: 28.0,
                            ),
                          ),
                          Icon(
                            Icons.call_outlined,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 28.0,
                          ),
                          FaIcon(
                            FaIconData(const IconData(/* wallet */ 0xf555,
                                fontFamily: 'FontAwesomeSolid',
                                fontPackage: 'font_awesome_flutter')),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 28.0,
                          ),
                          FaIcon(
                            FaIconData(const IconData(/* hornbill */ 0xf592,
                                fontFamily: 'FontAwesomeBrands',
                                fontPackage: 'font_awesome_flutter')),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 28.0,
                          ),
                        ].divide(SizedBox(width: 38.0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            appBar: AppBar(
              backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (_model.isSearching == false)
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (_model.isPrivateLocked == false)
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            scaffoldKey.currentState!
                                                .openDrawer();
                                          },
                                          child: Icon(
                                            Icons.sort,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            size: 30.0,
                                          ),
                                        ),
                                      if (_model.isPrivateLocked == true)
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            context.safePop();
                                          },
                                          child: Icon(
                                            Icons.arrow_back,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            size: 30.0,
                                          ),
                                        ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            15.0, 0.0, 15.0, 0.0),
                                        child: Stack(
                                          alignment:
                                              AlignmentDirectional(1.0, 1.0),
                                          children: [
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                context.pushNamed(
                                                  UserProfileWidget.routeName,
                                                  queryParameters: {
                                                    'otherUserId':
                                                        serializeParam(
                                                      widget.otherUserId,
                                                      ParamType.String,
                                                    ),
                                                  }.withoutNulls,
                                                  extra: <String, dynamic>{
                                                    '__transition_info__':
                                                        TransitionInfo(
                                                      hasTransition: true,
                                                      transitionType:
                                                          PageTransitionType
                                                              .fade,
                                                      duration: Duration(
                                                          milliseconds: 0),
                                                    ),
                                                  },
                                                );
                                              },
                                              child: Container(
                                                width: 50.0,
                                                height: 50.0,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Container(
                                                  width: 50.0,
                                                  height: 50.0,
                                                  child: custom_widgets
                                                      .UserAvatarWidget(
                                                    width: 50.0,
                                                    height: 50.0,
                                                    avatarUrl:
                                                        valueOrDefault<String>(
                                                      widget.displayAvatar,
                                                      'https://plus.unsplash.com/premium_photo-1689551670902-19b441a6afde?q=80&w=387&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                                                    ),
                                                    displayName:
                                                        valueOrDefault<String>(
                                                      widget.displayName,
                                                      'Name',
                                                    ),
                                                    radius: 25.0,
                                                    userId: widget.otherUserId,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (_model.otherUserProfile
                                                    ?.isOnline ==
                                                true)
                                              Container(
                                                width: 13.0,
                                                height: 13.0,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF2FFB4B),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    width: 2.0,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 15.0, 0.0),
                                          child: InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              context.pushNamed(
                                                UserProfileWidget.routeName,
                                                queryParameters: {
                                                  'otherUserId': serializeParam(
                                                    widget.otherUserId,
                                                    ParamType.String,
                                                  ),
                                                }.withoutNulls,
                                                extra: <String, dynamic>{
                                                  '__transition_info__':
                                                      TransitionInfo(
                                                    hasTransition: true,
                                                    transitionType:
                                                        PageTransitionType.fade,
                                                    duration: Duration(
                                                        milliseconds: 0),
                                                  ),
                                                },
                                              );
                                            },
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    valueOrDefault<String>(
                                                      widget.displayName,
                                                      'Emma Johnson Mr Kesta Wealth 234',
                                                    ),
                                                    maxLines: 1,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .plusJakartaSans(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          fontSize: 15.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (_model.otherUserProfile
                                                        ?.isOnline ==
                                                    true)
                                                  Text(
                                                    FFLocalizations.of(context)
                                                        .getText(
                                                      '5hpucbuz' /* Online */,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .plusJakartaSans(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color:
                                                              Color(0xFF2FFB4B),
                                                          fontSize: 12.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                              ].divide(SizedBox(height: 5.0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 10.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      if (_model.isPrivateLocked == false)
                                        FlutterFlowIconButton(
                                          borderRadius: 8.0,
                                          buttonSize: 40.0,
                                          icon: Icon(
                                            Icons.videocam_outlined,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            size: 24.0,
                                          ),
                                          onPressed: () async {
                                            _model.callResult =
                                                await actions.startCall(
                                              widget.conversationId!,
                                              currentUserUid,
                                              'video',
                                            );
                                            if (_model.callResult != null) {
                                              context.pushNamed(
                                                ActiveCallScreenWidget
                                                    .routeName,
                                                queryParameters: {
                                                  'callId': serializeParam(
                                                    _model.callResult?.callId,
                                                    ParamType.String,
                                                  ),
                                                  'conversationId':
                                                      serializeParam(
                                                    widget.conversationId,
                                                    ParamType.String,
                                                  ),
                                                  'calleeName': serializeParam(
                                                    widget.displayName,
                                                    ParamType.String,
                                                  ),
                                                  'calleeAvatar':
                                                      serializeParam(
                                                    widget.displayAvatar,
                                                    ParamType.String,
                                                  ),
                                                  'callType': serializeParam(
                                                    'video',
                                                    ParamType.String,
                                                  ),
                                                  'agoraChannelName':
                                                      serializeParam(
                                                    _model.callResult
                                                        ?.agoraChannelName,
                                                    ParamType.String,
                                                  ),
                                                  'agoraToken': serializeParam(
                                                    _model
                                                        .callResult?.agoraToken,
                                                    ParamType.String,
                                                  ),
                                                  'agoraUid': serializeParam(
                                                    _model.callResult?.agoraUid,
                                                    ParamType.int,
                                                  ),
                                                }.withoutNulls,
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Couldn\'t start the call, please try again',
                                                    style: TextStyle(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                    ),
                                                  ),
                                                  duration: Duration(
                                                      milliseconds: 4000),
                                                  backgroundColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                ),
                                              );
                                            }

                                            safeSetState(() {});
                                          },
                                        ),
                                      if (_model.isPrivateLocked == false)
                                        FlutterFlowIconButton(
                                          borderRadius: 8.0,
                                          buttonSize: 40.0,
                                          icon: Icon(
                                            Icons.phone_outlined,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            size: 24.0,
                                          ),
                                          onPressed: () async {
                                            _model.callResult2 =
                                                await actions.startCall(
                                              widget.conversationId!,
                                              currentUserUid,
                                              'voice',
                                            );
                                            if (_model.callResult2 != null) {
                                              context.pushNamed(
                                                ActiveCallScreenWidget
                                                    .routeName,
                                                queryParameters: {
                                                  'callId': serializeParam(
                                                    _model.callResult2?.callId,
                                                    ParamType.String,
                                                  ),
                                                  'conversationId':
                                                      serializeParam(
                                                    widget.conversationId,
                                                    ParamType.String,
                                                  ),
                                                  'calleeName': serializeParam(
                                                    widget.displayName,
                                                    ParamType.String,
                                                  ),
                                                  'calleeAvatar':
                                                      serializeParam(
                                                    widget.displayAvatar,
                                                    ParamType.String,
                                                  ),
                                                  'callType': serializeParam(
                                                    'voice',
                                                    ParamType.String,
                                                  ),
                                                  'agoraChannelName':
                                                      serializeParam(
                                                    _model.callResult2
                                                        ?.agoraChannelName,
                                                    ParamType.String,
                                                  ),
                                                  'agoraToken': serializeParam(
                                                    _model.callResult2
                                                        ?.agoraToken,
                                                    ParamType.String,
                                                  ),
                                                  'agoraUid': serializeParam(
                                                    _model
                                                        .callResult2?.agoraUid,
                                                    ParamType.int,
                                                  ),
                                                }.withoutNulls,
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Couldn\'t start the call, please try again',
                                                    style: TextStyle(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                    ),
                                                  ),
                                                  duration: Duration(
                                                      milliseconds: 4000),
                                                  backgroundColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                ),
                                              );
                                            }

                                            safeSetState(() {});
                                          },
                                        ),
                                      if (_model.isPrivateLocked == true)
                                        FlutterFlowIconButton(
                                          borderRadius: 8.0,
                                          buttonSize: 40.0,
                                          icon: Icon(
                                            Icons.notifications_none_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            size: 24.0,
                                          ),
                                          onPressed: () async {
                                            _model.bimpSent =
                                                await actions.sendBimp(
                                              widget.conversationId!,
                                              currentUserUid,
                                            );
                                            if (_model.bimpSent == true) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Bimp sent',
                                                    style: TextStyle(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                    ),
                                                  ),
                                                  duration: Duration(
                                                      milliseconds: 4000),
                                                  backgroundColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Could not send Bimp',
                                                    style: TextStyle(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                    ),
                                                  ),
                                                  duration: Duration(
                                                      milliseconds: 4000),
                                                  backgroundColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                ),
                                              );
                                            }

                                            safeSetState(() {});
                                          },
                                        ),
                                    ].divide(SizedBox(width: 20.0)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_model.isSearching == true)
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(),
                              child: Container(
                                width: double.infinity,
                                height: 45.0,
                                child: custom_widgets.ChatSearchField(
                                  width: double.infinity,
                                  height: 45.0,
                                  onQueryChanged: (query) async {
                                    _model.searchQuery = query;
                                    safeSetState(() {});
                                  },
                                  onClose: () async {
                                    _model.isSearching = false;
                                    safeSetState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [],
              centerTitle: true,
              elevation: 0.0,
            ),
            body: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).transparent,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(),
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: custom_widgets.ChatThread(
                                    width: double.infinity,
                                    height: double.infinity,
                                    conversationId: widget.conversationId!,
                                    currentUserId: currentUserUid,
                                    otherDisplayName: widget.displayName!,
                                    otherUserId: widget.otherUserId!,
                                    currentUserPhoneNumber: currentPhoneNumber,
                                    initialTargetMessageId:
                                        widget.initialTargetMessageId,
                                    searchActive: _model.isSearching,
                                    searchQuery: _model.searchQuery,
                                    onReply: (messageId, content, isOwn) async {
                                      _model.replyingToMessageId = messageId;
                                      safeSetState(() {});
                                      _model.replyingToContent = content;
                                      safeSetState(() {});
                                      _model.replyingToIsOwn = isOwn;
                                      safeSetState(() {});
                                    },
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 1.51),
                                child: Stack(
                                  children: [
                                    if ((FFAppState().chatBlocked == false) &&
                                        (_model.isSearching == false))
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 1.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  15.0, 5.0, 15.0, 10.0),
                                          child: Material(
                                            color: Colors.transparent,
                                            elevation: 0.0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                            child: Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
                                                border: Border.all(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  width: 2.0,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (_model.replyingToMessageId !=
                                                          null &&
                                                      _model.replyingToMessageId !=
                                                          '')
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  5.0,
                                                                  5.0,
                                                                  0.0,
                                                                  0.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          5.0,
                                                                          0.0,
                                                                          5.0,
                                                                          0.0),
                                                              child: Container(
                                                                width: 308.1,
                                                                height: 57.0,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Color(
                                                                      0xFFD2E5F8),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20.0),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              5.0),
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                4.0,
                                                                                0.0,
                                                                                0.0,
                                                                                0.0),
                                                                            child:
                                                                                Text(
                                                                              valueOrDefault<String>(
                                                                                _model.replyingToIsOwn == true ? 'You' : widget.displayName,
                                                                                'Yours',
                                                                              ),
                                                                              maxLines: 1,
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    font: GoogleFonts.plusJakartaSans(
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                                    color: Color(0xFF071496),
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                          InkWell(
                                                                            splashColor:
                                                                                Colors.transparent,
                                                                            focusColor:
                                                                                Colors.transparent,
                                                                            hoverColor:
                                                                                Colors.transparent,
                                                                            highlightColor:
                                                                                Colors.transparent,
                                                                            onTap:
                                                                                () async {
                                                                              _model.replyingToMessageId = null;
                                                                              safeSetState(() {});
                                                                              _model.replyingToContent = null;
                                                                              safeSetState(() {});
                                                                              _model.replyingToIsOwn = false;
                                                                              safeSetState(() {});
                                                                              safeSetState(() {});
                                                                            },
                                                                            child:
                                                                                Icon(
                                                                              Icons.close,
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            4.0,
                                                                            0.0,
                                                                            5.0,
                                                                            0.0),
                                                                        child:
                                                                            Text(
                                                                          valueOrDefault<
                                                                              String>(
                                                                            _model.replyingToContent,
                                                                            'Replying to chat message',
                                                                          ),
                                                                          maxLines:
                                                                              1,
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.plusJakartaSans(
                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        height:
                                                                            3.0)),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  if (_model
                                                      .pendingWebChatImages
                                                      .isNotEmpty)
                                                    Container(
                                                      width: double.infinity,
                                                      height: 74.0,
                                                      child: custom_widgets
                                                          .PendingImageStrip(
                                                        width: double.infinity,
                                                        height: 74.0,
                                                        images: _model
                                                            .pendingWebChatImages,
                                                        onRemove:
                                                            (index) async {
                                                          _model.pendingWebChatImages = functions
                                                              .removeImageAtIndex(
                                                                  _model
                                                                      .pendingWebChatImages
                                                                      .toList(),
                                                                  index)
                                                              .toList()
                                                              .cast<
                                                                  PendingWebImageStruct>();
                                                          safeSetState(() {});
                                                        },
                                                        onUpdated:
                                                            (updatedImages) async {
                                                          _model.pendingWebChatImages =
                                                              updatedImages
                                                                  .toList()
                                                                  .cast<
                                                                      PendingWebImageStruct>();
                                                          safeSetState(() {});
                                                        },
                                                      ),
                                                    ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(15.0, 0.0,
                                                                15.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        if (_model
                                                                .showMediaPicker ==
                                                            false)
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        12.0),
                                                            child: InkWell(
                                                              splashColor: Colors
                                                                  .transparent,
                                                              focusColor: Colors
                                                                  .transparent,
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              onTap: () async {
                                                                if (isWeb ==
                                                                    true) {
                                                                  _model.pickedImages =
                                                                      await actions
                                                                          .pickMultipleWebChatMedia();
                                                                  _model.pendingWebChatImages = _model
                                                                      .pickedImages!
                                                                      .toList()
                                                                      .cast<
                                                                          PendingWebImageStruct>();
                                                                  safeSetState(
                                                                      () {});
                                                                } else {
                                                                  _model.showMediaPicker =
                                                                      !_model
                                                                          .showMediaPicker;
                                                                  safeSetState(
                                                                      () {});
                                                                }

                                                                safeSetState(
                                                                    () {});
                                                              },
                                                              child: Icon(
                                                                Icons.add,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                size: 26.0,
                                                              ),
                                                            ),
                                                          ),
                                                        if (() {
                                                          if (_model
                                                                  .showMediaPicker ==
                                                              false) {
                                                            return false;
                                                          } else if (_model
                                                                  .hasStagedMedia ==
                                                              false) {
                                                            return true;
                                                          } else {
                                                            return false;
                                                          }
                                                        }())
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        10.0),
                                                            child: InkWell(
                                                              splashColor: Colors
                                                                  .transparent,
                                                              focusColor: Colors
                                                                  .transparent,
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              onTap: () async {
                                                                _model.showMediaPicker =
                                                                    !_model
                                                                        .showMediaPicker;
                                                                safeSetState(
                                                                    () {});
                                                              },
                                                              child: Icon(
                                                                Icons.keyboard,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                size: 26.0,
                                                              ),
                                                            ),
                                                          ),
                                                        if (_model
                                                                .stagedMediaUrls
                                                                .length >
                                                            0)
                                                          Container(
                                                            width: 40.0,
                                                            height: 40.0,
                                                            child: custom_widgets
                                                                .StagedMediaPreview(
                                                              width: 40.0,
                                                              height: 40.0,
                                                              existingSelectedPaths:
                                                                  _model
                                                                      .stagedMediaUrls,
                                                              onRemove:
                                                                  (assetId) async {
                                                                _model
                                                                    .removeFromStagedMediaUrls(
                                                                        assetId);
                                                                _model.hasStagedMedia =
                                                                    false;
                                                                safeSetState(
                                                                    () {});
                                                              },
                                                              onUpdated:
                                                                  (updatedIdentifiers) async {
                                                                _model
                                                                    .stagedMediaUrls = (updatedIdentifiers
                                                                        as List)
                                                                    .map<String>(
                                                                        (e) => e
                                                                            .toString())
                                                                    .toList()
                                                                    .cast<
                                                                        String>()
                                                                    .toList()
                                                                    .cast<
                                                                        String>();
                                                                safeSetState(
                                                                    () {});
                                                              },
                                                              onAllRemoved:
                                                                  () async {
                                                                _model.hasStagedMedia =
                                                                    false;
                                                                safeSetState(
                                                                    () {});
                                                              },
                                                            ),
                                                          ),
                                                        Expanded(
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            child:
                                                                TextFormField(
                                                              controller: _model
                                                                  .textFieldMessageMoodTextController,
                                                              focusNode: _model
                                                                  .textFieldMessageMoodFocusNode,
                                                              onChanged: (_) =>
                                                                  EasyDebounce
                                                                      .debounce(
                                                                '_model.textFieldMessageMoodTextController',
                                                                Duration(
                                                                    milliseconds:
                                                                        0),
                                                                () async {
                                                                  safeSetState(
                                                                      () {});
                                                                  await actions
                                                                      .handleComposerTyping(
                                                                    widget
                                                                        .conversationId!,
                                                                    currentUserUid,
                                                                  );
                                                                },
                                                              ),
                                                              autofocus: false,
                                                              enabled: true,
                                                              textCapitalization:
                                                                  TextCapitalization
                                                                      .sentences,
                                                              obscureText:
                                                                  false,
                                                              decoration:
                                                                  InputDecoration(
                                                                isDense: true,
                                                                labelStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .plusJakartaSans(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .fontStyle,
                                                                    ),
                                                                hintText:
                                                                    FFLocalizations.of(
                                                                            context)
                                                                        .getText(
                                                                  'lf3b2nd5' /* Enter chatting mood */,
                                                                ),
                                                                hintStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .plusJakartaSans(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .fontStyle,
                                                                    ),
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: Color(
                                                                        0x00000000),
                                                                    width: 0.0,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(),
                                                                ),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: Color(
                                                                        0x00000000),
                                                                    width: 0.0,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(),
                                                                ),
                                                                errorBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .error,
                                                                    width: 0.0,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(),
                                                                ),
                                                                focusedErrorBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .error,
                                                                    width: 0.0,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(),
                                                                ),
                                                              ),
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .plusJakartaSans(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                              maxLines: 5,
                                                              minLines: 1,
                                                              maxLength: 6000,
                                                              maxLengthEnforcement:
                                                                  MaxLengthEnforcement
                                                                      .none,
                                                              buildCounter: (context,
                                                                      {required currentLength,
                                                                      required isFocused,
                                                                      maxLength}) =>
                                                                  null,
                                                              cursorColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                              enableInteractiveSelection:
                                                                  true,
                                                              validator: _model
                                                                  .textFieldMessageMoodTextControllerValidator
                                                                  .asValidator(
                                                                      context),
                                                              inputFormatters: [
                                                                if (!isAndroid &&
                                                                    !isiOS)
                                                                  TextInputFormatter
                                                                      .withFunction(
                                                                          (oldValue,
                                                                              newValue) {
                                                                    return TextEditingValue(
                                                                      selection:
                                                                          newValue
                                                                              .selection,
                                                                      text: newValue
                                                                          .text
                                                                          .toCapitalization(
                                                                              TextCapitalization.sentences),
                                                                    );
                                                                  }),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        if (functions.shouldShowSendIcon(
                                                                _model
                                                                    .textFieldMessageMoodTextController
                                                                    .text,
                                                                _model
                                                                    .stagedMediaUrls
                                                                    .length,
                                                                _model
                                                                    .pendingWebChatImages
                                                                    .length) ==
                                                            false)
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        10.0),
                                                            child: InkWell(
                                                              splashColor: Colors
                                                                  .transparent,
                                                              focusColor: Colors
                                                                  .transparent,
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              onTap: () async {
                                                                _model.isRecordingVoice =
                                                                    true;
                                                                safeSetState(
                                                                    () {});
                                                                safeSetState(
                                                                    () {});
                                                              },
                                                              child: Icon(
                                                                Icons.mic_none,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                size: 26.0,
                                                              ),
                                                            ),
                                                          ),
                                                        if (() {
                                                          if (_model
                                                                  .isSending ==
                                                              true) {
                                                            return false;
                                                          } else if (functions.shouldShowSendIcon(
                                                              _model
                                                                  .textFieldMessageMoodTextController
                                                                  .text,
                                                              _model
                                                                  .stagedMediaUrls
                                                                  .length,
                                                              _model
                                                                  .pendingWebChatImages
                                                                  .length)!) {
                                                            return true;
                                                          } else {
                                                            return false;
                                                          }
                                                        }())
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        10.0),
                                                            child: InkWell(
                                                              splashColor: Colors
                                                                  .transparent,
                                                              focusColor: Colors
                                                                  .transparent,
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              onTap: () async {
                                                                if (_model
                                                                    .pendingWebChatImages
                                                                    .isNotEmpty) {
                                                                  unawaited(
                                                                    () async {
                                                                      _model.sendError =
                                                                          await actions
                                                                              .sendPendingWebChatImages(
                                                                        widget
                                                                            .conversationId!,
                                                                        currentUserUid,
                                                                        _model
                                                                            .pendingWebChatImages
                                                                            .toList(),
                                                                        _model
                                                                            .textFieldMessageMoodTextController
                                                                            .text,
                                                                        _model
                                                                            .replyingToMessageId,
                                                                        _model
                                                                            .replyingToContent,
                                                                        _model
                                                                            .replyingToIsOwn,
                                                                      );
                                                                    }(),
                                                                  );
                                                                  _model.pendingWebChatImages =
                                                                      [];
                                                                  safeSetState(
                                                                      () {});
                                                                  _model.replyingToMessageId =
                                                                      '';
                                                                  _model.replyingToContent =
                                                                      '';
                                                                  _model.replyingToIsOwn =
                                                                      false;
                                                                  safeSetState(
                                                                      () {});
                                                                  safeSetState(
                                                                      () {
                                                                    _model
                                                                        .textFieldMessageMoodTextController
                                                                        ?.clear();
                                                                  });
                                                                } else {
                                                                  if (_model
                                                                          .isSending !=
                                                                      true) {
                                                                    _model.isSending =
                                                                        true;
                                                                    safeSetState(
                                                                        () {});
                                                                    if ((_model
                                                                            .stagedMediaUrls
                                                                            .isNotEmpty) ==
                                                                        true) {
                                                                      _model.uploadedImageUrls =
                                                                          await actions
                                                                              .uploadStagedAssetsWithEdits(
                                                                        _model
                                                                            .stagedMediaUrls
                                                                            .toList(),
                                                                      );
                                                                      await actions
                                                                          .sendStagedImageMessages(
                                                                        widget
                                                                            .conversationId!,
                                                                        currentUserUid,
                                                                        _model
                                                                            .uploadedImageUrls!
                                                                            .toList(),
                                                                        _model
                                                                            .textFieldMessageMoodTextController
                                                                            .text,
                                                                        _model.replyingToMessageId != null &&
                                                                                _model.replyingToMessageId != ''
                                                                            ? _model.replyingToMessageId
                                                                            : '',
                                                                        _model.replyingToMessageId != null &&
                                                                                _model.replyingToMessageId != ''
                                                                            ? _model.replyingToContent
                                                                            : '',
                                                                        _model.replyingToMessageId != null &&
                                                                                _model.replyingToMessageId != ''
                                                                            ? _model.replyingToIsOwn
                                                                            : false,
                                                                      );
                                                                      _model.replyingToMessageId =
                                                                          null;
                                                                      safeSetState(
                                                                          () {});
                                                                      _model.replyingToContent =
                                                                          null;
                                                                      safeSetState(
                                                                          () {});
                                                                      _model.replyingToIsOwn =
                                                                          false;
                                                                      safeSetState(
                                                                          () {});
                                                                      _model.showMediaPicker =
                                                                          false;
                                                                      _model.stagedMediaUrls =
                                                                          [];
                                                                      _model.hasStagedMedia =
                                                                          false;
                                                                      safeSetState(
                                                                          () {});
                                                                      safeSetState(
                                                                          () {
                                                                        _model
                                                                            .textFieldMessageMoodTextController
                                                                            ?.clear();
                                                                      });
                                                                      _model.isSending =
                                                                          false;
                                                                      safeSetState(
                                                                          () {});
                                                                    } else {
                                                                      await actions
                                                                          .sendTextMessage(
                                                                        widget
                                                                            .conversationId!,
                                                                        currentUserUid,
                                                                        _model
                                                                            .textFieldMessageMoodTextController
                                                                            .text,
                                                                        _model
                                                                            .replyingToMessageId,
                                                                        _model
                                                                            .replyingToContent,
                                                                        _model
                                                                            .replyingToIsOwn,
                                                                      );
                                                                      _model.replyingToMessageId =
                                                                          null;
                                                                      safeSetState(
                                                                          () {});
                                                                      _model.replyingToContent =
                                                                          null;
                                                                      safeSetState(
                                                                          () {});
                                                                      _model.replyingToIsOwn =
                                                                          false;
                                                                      safeSetState(
                                                                          () {});
                                                                      safeSetState(
                                                                          () {
                                                                        _model
                                                                            .textFieldMessageMoodTextController
                                                                            ?.clear();
                                                                      });
                                                                      _model.isSending =
                                                                          false;
                                                                      safeSetState(
                                                                          () {});
                                                                    }
                                                                  }
                                                                }

                                                                safeSetState(
                                                                    () {});
                                                              },
                                                              child: Icon(
                                                                Icons
                                                                    .send_outlined,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                size: 26.0,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (_model.isRecordingVoice == true)
                                      Container(
                                        height: 70.0,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20.0),
                                            topRight: Radius.circular(20.0),
                                          ),
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          height: 60.0,
                                          child:
                                              custom_widgets.VoiceRecorderBar(
                                            width: double.infinity,
                                            height: 60.0,
                                            onCancel: () async {
                                              _model.isRecordingVoice = false;
                                              safeSetState(() {});
                                              safeSetState(() {});
                                            },
                                            onSend: (filePath,
                                                durationSeconds) async {
                                              _model.voiceNoteUrl =
                                                  await actions.uploadVoiceNote(
                                                filePath,
                                              );
                                              if (_model.voiceNoteUrl != null &&
                                                  _model.voiceNoteUrl != '') {
                                                await MessagesTable().insert({
                                                  'conversation_id':
                                                      widget.conversationId,
                                                  'sender_id': currentUserUid,
                                                  'message_type': 'voice_note',
                                                  'media_url':
                                                      _model.voiceNoteUrl,
                                                  'duration_seconds':
                                                      durationSeconds,
                                                });
                                                _model.isRecordingVoice = false;
                                                safeSetState(() {});
                                                safeSetState(() {});
                                              }

                                              safeSetState(() {});
                                            },
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1.0,
                                height: 1.0,
                                child: custom_widgets.PrivateScreenGuard(
                                  width: 1.0,
                                  height: 1.0,
                                  enabled: _model.isPrivateLocked,
                                ),
                              ),
                              Container(
                                width: 1.0,
                                height: 1.0,
                                child: custom_widgets.BlockStatusBar(
                                  width: 1.0,
                                  height: 1.0,
                                  otherUserId: widget.otherUserId!,
                                  showBanner: false,
                                ),
                              ),
                              if (FFAppState().chatBlocked == true)
                                Align(
                                  alignment: AlignmentDirectional(0.0, 1.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        12.0, 0.0, 12.0, 0.0),
                                    child: Container(
                                      width: double.infinity,
                                      height: 64.0,
                                      child: custom_widgets.BlockStatusBar(
                                        width: double.infinity,
                                        height: 64.0,
                                        otherUserId: widget.otherUserId!,
                                        showBanner: true,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_model.showMediaPicker == true)
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        FFLocalizations.of(context).getText(
                                          'bwl6wk0d' /* Photos */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              fontSize: 15.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          if (isWeb == true) {
                                            await showModalBottomSheet(
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              enableDrag: false,
                                              context: context,
                                              builder: (context) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus();
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        MediaQuery.viewInsetsOf(
                                                            context),
                                                    child: Container(
                                                      height: MediaQuery.sizeOf(
                                                                  context)
                                                              .height *
                                                          0.85,
                                                      child:
                                                          WebChatImageSendSheetWidgetWidget(
                                                        conversationId: widget
                                                            .conversationId,
                                                        senderId:
                                                            currentUserUid,
                                                        replyToMessageId: _model
                                                            .replyingToMessageId,
                                                        replyToContent: _model
                                                            .replyingToContent,
                                                        replyToIsOwn: _model
                                                            .replyingToIsOwn,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ).then(
                                                (value) => safeSetState(() {}));
                                          } else {
                                            await showModalBottomSheet(
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              enableDrag: false,
                                              context: context,
                                              builder: (context) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus();
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        MediaQuery.viewInsetsOf(
                                                            context),
                                                    child: Container(
                                                      height: MediaQuery.sizeOf(
                                                                  context)
                                                              .height *
                                                          0.85,
                                                      child:
                                                          MediaLibrarySheetComponentWidget(
                                                        currentSelection: _model
                                                            .stagedMediaUrls,
                                                        onSelectionChanged:
                                                            (selectedPaths) async {
                                                          _model.stagedMediaUrls =
                                                              selectedPaths
                                                                  .toList()
                                                                  .cast<
                                                                      String>();
                                                          safeSetState(() {});
                                                        },
                                                        onClose: () async {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        onSend: (selectedPaths,
                                                            caption) async {
                                                          _model.uploadedImageUrls2 =
                                                              await actions
                                                                  .uploadStagedAssets(
                                                            selectedPaths
                                                                .toList(),
                                                          );
                                                          await actions
                                                              .sendStagedImageMessages(
                                                            widget
                                                                .conversationId!,
                                                            currentUserUid,
                                                            _model
                                                                .uploadedImageUrls2!
                                                                .toList(),
                                                            caption,
                                                            _model.replyingToMessageId !=
                                                                        null &&
                                                                    _model.replyingToMessageId !=
                                                                        ''
                                                                ? _model
                                                                    .replyingToMessageId
                                                                : '',
                                                            _model.replyingToMessageId !=
                                                                        null &&
                                                                    _model.replyingToMessageId !=
                                                                        ''
                                                                ? _model
                                                                    .replyingToContent
                                                                : '',
                                                            _model.replyingToMessageId !=
                                                                        null &&
                                                                    _model.replyingToMessageId !=
                                                                        ''
                                                                ? _model
                                                                    .replyingToIsOwn
                                                                : false,
                                                          );
                                                          _model.replyingToMessageId =
                                                              null;
                                                          safeSetState(() {});
                                                          _model.replyingToContent =
                                                              null;
                                                          safeSetState(() {});
                                                          _model.replyingToIsOwn =
                                                              false;
                                                          safeSetState(() {});
                                                          _model.stagedMediaUrls =
                                                              [];
                                                          _model.hasStagedMedia =
                                                              false;
                                                          safeSetState(() {});
                                                          Navigator.pop(
                                                              context);
                                                          safeSetState(() {});
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ).then(
                                                (value) => safeSetState(() {}));
                                          }

                                          safeSetState(() {});
                                        },
                                        child: Text(
                                          FFLocalizations.of(context).getText(
                                            'fo2a61et' /* Show All */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                fontSize: 13.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 100.0,
                                    child: custom_widgets.DeviceGalleryGrid(
                                      width: double.infinity,
                                      height: 100.0,
                                      existingSelectedPaths:
                                          _model.stagedMediaUrls,
                                      onSelectionChanged:
                                          (selectedPaths) async {
                                        _model.stagedMediaUrls = selectedPaths
                                            .toList()
                                            .cast<String>();
                                        safeSetState(() {});
                                        _model.hasStagedMedia =
                                            selectedPaths.isNotEmpty;
                                        safeSetState(() {});
                                      },
                                      onCameraTap: () async {
                                        _model.newCameraAssetId = await actions
                                            .captureAndSaveCameraPhoto();
                                        if (_model.newCameraAssetId != null &&
                                            _model.newCameraAssetId != '') {
                                          _model.addToStagedMediaUrls(
                                              _model.newCameraAssetId!);
                                          _model.hasStagedMedia = true;
                                          safeSetState(() {});
                                        }

                                        safeSetState(() {});
                                      },
                                    ),
                                  ),
                                  Divider(
                                    height: 1.0,
                                    thickness: 1.0,
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 10.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (_model.isPrivateLocked == false)
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              await actions.pickAndSendDocument(
                                                widget.conversationId!,
                                                currentUserUid,
                                              );
                                            },
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Container(
                                                  width: 45.0,
                                                  height: 30.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                  child: Icon(
                                                    Icons
                                                        .insert_drive_file_outlined,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 24.0,
                                                  ),
                                                ),
                                                Text(
                                                  FFLocalizations.of(context)
                                                      .getText(
                                                    'di5s3mwr' /* Document */,
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        fontSize: 10.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ].divide(SizedBox(height: 5.0)),
                                            ),
                                          ),
                                        if (_model.isPrivateLocked == false)
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 45.0,
                                                height: 30.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                                child: Icon(
                                                  Icons.location_on_outlined,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 24.0,
                                                ),
                                              ),
                                              Text(
                                                FFLocalizations.of(context)
                                                    .getText(
                                                  'n8rfbrsy' /* Location */,
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .plusJakartaSans(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          fontSize: 10.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ),
                                            ].divide(SizedBox(height: 5.0)),
                                          ),
                                        if (_model.isPrivateLocked == false)
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 45.0,
                                                height: 30.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                                child: Icon(
                                                  Icons
                                                      .cancel_schedule_send_outlined,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 24.0,
                                                ),
                                              ),
                                              Text(
                                                FFLocalizations.of(context)
                                                    .getText(
                                                  'ipnzvtc2' /* Schedule message */,
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .plusJakartaSans(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          fontSize: 10.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ),
                                            ].divide(SizedBox(height: 5.0)),
                                          ),
                                        if (_model.isPrivateLocked == false)
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 45.0,
                                                height: 30.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                                child: Icon(
                                                  Icons.account_circle_outlined,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 24.0,
                                                ),
                                              ),
                                              Text(
                                                FFLocalizations.of(context)
                                                    .getText(
                                                  '3eh38mav' /* Share Contact */,
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .plusJakartaSans(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          fontSize: 10.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ),
                                            ].divide(SizedBox(height: 5.0)),
                                          ),
                                      ],
                                    ),
                                  ),
                                ].divide(SizedBox(height: 10.0)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
