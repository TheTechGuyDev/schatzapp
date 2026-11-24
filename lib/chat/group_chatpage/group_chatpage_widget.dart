import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/media_library_sheet_component_widget.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'group_chatpage_model.dart';
export 'group_chatpage_model.dart';

class GroupChatpageWidget extends StatefulWidget {
  const GroupChatpageWidget({
    super.key,
    this.groupConversationId,
    this.groupNameParam,
    this.groupAvatarParam,
    this.displayName,
    this.conversationId,
    this.displayAvatar,
    this.initialTargetMessageId,
    bool? startSearch,
  }) : this.startSearch = startSearch ?? false;

  final String? groupConversationId;
  final String? groupNameParam;
  final String? groupAvatarParam;
  final String? displayName;
  final String? conversationId;
  final String? displayAvatar;
  final String? initialTargetMessageId;
  final bool startSearch;

  static String routeName = 'Group_chatpage';
  static String routePath = '/groupChatpage';

  @override
  State<GroupChatpageWidget> createState() => _GroupChatpageWidgetState();
}

class _GroupChatpageWidgetState extends State<GroupChatpageWidget> {
  late GroupChatpageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GroupChatpageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await actions.showGlobalCallBanner();
      _model.summaryResult = await actions.getGroupMemberSummary(
        widget.groupConversationId!,
      );
      _model.memberNamesSummary = _model.summaryResult;
      safeSetState(() {});
      _model.groupParticipantProfilesResult =
          await actions.getGroupParticipantProfiles(
        widget.groupConversationId!,
      );
      _model.groupParticipantProfiles =
          _model.groupParticipantProfilesResult!.toList().cast<ProfilesRow>();
      safeSetState(() {});
      await actions.markConversationAsRead(
        widget.groupConversationId!,
        currentUserUid,
      );
      _model.lockResult2 = await actions.isPrivateLocked(
        widget.groupConversationId!,
      );
      _model.isPrivateLocked = _model.lockResult2!;
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
        title: 'Group_chatpage',
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
                              'ibc8d7ks' /* SchatzApp */,
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
                  if (_model.isSearching == false)
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 15.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      scaffoldKey.currentState!.openDrawer();
                                    },
                                    child: Icon(
                                      Icons.sort,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 30.0,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        15.0, 0.0, 15.0, 0.0),
                                    child: Stack(
                                      alignment: AlignmentDirectional(1.0, 1.0),
                                      children: [
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            context.pushNamed(
                                              GroupProfileDetailsPageWidget
                                                  .routeName,
                                              queryParameters: {
                                                'groupConversationId':
                                                    serializeParam(
                                                  widget.groupConversationId,
                                                  ParamType.String,
                                                ),
                                              }.withoutNulls,
                                              extra: <String, dynamic>{
                                                '__transition_info__':
                                                    TransitionInfo(
                                                  hasTransition: true,
                                                  transitionType:
                                                      PageTransitionType.fade,
                                                  duration:
                                                      Duration(milliseconds: 0),
                                                ),
                                              },
                                            );
                                          },
                                          child: custom_widgets.GroupAvatar(
                                            width: 50.0,
                                            height: 50.0,
                                            imageUrl: widget.groupAvatarParam!,
                                            size: 50.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 10.0, 0.0, 0.0),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          context.pushNamed(
                                            GroupProfileDetailsPageWidget
                                                .routeName,
                                            queryParameters: {
                                              'groupConversationId':
                                                  serializeParam(
                                                widget.groupConversationId,
                                                ParamType.String,
                                              ),
                                            }.withoutNulls,
                                            extra: <String, dynamic>{
                                              '__transition_info__':
                                                  TransitionInfo(
                                                hasTransition: true,
                                                transitionType:
                                                    PageTransitionType.fade,
                                                duration:
                                                    Duration(milliseconds: 0),
                                              ),
                                            },
                                          );
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              valueOrDefault<String>(
                                                widget.groupNameParam,
                                                'Vacation Group',
                                              ),
                                              style:
                                                  FlutterFlowTheme.of(context)
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
                                            ),
                                            Text(
                                              valueOrDefault<String>(
                                                _model.memberNamesSummary,
                                                'Members\' names +1',
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
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
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
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 10.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                if (_model.isPrivateLocked == false)
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      _model.callResult2 =
                                          await actions.startCall(
                                        widget.groupConversationId!,
                                        currentUserUid,
                                        'video',
                                      );
                                      if (_model.callResult2 != null) {
                                        context.pushNamed(
                                          ActiveCallScreenWidget.routeName,
                                          queryParameters: {
                                            'callId': serializeParam(
                                              _model.callResult2?.callId,
                                              ParamType.String,
                                            ),
                                            'conversationId': serializeParam(
                                              widget.groupConversationId,
                                              ParamType.String,
                                            ),
                                            'calleeName': serializeParam(
                                              widget.groupNameParam,
                                              ParamType.String,
                                            ),
                                            'calleeAvatar': serializeParam(
                                              widget.groupAvatarParam,
                                              ParamType.String,
                                            ),
                                            'callType': serializeParam(
                                              'video',
                                              ParamType.String,
                                            ),
                                            'agoraChannelName': serializeParam(
                                              _model.callResult2
                                                  ?.agoraChannelName,
                                              ParamType.String,
                                            ),
                                            'agoraToken': serializeParam(
                                              _model.callResult2?.agoraToken,
                                              ParamType.String,
                                            ),
                                            'agoraUid': serializeParam(
                                              _model.callResult2?.agoraUid,
                                              ParamType.int,
                                            ),
                                          }.withoutNulls,
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Couldn’t start the call, please try again',
                                              style: TextStyle(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                              ),
                                            ),
                                            duration:
                                                Duration(milliseconds: 4000),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondary,
                                          ),
                                        );
                                      }

                                      safeSetState(() {});
                                    },
                                    child: Icon(
                                      Icons.videocam_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 30.0,
                                    ),
                                  ),
                                if (_model.isPrivateLocked == false)
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      _model.callResult =
                                          await actions.startCall(
                                        widget.groupConversationId!,
                                        currentUserUid,
                                        'voice',
                                      );
                                      if (_model.callResult != null) {
                                        context.pushNamed(
                                          ActiveCallScreenWidget.routeName,
                                          queryParameters: {
                                            'callId': serializeParam(
                                              _model.callResult?.callId,
                                              ParamType.String,
                                            ),
                                            'conversationId': serializeParam(
                                              widget.groupConversationId,
                                              ParamType.String,
                                            ),
                                            'calleeName': serializeParam(
                                              widget.groupNameParam,
                                              ParamType.String,
                                            ),
                                            'calleeAvatar': serializeParam(
                                              widget.groupAvatarParam,
                                              ParamType.String,
                                            ),
                                            'callType': serializeParam(
                                              'voice',
                                              ParamType.String,
                                            ),
                                            'agoraChannelName': serializeParam(
                                              _model
                                                  .callResult?.agoraChannelName,
                                              ParamType.String,
                                            ),
                                            'agoraToken': serializeParam(
                                              _model.callResult?.agoraToken,
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
                                              'Couldn’t start the call, please try again',
                                              style: TextStyle(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                              ),
                                            ),
                                            duration:
                                                Duration(milliseconds: 4000),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondary,
                                          ),
                                        );
                                      }

                                      safeSetState(() {});
                                    },
                                    child: Icon(
                                      Icons.call_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 25.0,
                                    ),
                                  ),
                                if (_model.isPrivateLocked == true)
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      _model.bimpSent = await actions.sendBimp(
                                        widget.groupConversationId!,
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
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                              ),
                                            ),
                                            duration:
                                                Duration(milliseconds: 4000),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
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
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                              ),
                                            ),
                                            duration:
                                                Duration(milliseconds: 4000),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondary,
                                          ),
                                        );
                                      }

                                      safeSetState(() {});
                                    },
                                    child: Icon(
                                      Icons.notifications_none,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 24.0,
                                    ),
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
                        width: double.infinity,
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
              actions: [],
              centerTitle: true,
              elevation: 0.0,
            ),
            body: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: StreamBuilder<List<ConversationParticipantsRow>>(
                    stream:
                        _model.wallpapperContainerSupabaseStream ??= SupaFlow
                            .client
                            .from("conversation_participants")
                            .stream(primaryKey: ['id'])
                            .eqOrNull(
                              'participant_key',
                              '${widget.groupConversationId}_${currentUserUid}',
                            )
                            .map((list) => list
                                .map(
                                    (item) => ConversationParticipantsRow(item))
                                .toList()),
                    builder: (context, snapshot) {
                      // Customize what your widget looks like when it's loading.
                      if (!snapshot.hasData) {
                        return Center(
                          child: SizedBox(
                            width: 50.0,
                            height: 50.0,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          ),
                        );
                      }
                      List<ConversationParticipantsRow>
                          wallpapperContainerConversationParticipantsRowList =
                          snapshot.data!;

                      final wallpapperContainerConversationParticipantsRow =
                          wallpapperContainerConversationParticipantsRowList
                                  .isNotEmpty
                              ? wallpapperContainerConversationParticipantsRowList
                                  .first
                              : null;

                      return Container(
                        decoration: BoxDecoration(),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    height:
                                        MediaQuery.sizeOf(context).height * 1.0,
                                    child: custom_widgets.GroupChatThread(
                                      width: MediaQuery.sizeOf(context).width *
                                          1.0,
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                              1.0,
                                      conversationId:
                                          widget.groupConversationId!,
                                      currentUserId: currentUserUid,
                                      currentUserPhoneNumber:
                                          currentPhoneNumber,
                                      initialTargetMessageId:
                                          widget.initialTargetMessageId,
                                      searchActive: _model.isSearching,
                                      searchQuery: _model.searchQuery,
                                      onReply:
                                          (messageId, content, isOwn) async {
                                        _model.replyingToMessageId = messageId;
                                        _model.replyingToContent = FFAppState()
                                            .groupReplyIsOwn
                                            .toString();
                                        safeSetState(() {});
                                      },
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(0.0, 1.0),
                                    child: FutureBuilder<
                                        List<ConversationParticipantsRow>>(
                                      future: ConversationParticipantsTable()
                                          .querySingleRow(
                                        queryFn: (q) => q
                                            .eqOrNull(
                                              'conversation_id',
                                              widget.groupConversationId,
                                            )
                                            .eqOrNull(
                                              'user_id',
                                              currentUserUid,
                                            ),
                                      ),
                                      builder: (context, snapshot) {
                                        // Customize what your widget looks like when it's loading.
                                        if (!snapshot.hasData) {
                                          return Center(
                                            child: SizedBox(
                                              width: 50.0,
                                              height: 50.0,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        List<ConversationParticipantsRow>
                                            stackConversationParticipantsRowList =
                                            snapshot.data!;

                                        final stackConversationParticipantsRow =
                                            stackConversationParticipantsRowList
                                                    .isNotEmpty
                                                ? stackConversationParticipantsRowList
                                                    .first
                                                : null;

                                        return Stack(
                                          children: [
                                            if ((stackConversationParticipantsRow
                                                        ?.leftAt ==
                                                    null) &&
                                                (_model.isSearching == false))
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 1.0),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(15.0, 5.0, 15.0,
                                                          10.0),
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    elevation: 0.0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30.0),
                                                    ),
                                                    child: Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30.0),
                                                        border: Border.all(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          width: 2.0,
                                                        ),
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            (FFMainAxisAlignment
                                                                    .end)
                                                                .flutterValue,
                                                        children: [
                                                          if (_model.replyingToMessageId !=
                                                                  null &&
                                                              _model.replyingToMessageId !=
                                                                  '')
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  width: 308.12,
                                                                  height: 70.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Color(
                                                                        0xFFD2E5F8),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20.0),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            12.0),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              valueOrDefault<String>(
                                                                                _model.replyingToIsOwn == true ? 'You' : widget.displayName,
                                                                                'Yours',
                                                                              ),
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
                                                                            ),
                                                                            InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                _model.replyingToMessageId = null;
                                                                                safeSetState(() {});
                                                                                _model.replyingToContent = null;
                                                                                safeSetState(() {});
                                                                                _model.replyingToIsOwn = false;
                                                                                safeSetState(() {});
                                                                                safeSetState(() {});
                                                                              },
                                                                              child: Icon(
                                                                                Icons.close,
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                size: 24.0,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Text(
                                                                          valueOrDefault<
                                                                              String>(
                                                                            _model.replyingToContent,
                                                                            'MessageMessageMessageMessageMessageMessageMessageMessageMessage',
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
                                                                      ].divide(SizedBox(
                                                                              height: 5.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        15.0,
                                                                        0.0,
                                                                        15.0,
                                                                        0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
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
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            8.0),
                                                                    child:
                                                                        InkWell(
                                                                      splashColor:
                                                                          Colors
                                                                              .transparent,
                                                                      focusColor:
                                                                          Colors
                                                                              .transparent,
                                                                      hoverColor:
                                                                          Colors
                                                                              .transparent,
                                                                      highlightColor:
                                                                          Colors
                                                                              .transparent,
                                                                      onTap:
                                                                          () async {
                                                                        _model.showMediaPicker =
                                                                            !_model.showMediaPicker;
                                                                        safeSetState(
                                                                            () {});
                                                                      },
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .add,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                        size:
                                                                            26.0,
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
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            8.0),
                                                                    child:
                                                                        InkWell(
                                                                      splashColor:
                                                                          Colors
                                                                              .transparent,
                                                                      focusColor:
                                                                          Colors
                                                                              .transparent,
                                                                      hoverColor:
                                                                          Colors
                                                                              .transparent,
                                                                      highlightColor:
                                                                          Colors
                                                                              .transparent,
                                                                      onTap:
                                                                          () async {
                                                                        _model.showMediaPicker =
                                                                            !_model.showMediaPicker;
                                                                        safeSetState(
                                                                            () {});
                                                                      },
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .keyboard,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                        size:
                                                                            26.0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                if (_model
                                                                        .stagedMediaUrls
                                                                        .length >
                                                                    0)
                                                                  Container(
                                                                    width: 40.0,
                                                                    height:
                                                                        40.0,
                                                                    child: custom_widgets
                                                                        .StagedMediaPreview(
                                                                      width:
                                                                          40.0,
                                                                      height:
                                                                          40.0,
                                                                      existingSelectedPaths:
                                                                          _model
                                                                              .stagedMediaUrls,
                                                                      onRemove:
                                                                          (assetId) async {
                                                                        _model.removeFromStagedMediaUrls(
                                                                            assetId);
                                                                        _model.hasStagedMedia =
                                                                            false;
                                                                        safeSetState(
                                                                            () {});
                                                                      },
                                                                      onUpdated:
                                                                          (updatedIdentifiers) async {},
                                                                      onAllRemoved:
                                                                          () async {},
                                                                    ),
                                                                  ),
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    width: double
                                                                        .infinity,
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _model
                                                                              .textFieldMessageMoodTextController,
                                                                      focusNode:
                                                                          _model
                                                                              .textFieldMessageMoodFocusNode,
                                                                      onChanged:
                                                                          (_) =>
                                                                              EasyDebounce.debounce(
                                                                        '_model.textFieldMessageMoodTextController',
                                                                        Duration(
                                                                            milliseconds:
                                                                                0),
                                                                        () async {
                                                                          safeSetState(
                                                                              () {});
                                                                        },
                                                                      ),
                                                                      autofocus:
                                                                          false,
                                                                      enabled:
                                                                          true,
                                                                      obscureText:
                                                                          false,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        isDense:
                                                                            true,
                                                                        labelStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.plusJakartaSans(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                        hintText:
                                                                            FFLocalizations.of(context).getText(
                                                                          'zvrpbrx1' /* Enter chatting mood */,
                                                                        ),
                                                                        hintStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .override(
                                                                              font: GoogleFonts.plusJakartaSans(
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0x00000000),
                                                                            width:
                                                                                0.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.only(),
                                                                        ),
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0x00000000),
                                                                            width:
                                                                                0.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.only(),
                                                                        ),
                                                                        errorBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).error,
                                                                            width:
                                                                                0.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.only(),
                                                                        ),
                                                                        focusedErrorBorder:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).error,
                                                                            width:
                                                                                0.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.only(),
                                                                        ),
                                                                      ),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.plusJakartaSans(
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                      maxLines:
                                                                          5,
                                                                      minLines:
                                                                          1,
                                                                      cursorColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .primaryText,
                                                                      enableInteractiveSelection:
                                                                          true,
                                                                      validator: _model
                                                                          .textFieldMessageMoodTextControllerValidator
                                                                          .asValidator(
                                                                              context),
                                                                    ),
                                                                  ),
                                                                ),
                                                                if (_model.textFieldMessageMoodTextController
                                                                            .text ==
                                                                        '')
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            8.0),
                                                                    child:
                                                                        InkWell(
                                                                      splashColor:
                                                                          Colors
                                                                              .transparent,
                                                                      focusColor:
                                                                          Colors
                                                                              .transparent,
                                                                      hoverColor:
                                                                          Colors
                                                                              .transparent,
                                                                      highlightColor:
                                                                          Colors
                                                                              .transparent,
                                                                      onTap:
                                                                          () async {
                                                                        _model.isRecordingVoice =
                                                                            true;
                                                                        safeSetState(
                                                                            () {});
                                                                        safeSetState(
                                                                            () {});
                                                                      },
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .mic_none,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                        size:
                                                                            26.0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                if (() {
                                                                  if (_model.isSending ==
                                                                      true) {
                                                                    return false;
                                                                  } else if (functions.shouldShowSendIcon(
                                                                      _model
                                                                          .textFieldMessageMoodTextController
                                                                          .text,
                                                                      _model
                                                                          .stagedMediaUrls
                                                                          .length,
                                                                      0)!) {
                                                                    return true;
                                                                  } else {
                                                                    return false;
                                                                  }
                                                                }())
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            8.0),
                                                                    child:
                                                                        InkWell(
                                                                      splashColor:
                                                                          Colors
                                                                              .transparent,
                                                                      focusColor:
                                                                          Colors
                                                                              .transparent,
                                                                      hoverColor:
                                                                          Colors
                                                                              .transparent,
                                                                      highlightColor:
                                                                          Colors
                                                                              .transparent,
                                                                      onTap:
                                                                          () async {
                                                                        if (_model.isSending !=
                                                                            true) {
                                                                          _model.isSending =
                                                                              true;
                                                                          safeSetState(
                                                                              () {});
                                                                          if (_model.stagedMediaUrls.length >
                                                                              0) {
                                                                            _model.uploadedImageUrls =
                                                                                await actions.uploadStagedAssets(
                                                                              _model.stagedMediaUrls.toList(),
                                                                            );
                                                                            await actions.sendStagedImageMessages(
                                                                              widget.groupConversationId!,
                                                                              currentUserUid,
                                                                              _model.uploadedImageUrls!.toList(),
                                                                              _model.textFieldMessageMoodTextController.text,
                                                                              _model.replyingToMessageId != null && _model.replyingToMessageId != '' ? _model.replyingToMessageId : '',
                                                                              _model.replyingToMessageId != null && _model.replyingToMessageId != '' ? _model.replyingToContent : '',
                                                                              _model.replyingToMessageId != null && _model.replyingToMessageId != '' ? _model.replyingToIsOwn : false,
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
                                                                            _model.showMediaPicker =
                                                                                false;
                                                                            _model.stagedMediaUrls =
                                                                                [];
                                                                            _model.hasStagedMedia =
                                                                                false;
                                                                            safeSetState(() {});
                                                                            safeSetState(() {
                                                                              _model.textFieldMessageMoodTextController?.clear();
                                                                            });
                                                                            _model.isSending =
                                                                                false;
                                                                            safeSetState(() {});
                                                                          } else {
                                                                            await actions.sendTextMessage(
                                                                              widget.groupConversationId!,
                                                                              currentUserUid,
                                                                              _model.textFieldMessageMoodTextController.text,
                                                                              _model.replyingToMessageId,
                                                                              _model.replyingToContent,
                                                                              _model.replyingToIsOwn,
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
                                                                            safeSetState(() {
                                                                              _model.textFieldMessageMoodTextController?.clear();
                                                                            });
                                                                            _model.isSending =
                                                                                false;
                                                                            safeSetState(() {});
                                                                          }
                                                                        }

                                                                        safeSetState(
                                                                            () {});
                                                                      },
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .send_outlined,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                        size:
                                                                            26.0,
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
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20.0),
                                                    topRight:
                                                        Radius.circular(20.0),
                                                  ),
                                                ),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 60.0,
                                                  child: custom_widgets
                                                      .VoiceRecorderBar(
                                                    width: double.infinity,
                                                    height: 60.0,
                                                    onCancel: () async {
                                                      _model.isRecordingVoice =
                                                          false;
                                                      safeSetState(() {});
                                                      safeSetState(() {});
                                                    },
                                                    onSend: (filePath,
                                                        durationSeconds) async {
                                                      _model.voiceNoteUrl =
                                                          await actions
                                                              .uploadVoiceNote(
                                                        filePath,
                                                      );
                                                      if (_model.voiceNoteUrl !=
                                                              null &&
                                                          _model.voiceNoteUrl !=
                                                              '') {
                                                        await MessagesTable()
                                                            .insert({
                                                          'conversation_id': widget
                                                              .groupConversationId,
                                                          'sender_id':
                                                              currentUserUid,
                                                          'message_type':
                                                              'voice_note',
                                                          'media_url': _model
                                                              .voiceNoteUrl,
                                                          'duration_seconds':
                                                              durationSeconds,
                                                        });
                                                        _model.isRecordingVoice =
                                                            false;
                                                        safeSetState(() {});
                                                        safeSetState(() {});
                                                      }

                                                      safeSetState(() {});
                                                    },
                                                  ),
                                                ),
                                              ),
                                            if (stackConversationParticipantsRow
                                                    ?.leftAt !=
                                                null)
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 1.0),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 0.0, 0.0, 40.0),
                                                  child: Text(
                                                    FFLocalizations.of(context)
                                                        .getText(
                                                      '09uf67sr' /* You Left This Group Already */,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .plusJakartaSans(
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color:
                                                              Color(0xFF9CF442),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            FFLocalizations.of(context).getText(
                                              'bilzefg7' /* Photos */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  fontSize: 15.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
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
                                                      padding: MediaQuery
                                                          .viewInsetsOf(
                                                              context),
                                                      child: Container(
                                                        height:
                                                            MediaQuery.sizeOf(
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
                                                                  .groupConversationId!,
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
                                              ).then((value) =>
                                                  safeSetState(() {}));

                                              safeSetState(() {});
                                            },
                                            child: Text(
                                              FFLocalizations.of(context)
                                                  .getText(
                                                'oy5suy4i' /* Show All */,
                                              ),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        fontSize: 13.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
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
                                            _model.stagedMediaUrls =
                                                selectedPaths
                                                    .toList()
                                                    .cast<String>();
                                            safeSetState(() {});
                                            _model.hasStagedMedia =
                                                selectedPaths.isNotEmpty;
                                            safeSetState(() {});
                                          },
                                          onCameraTap: () async {
                                            _model.newCameraAssetId =
                                                await actions
                                                    .captureAndSaveCameraPhoto();
                                            if (_model.newCameraAssetId !=
                                                    null &&
                                                _model.newCameraAssetId != '') {
                                              _model.addToStagedMediaUrls(
                                                  _model.newCameraAssetId!);
                                              _model.hasStagedMedia = false;
                                              safeSetState(() {});
                                            }

                                            safeSetState(() {});
                                          },
                                        ),
                                      ),
                                      Divider(
                                        height: 1.0,
                                        thickness: 1.0,
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
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
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  await actions
                                                      .pickAndSendDocument(
                                                    widget
                                                        .groupConversationId!,
                                                    currentUserUid,
                                                  );
                                                },
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Container(
                                                      width: 45.0,
                                                      height: 30.0,
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .primaryBackground,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20.0),
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .insert_drive_file_outlined,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        size: 24.0,
                                                      ),
                                                    ),
                                                    Text(
                                                      FFLocalizations.of(
                                                              context)
                                                          .getText(
                                                        'wg9oo2k1' /* Document */,
                                                      ),
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
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
                                                                fontSize: 10.0,
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
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 5.0)),
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
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .location_on_outlined,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      size: 24.0,
                                                    ),
                                                  ),
                                                  Text(
                                                    FFLocalizations.of(context)
                                                        .getText(
                                                      '6v9cp5i2' /* Location */,
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
                                            if (_model.isPrivateLocked == false)
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Container(
                                                    width: 45.0,
                                                    height: 30.0,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .cancel_schedule_send_outlined,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      size: 24.0,
                                                    ),
                                                  ),
                                                  Text(
                                                    FFLocalizations.of(context)
                                                        .getText(
                                                      'lcbqsh40' /* Schedule message */,
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
                                            if (_model.isPrivateLocked == false)
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Container(
                                                    width: 45.0,
                                                    height: 30.0,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .account_circle_outlined,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      size: 24.0,
                                                    ),
                                                  ),
                                                  Text(
                                                    FFLocalizations.of(context)
                                                        .getText(
                                                      'o5nuqwtd' /* Share Contact */,
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
                                          ],
                                        ),
                                      ),
                                    ].divide(SizedBox(height: 10.0)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
