import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/stories/edit_other_user_stories/edit_other_user_stories_widget.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'users_story_model.dart';
export 'users_story_model.dart';

class UsersStoryWidget extends StatefulWidget {
  const UsersStoryWidget({
    super.key,
    this.storyGroups,
    this.groupIndex,
    this.currentUserId,
  });

  final List<StoryGroupStruct>? storyGroups;
  final int? groupIndex;
  final String? currentUserId;

  static String routeName = 'users_story';
  static String routePath = '/usersStory';

  @override
  State<UsersStoryWidget> createState() => _UsersStoryWidgetState();
}

class _UsersStoryWidgetState extends State<UsersStoryWidget>
    with TickerProviderStateMixin {
  late UsersStoryModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  var hasTextTriggered1 = false;
  var hasTextTriggered2 = false;
  var hasIconTriggered = false;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UsersStoryModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    animationsMap.addAll({
      'textOnActionTriggerAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.0, -61.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'textOnActionTriggerAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.0, -61.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'iconOnActionTriggerAnimation': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.0, -61.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
    });
    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
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
        title: 'users_story',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: custom_widgets.StoryPlayer(
                          width: double.infinity,
                          height: double.infinity,
                          viewerId: widget.currentUserId!,
                          items: FFAppState()
                              .friendsStoriesList
                              .elementAtOrNull(widget.groupIndex!)!
                              .items,
                          startIndex: 0,
                          isOwnStory: false,
                          onFinishedGroup: () async {
                            if (functions.hasNextGroup(widget.groupIndex!,
                                FFAppState().friendsStoriesList.length)) {
                              if (Navigator.of(context).canPop()) {
                                context.pop();
                              }
                              context.pushNamed(
                                UsersStoryWidget.routeName,
                                queryParameters: {
                                  'groupIndex': serializeParam(
                                    functions
                                        .nextGroupIndex(widget.groupIndex!),
                                    ParamType.int,
                                  ),
                                  'currentUserId': serializeParam(
                                    widget.currentUserId,
                                    ParamType.String,
                                  ),
                                }.withoutNulls,
                              );
                            } else {
                              context.safePop();
                            }
                          },
                          onExitToPrevious: () async {
                            if (widget.groupIndex! > 0) {
                              if (Navigator.of(context).canPop()) {
                                context.pop();
                              }
                              context.pushNamed(
                                UsersStoryWidget.routeName,
                                queryParameters: {
                                  'groupIndex': serializeParam(
                                    functions.previousGroupIndex(
                                        widget.groupIndex!),
                                    ParamType.int,
                                  ),
                                  'currentUserId': serializeParam(
                                    widget.currentUserId,
                                    ParamType.String,
                                  ),
                                }.withoutNulls,
                              );
                            } else {
                              context.safePop();
                            }
                          },
                          onIndexChanged: (index) async {
                            _model.currentStoryItemIndex = index;
                            safeSetState(() {});
                          },
                        ),
                      ),
                      Stack(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment:
                                (FFMainAxisAlignment.spaceBetween).flutterValue,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 25.0, 16.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            width: 55.0,
                                            height: 55.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: cachedNetworkImage(
                                                  valueOrDefault<String>(
                                                    '${FFAppState().friendsStoriesList.elementAtOrNull(widget.groupIndex!)?.avatarUrl}',
                                                    'https://plus.unsplash.com/premium_photo-1689551670902-19b441a6afde?q=80&w=387&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                                                  ),
                                                ).image,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 10.0,
                                                  color: Color(0x33000000),
                                                  offset: Offset(
                                                    0.0,
                                                    0.0,
                                                  ),
                                                )
                                              ],
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Flexible(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    valueOrDefault<String>(
                                                      FFAppState()
                                                          .friendsStoriesList
                                                          .elementAtOrNull(
                                                              widget
                                                                  .groupIndex!)
                                                          ?.fullName,
                                                      'Mr Kesta Wealth',
                                                    ),
                                                    maxLines: 1,
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      fontSize: 16.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                      shadows: [
                                                        Shadow(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          offset:
                                                              Offset(1.0, 1.0),
                                                          blurRadius: 2.0,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  dateTimeFormat(
                                                    "relative",
                                                    FFAppState()
                                                        .friendsStoriesList
                                                        .elementAtOrNull(widget
                                                            .groupIndex!)!
                                                        .items
                                                        .elementAtOrNull(0)!
                                                        .createdAt!,
                                                    locale: FFLocalizations.of(
                                                            context)
                                                        .languageCode,
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
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
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
                                                    shadows: [
                                                      Shadow(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        offset:
                                                            Offset(1.0, 1.0),
                                                        blurRadius: 2.0,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ].divide(SizedBox(height: 5.0)),
                                            ),
                                          ),
                                        ].divide(SizedBox(width: 10.0)),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
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
                                                    padding:
                                                        MediaQuery.viewInsetsOf(
                                                            context),
                                                    child:
                                                        EditOtherUserStoriesWidget(),
                                                  ),
                                                );
                                              },
                                            ).then(
                                                (value) => safeSetState(() {}));
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 35.0,
                                                  color: Color(0x33000000),
                                                  offset: Offset(
                                                    0.0,
                                                    0.0,
                                                  ),
                                                )
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.keyboard_control,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              size: 24.0,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            context.pop();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 35.0,
                                                  color: Color(0x33000000),
                                                  offset: Offset(
                                                    0.0,
                                                    0.0,
                                                  ),
                                                )
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              size: 24.0,
                                            ),
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 35.0)),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 80.0,
                                decoration: BoxDecoration(
                                  color: Color(0x7FE0E3E7),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25.0),
                                    topRight: Radius.circular(25.0),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(2.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            10.0, 10.0, 10.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            if ((FFAppState()
                                                        .friendsStoriesList
                                                        .elementAtOrNull(
                                                            widget.groupIndex!)
                                                        ?.items
                                                        .elementAtOrNull(_model
                                                            .currentStoryItemIndex))
                                                    ?.commentsEnabled ==
                                                true)
                                              Expanded(
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: Color(0x7FE0E3E7),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0),
                                                    border: Border.all(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(5.0, 2.0,
                                                                15.0, 2.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          (FFCrossAxisAlignment
                                                                  .center)
                                                              .flutterValue,
                                                      textBaseline: TextBaseline
                                                          .alphabetic,
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            child:
                                                                TextFormField(
                                                              controller: _model
                                                                  .textController,
                                                              focusNode: _model
                                                                  .textFieldFocusNode,
                                                              autofocus: false,
                                                              enabled: true,
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
                                                                  'ei78t12t' /* Share your thoughts... */,
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
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
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
                                                                    width: 1.0,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                ),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: Color(
                                                                        0x00000000),
                                                                    width: 1.0,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                ),
                                                                errorBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .error,
                                                                    width: 1.0,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                ),
                                                                focusedErrorBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .error,
                                                                    width: 1.0,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
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
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
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
                                                              maxLines: 3,
                                                              minLines: 1,
                                                              cursorColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                              enableInteractiveSelection:
                                                                  true,
                                                              validator: _model
                                                                  .textControllerValidator
                                                                  .asValidator(
                                                                      context),
                                                            ),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          splashColor: Colors
                                                              .transparent,
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () async {
                                                            await actions
                                                                .sendStoryInteraction(
                                                              currentUserUid,
                                                              FFAppState()
                                                                  .friendsStoriesList
                                                                  .elementAtOrNull(
                                                                      widget
                                                                          .groupIndex!)!
                                                                  .userId,
                                                              FFAppState()
                                                                  .friendsStoriesList
                                                                  .elementAtOrNull(
                                                                      widget
                                                                          .groupIndex!)!
                                                                  .items
                                                                  .elementAtOrNull(
                                                                      _model
                                                                          .currentStoryItemIndex)!
                                                                  .id,
                                                              (FFAppState()
                                                                      .friendsStoriesList
                                                                      .elementAtOrNull(
                                                                          widget
                                                                              .groupIndex!)
                                                                      ?.items
                                                                      .elementAtOrNull(
                                                                          _model
                                                                              .currentStoryItemIndex))
                                                                  ?.mediaUrl,
                                                              (FFAppState()
                                                                      .friendsStoriesList
                                                                      .elementAtOrNull(
                                                                          widget
                                                                              .groupIndex!)
                                                                      ?.items
                                                                      .elementAtOrNull(
                                                                          _model
                                                                              .currentStoryItemIndex))
                                                                  ?.mediaType,
                                                              _model
                                                                  .textController
                                                                  .text,
                                                            );
                                                            safeSetState(() {
                                                              _model
                                                                  .textController
                                                                  ?.clear();
                                                            });
                                                          },
                                                          child: Icon(
                                                            Icons.send_outlined,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                            size: 24.0,
                                                          ),
                                                        ),
                                                      ].divide(SizedBox(
                                                          width: 10.0)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            Container(
                                              width: 40.0,
                                              height: 40.0,
                                              decoration: BoxDecoration(
                                                color: Color(0x7FE0E3E7),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .alternate,
                                                ),
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await actions
                                                        .sendStoryInteraction(
                                                      currentUserUid,
                                                      FFAppState()
                                                          .friendsStoriesList
                                                          .elementAtOrNull(
                                                              widget
                                                                  .groupIndex!)!
                                                          .userId,
                                                      FFAppState()
                                                          .friendsStoriesList
                                                          .elementAtOrNull(
                                                              widget
                                                                  .groupIndex!)!
                                                          .items
                                                          .elementAtOrNull(_model
                                                              .currentStoryItemIndex)!
                                                          .id,
                                                      (FFAppState()
                                                              .friendsStoriesList
                                                              .elementAtOrNull(
                                                                  widget
                                                                      .groupIndex!)
                                                              ?.items
                                                              .elementAtOrNull(
                                                                  _model
                                                                      .currentStoryItemIndex))
                                                          ?.mediaUrl,
                                                      (FFAppState()
                                                              .friendsStoriesList
                                                              .elementAtOrNull(
                                                                  widget
                                                                      .groupIndex!)
                                                              ?.items
                                                              .elementAtOrNull(
                                                                  _model
                                                                      .currentStoryItemIndex))
                                                          ?.mediaType,
                                                      '😂',
                                                    );
                                                  },
                                                  child: Text(
                                                    FFLocalizations.of(context)
                                                        .getText(
                                                      '8kn59kjt' /* 😂 */,
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
                                                          fontSize: 24.0,
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
                                                ).animateOnActionTrigger(
                                                    animationsMap[
                                                        'textOnActionTriggerAnimation1']!,
                                                    hasBeenTriggered:
                                                        hasTextTriggered1),
                                              ),
                                            ),
                                            Container(
                                              width: 40.0,
                                              height: 40.0,
                                              decoration: BoxDecoration(
                                                color: Color(0x7FE0E3E7),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .alternate,
                                                ),
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await actions
                                                        .sendStoryInteraction(
                                                      currentUserUid,
                                                      FFAppState()
                                                          .friendsStoriesList
                                                          .elementAtOrNull(
                                                              widget
                                                                  .groupIndex!)!
                                                          .userId,
                                                      FFAppState()
                                                          .friendsStoriesList
                                                          .elementAtOrNull(
                                                              widget
                                                                  .groupIndex!)!
                                                          .items
                                                          .elementAtOrNull(_model
                                                              .currentStoryItemIndex)!
                                                          .id,
                                                      (FFAppState()
                                                              .friendsStoriesList
                                                              .elementAtOrNull(
                                                                  widget
                                                                      .groupIndex!)
                                                              ?.items
                                                              .elementAtOrNull(
                                                                  _model
                                                                      .currentStoryItemIndex))
                                                          ?.mediaUrl,
                                                      (FFAppState()
                                                              .friendsStoriesList
                                                              .elementAtOrNull(
                                                                  widget
                                                                      .groupIndex!)
                                                              ?.items
                                                              .elementAtOrNull(
                                                                  _model
                                                                      .currentStoryItemIndex))
                                                          ?.mediaType,
                                                      '❤️',
                                                    );
                                                  },
                                                  child: Text(
                                                    FFLocalizations.of(context)
                                                        .getText(
                                                      'vjxl3r1b' /* ❤️ */,
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
                                                          fontSize: 24.0,
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
                                                ).animateOnActionTrigger(
                                                    animationsMap[
                                                        'textOnActionTriggerAnimation2']!,
                                                    hasBeenTriggered:
                                                        hasTextTriggered2),
                                              ),
                                            ),
                                            Container(
                                              width: 40.0,
                                              height: 40.0,
                                              decoration: BoxDecoration(
                                                color: Color(0x7FE0E3E7),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .alternate,
                                                ),
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await actions
                                                        .sendStoryInteraction(
                                                      currentUserUid,
                                                      FFAppState()
                                                          .friendsStoriesList
                                                          .elementAtOrNull(
                                                              widget
                                                                  .groupIndex!)!
                                                          .userId,
                                                      FFAppState()
                                                          .friendsStoriesList
                                                          .elementAtOrNull(
                                                              widget
                                                                  .groupIndex!)!
                                                          .items
                                                          .elementAtOrNull(_model
                                                              .currentStoryItemIndex)!
                                                          .id,
                                                      (FFAppState()
                                                              .friendsStoriesList
                                                              .elementAtOrNull(
                                                                  widget
                                                                      .groupIndex!)
                                                              ?.items
                                                              .elementAtOrNull(
                                                                  _model
                                                                      .currentStoryItemIndex))
                                                          ?.mediaUrl,
                                                      (FFAppState()
                                                              .friendsStoriesList
                                                              .elementAtOrNull(
                                                                  widget
                                                                      .groupIndex!)
                                                              ?.items
                                                              .elementAtOrNull(
                                                                  _model
                                                                      .currentStoryItemIndex))
                                                          ?.mediaType,
                                                      '✌️',
                                                    );
                                                  },
                                                  child: FaIcon(
                                                    FaIconData(const IconData(
                                                        /* solidHandPeace */ 0xf25b,
                                                        fontFamily:
                                                            'FontAwesomeSolid',
                                                        fontPackage:
                                                            'font_awesome_flutter')),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    size: 24.0,
                                                  ),
                                                ).animateOnActionTrigger(
                                                    animationsMap[
                                                        'iconOnActionTriggerAnimation']!,
                                                    hasBeenTriggered:
                                                        hasIconTriggered),
                                              ),
                                            ),
                                          ].divide(SizedBox(width: 5.0)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
