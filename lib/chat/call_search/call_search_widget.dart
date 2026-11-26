import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'call_search_model.dart';
export 'call_search_model.dart';

class CallSearchWidget extends StatefulWidget {
  const CallSearchWidget({super.key});

  static String routeName = 'call_search';
  static String routePath = '/callSearch';

  @override
  State<CallSearchWidget> createState() => _CallSearchWidgetState();
}

class _CallSearchWidgetState extends State<CallSearchWidget> {
  late CallSearchModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CallSearchModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
    });

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

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
        title: 'call_search',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: SafeArea(
              top: true,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 0.0, 16.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 10.0, 0.0, 10.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 45.0,
                                  decoration: BoxDecoration(
                                    color: Color(0x2CE0E3E7),
                                    borderRadius: BorderRadius.circular(22.0),
                                    border: Border.all(
                                      color: Color(0xFFB0C2D0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            10.0, 0.0, 10.0, 0.0),
                                        child: Icon(
                                          Icons.search,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          size: 24.0,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          width: 200.0,
                                          child: TextFormField(
                                            controller: _model.textController,
                                            focusNode:
                                                _model.textFieldFocusNode,
                                            autofocus: false,
                                            enabled: true,
                                            autofillHints: [AutofillHints.name],
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              isDense: false,
                                              labelStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                              hintText:
                                                  FFLocalizations.of(context)
                                                      .getText(
                                                'de1aa9j4' /* Search contact */,
                                              ),
                                              hintStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .override(
                                                        font: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 0.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 0.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 0.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 0.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            style: FlutterFlowTheme.of(context)
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
                                            maxLength: 30,
                                            maxLengthEnforcement:
                                                MaxLengthEnforcement.enforced,
                                            buildCounter: (context,
                                                    {required currentLength,
                                                    required isFocused,
                                                    maxLength}) =>
                                                null,
                                            cursorColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            enableInteractiveSelection: true,
                                            validator: _model
                                                .textControllerValidator
                                                .asValidator(context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 10.0, 0.0, 10.0),
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.pop();
                                },
                                child: Container(
                                  width: 45.0,
                                  height: 45.0,
                                  decoration: BoxDecoration(
                                    color: Color(0x2CE0E3E7),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(0xFFB0C2D0),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.close,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 30.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ].divide(SizedBox(width: 15.0)),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(15.0, 0.0, 15.0, 0.0),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (context) {
                              final callHistoryItem =
                                  _model.callHistoryList.toList();

                              return ListView.builder(
                                padding: EdgeInsets.zero,
                                primary: false,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: callHistoryItem.length,
                                itemBuilder: (context, callHistoryItemIndex) {
                                  final callHistoryItemItem =
                                      callHistoryItem[callHistoryItemIndex];
                                  return Visibility(
                                    visible: functions.chatRowMatchesSearch(
                                        callHistoryItemItem.otherPartyName,
                                        _model.textController.text,
                                        'all',
                                        callHistoryItemIndex,
                                        callHistoryItemItem.callType,
                                        false),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 25.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 55.0,
                                                height: 55.0,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                ),
                                                child: cachedNetworkImage(
                                                  valueOrDefault<String>(
                                                    '${callHistoryItemItem.otherPartyAvatar}',
                                                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTuTHMouALM9GtFV92ULCO9KzgU-wSj3lyUHD1wwSlQwLylW3ma4zqU8Ms&s=10',
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        15.0, 0.0, 0.0, 0.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  0.0,
                                                                  5.0),
                                                      child: Text(
                                                        valueOrDefault<String>(
                                                          callHistoryItemItem
                                                              .otherPartyName,
                                                          'Emma Johnson',
                                                        ),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .plusJakartaSans(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                      ),
                                                    ),
                                                    Text(
                                                      valueOrDefault<String>(
                                                        callHistoryItemItem
                                                            .direction,
                                                        'Outgoing',
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
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
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
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: AlignmentDirectional(
                                                  1.0, -1.0),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        15.0, 0.0, 0.0, 0.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      valueOrDefault<String>(
                                                        dateTimeFormat(
                                                          "jm",
                                                          callHistoryItemItem
                                                              .startedAt,
                                                          locale:
                                                              FFLocalizations.of(
                                                                      context)
                                                                  .languageCode,
                                                        ),
                                                        'Time',
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
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                fontSize: 12.0,
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
                                                    if (callHistoryItemItem
                                                            .callType ==
                                                        'voice')
                                                      InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          _model.contactVoiceCallResult =
                                                              await actions
                                                                  .startCall(
                                                            callHistoryItemItem
                                                                .conversationId,
                                                            currentUserUid,
                                                            callHistoryItemItem
                                                                .callType,
                                                          );
                                                          if (_model
                                                                  .contactVoiceCallResult !=
                                                              null) {
                                                            context.pushNamed(
                                                              ActiveCallScreenWidget
                                                                  .routeName,
                                                              queryParameters: {
                                                                'callId':
                                                                    serializeParam(
                                                                  _model
                                                                      .contactVoiceCallResult
                                                                      ?.callId,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'conversationId':
                                                                    serializeParam(
                                                                  callHistoryItemItem
                                                                      .conversationId,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'calleeName':
                                                                    serializeParam(
                                                                  callHistoryItemItem
                                                                      .otherPartyName,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'calleeAvatar':
                                                                    serializeParam(
                                                                  '${callHistoryItemItem.otherPartyAvatar}',
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'callType':
                                                                    serializeParam(
                                                                  callHistoryItemItem
                                                                      .callType,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'agoraChannelName':
                                                                    serializeParam(
                                                                  _model
                                                                      .contactVoiceCallResult
                                                                      ?.agoraChannelName,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'agoraToken':
                                                                    serializeParam(
                                                                  _model
                                                                      .contactVoiceCallResult
                                                                      ?.agoraToken,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'agoraUid':
                                                                    serializeParam(
                                                                  _model
                                                                      .contactVoiceCallResult
                                                                      ?.agoraUid,
                                                                  ParamType.int,
                                                                ),
                                                              }.withoutNulls,
                                                            );
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  'Couldn\'t start the call, please try again',
                                                                  style:
                                                                      TextStyle(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                  ),
                                                                ),
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        4000),
                                                                backgroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                              ),
                                                            );
                                                          }

                                                          safeSetState(() {});
                                                        },
                                                        child: Icon(
                                                          Icons.call_outlined,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          size: 24.0,
                                                        ),
                                                      ),
                                                    if (callHistoryItemItem
                                                            .callType ==
                                                        'video')
                                                      InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          _model.contactVideoCallResult =
                                                              await actions
                                                                  .startCall(
                                                            callHistoryItemItem
                                                                .conversationId,
                                                            currentUserUid,
                                                            'video',
                                                          );
                                                          if (_model
                                                                  .contactVideoCallResult !=
                                                              null) {
                                                            context.pushNamed(
                                                              ActiveCallScreenWidget
                                                                  .routeName,
                                                              queryParameters: {
                                                                'callId':
                                                                    serializeParam(
                                                                  _model
                                                                      .contactVideoCallResult
                                                                      ?.callId,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'conversationId':
                                                                    serializeParam(
                                                                  callHistoryItemItem
                                                                      .conversationId,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'calleeName':
                                                                    serializeParam(
                                                                  callHistoryItemItem
                                                                      .otherPartyName,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'calleeAvatar':
                                                                    serializeParam(
                                                                  '${callHistoryItemItem.otherPartyAvatar}',
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'callType':
                                                                    serializeParam(
                                                                  'video',
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'agoraChannelName':
                                                                    serializeParam(
                                                                  _model
                                                                      .contactVideoCallResult
                                                                      ?.agoraChannelName,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'agoraToken':
                                                                    serializeParam(
                                                                  _model
                                                                      .contactVideoCallResult
                                                                      ?.agoraToken,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'agoraUid':
                                                                    serializeParam(
                                                                  _model
                                                                      .contactVideoCallResult
                                                                      ?.agoraUid,
                                                                  ParamType.int,
                                                                ),
                                                              }.withoutNulls,
                                                            );
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  'Couldn\'t start the call, please try again',
                                                                  style:
                                                                      TextStyle(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                  ),
                                                                ),
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        4000),
                                                                backgroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                              ),
                                                            );
                                                          }

                                                          safeSetState(() {});
                                                        },
                                                        child: Icon(
                                                          Icons
                                                              .videocam_outlined,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          size: 24.0,
                                                        ),
                                                      ),
                                                  ].divide(
                                                      SizedBox(width: 20.0)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 40.0, 0.0, 20.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  FFLocalizations.of(context).getText(
                                    '7xzxpm13' /* Contacts on  */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        fontSize: 15.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                                GradientText(
                                  FFLocalizations.of(context).getText(
                                    'n97mqjzr' /* SchatzApp */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        fontSize: 15.0,
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
                          FutureBuilder<
                              List<ConversationParticipantsDirectoryRow>>(
                            future: ConversationParticipantsDirectoryTable()
                                .queryRows(
                              queryFn: (q) => q
                                  .neqOrNull(
                                    'user_id',
                                    currentUserUid,
                                  )
                                  .order('full_name', ascending: true),
                            ),
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
                              List<ConversationParticipantsDirectoryRow>
                                  listViewConversationParticipantsDirectoryRowList =
                                  snapshot.data!;

                              return ListView.builder(
                                padding: EdgeInsets.zero,
                                primary: false,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    listViewConversationParticipantsDirectoryRowList
                                        .length,
                                itemBuilder: (context, listViewIndex) {
                                  final listViewConversationParticipantsDirectoryRow =
                                      listViewConversationParticipantsDirectoryRowList[
                                          listViewIndex];
                                  return Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 25.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Container(
                                              width: 55.0,
                                              height: 55.0,
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              child: cachedNetworkImage(
                                                valueOrDefault<String>(
                                                  '${listViewConversationParticipantsDirectoryRow.avatarUrl}',
                                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQSx0B9pTygIDAf0Vb9ypFWTtV5QtE4VlNGQ_U7H8u_ZA&s=10',
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      15.0, 0.0, 0.0, 0.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                0.0, 5.0),
                                                    child: Text(
                                                      valueOrDefault<String>(
                                                        listViewConversationParticipantsDirectoryRow
                                                            .fullName,
                                                        'Emma Johnson',
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            font: GoogleFonts
                                                                .plusJakartaSans(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                            ),
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
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  15.0, 0.0, 0.0, 0.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  _model.contactVoiceCallResult1 =
                                                      await actions.startCall(
                                                    listViewConversationParticipantsDirectoryRow
                                                        .conversationId!,
                                                    currentUserUid,
                                                    'voice',
                                                  );
                                                  if (_model
                                                          .contactVoiceCallResult1 !=
                                                      null) {
                                                    context.pushNamed(
                                                      ActiveCallScreenWidget
                                                          .routeName,
                                                      queryParameters: {
                                                        'callId':
                                                            serializeParam(
                                                          _model
                                                              .contactVoiceCallResult1
                                                              ?.callId,
                                                          ParamType.String,
                                                        ),
                                                        'conversationId':
                                                            serializeParam(
                                                          listViewConversationParticipantsDirectoryRow
                                                              .conversationId,
                                                          ParamType.String,
                                                        ),
                                                        'calleeName':
                                                            serializeParam(
                                                          listViewConversationParticipantsDirectoryRow
                                                              .fullName,
                                                          ParamType.String,
                                                        ),
                                                        'calleeAvatar':
                                                            serializeParam(
                                                          '${listViewConversationParticipantsDirectoryRow.avatarUrl}',
                                                          ParamType.String,
                                                        ),
                                                        'callType':
                                                            serializeParam(
                                                          'voice',
                                                          ParamType.String,
                                                        ),
                                                        'agoraChannelName':
                                                            serializeParam(
                                                          _model
                                                              .contactVoiceCallResult1
                                                              ?.agoraChannelName,
                                                          ParamType.String,
                                                        ),
                                                        'agoraToken':
                                                            serializeParam(
                                                          _model
                                                              .contactVoiceCallResult1
                                                              ?.agoraToken,
                                                          ParamType.String,
                                                        ),
                                                        'agoraUid':
                                                            serializeParam(
                                                          _model
                                                              .contactVoiceCallResult1
                                                              ?.agoraUid,
                                                          ParamType.int,
                                                        ),
                                                      }.withoutNulls,
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Couldn\'t start the call, please try again',
                                                          style: TextStyle(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
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
                                                child: Icon(
                                                  Icons.call_outlined,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 24.0,
                                                ),
                                              ),
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  _model.contactVideoCallResult2 =
                                                      await actions.startCall(
                                                    listViewConversationParticipantsDirectoryRow
                                                        .conversationId!,
                                                    currentUserUid,
                                                    'video',
                                                  );
                                                  if (_model
                                                          .contactVideoCallResult2 !=
                                                      null) {
                                                    context.pushNamed(
                                                      ActiveCallScreenWidget
                                                          .routeName,
                                                      queryParameters: {
                                                        'callId':
                                                            serializeParam(
                                                          _model
                                                              .contactVideoCallResult2
                                                              ?.callId,
                                                          ParamType.String,
                                                        ),
                                                        'conversationId':
                                                            serializeParam(
                                                          listViewConversationParticipantsDirectoryRow
                                                              .conversationId,
                                                          ParamType.String,
                                                        ),
                                                        'calleeName':
                                                            serializeParam(
                                                          listViewConversationParticipantsDirectoryRow
                                                              .fullName,
                                                          ParamType.String,
                                                        ),
                                                        'calleeAvatar':
                                                            serializeParam(
                                                          '${listViewConversationParticipantsDirectoryRow.avatarUrl}',
                                                          ParamType.String,
                                                        ),
                                                        'callType':
                                                            serializeParam(
                                                          'video',
                                                          ParamType.String,
                                                        ),
                                                        'agoraChannelName':
                                                            serializeParam(
                                                          _model
                                                              .contactVideoCallResult2
                                                              ?.agoraChannelName,
                                                          ParamType.String,
                                                        ),
                                                        'agoraToken':
                                                            serializeParam(
                                                          _model
                                                              .contactVideoCallResult2
                                                              ?.agoraToken,
                                                          ParamType.String,
                                                        ),
                                                        'agoraUid':
                                                            serializeParam(
                                                          _model
                                                              .contactVideoCallResult2
                                                              ?.agoraUid,
                                                          ParamType.int,
                                                        ),
                                                      }.withoutNulls,
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Couldn\'t start the call, please try again',
                                                          style: TextStyle(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
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
                                                child: Icon(
                                                  Icons.videocam_outlined,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 24.0,
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 35.0)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
