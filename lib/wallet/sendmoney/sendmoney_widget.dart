import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/wallet/sendmoney_final/sendmoney_final_widget.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sendmoney_model.dart';
export 'sendmoney_model.dart';

class SendmoneyWidget extends StatefulWidget {
  const SendmoneyWidget({super.key});

  static String routeName = 'Sendmoney';
  static String routePath = '/sendmoney';

  @override
  State<SendmoneyWidget> createState() => _SendmoneyWidgetState();
}

class _SendmoneyWidgetState extends State<SendmoneyWidget> {
  late SendmoneyModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SendmoneyModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.getOwnWalletCurrencyOutput = await actions.getOwnWalletCurrency(
        currentUserUid,
      );
      _model.senderCurrency = _model.getOwnWalletCurrencyOutput!;
      safeSetState(() {});
      _model.callFxRateNewResult = await actions.callFxRate(
        'EUR',
        _model.senderCurrency,
      );
      _model.senderFxRate = _model.callFxRateNewResult!;
      safeSetState(() {});
      _model.getOwnProfileNameResult = await actions.getOwnProfileName(
        currentUserUid,
      );
      _model.senderName = _model.getOwnProfileNameResult!;
      safeSetState(() {});
      _model.hasPinResult = await actions.checkHasPin();
      if (_model.hasPinResult == false) {
        context.pushNamed(SetPINWidget.routeName);
      }
      _model.senderWalletQuery = await WalletsTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'user_id',
          currentUserUid,
        ),
      );
      _model.senderKycStatus =
          _model.senderWalletQuery!.firstOrNull!.kycStatus!;
      safeSetState(() {});
    });

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.amountTextFieldTextController ??= TextEditingController();
    _model.amountTextFieldFocusNode ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

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
        title: 'Sendmoney',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            automaticallyImplyLeading: false,
            leading: FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 30.0,
              borderWidth: 1.0,
              buttonSize: 60.0,
              icon: Icon(
                Icons.arrow_back_rounded,
                color: FlutterFlowTheme.of(context).primaryText,
                size: 30.0,
              ),
              onPressed: () async {
                context.pop();
              },
            ),
            title: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: (FFCrossAxisAlignment.start).flutterValue,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  FFLocalizations.of(context).getText(
                    'rxhrhj6l' /* Send Money */,
                  ),
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .fontWeight,
                          fontStyle: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).primaryText,
                        fontSize: 22.0,
                        letterSpacing: 0.0,
                        fontWeight: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .fontWeight,
                        fontStyle: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .fontStyle,
                      ),
                ),
                Text(
                  FFLocalizations.of(context).getText(
                    'mo4l7sp6' /* Send money quickly and securel... */,
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
              ].divide(SizedBox(height: 5.0)),
            ),
            actions: [],
            centerTitle: false,
            elevation: 0.0,
          ),
          body: SafeArea(
            top: true,
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          borderRadius: BorderRadius.circular(22.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 85.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      (FFMainAxisAlignment.center).flutterValue,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      FFLocalizations.of(context).getText(
                                        'l5zkovn9' /* Account number / Username */,
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
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        border: Border.all(
                                          color: Color(0xFFD0BFF2),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            10.0, 0.0, 0.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Text(
                                              FFLocalizations.of(context)
                                                  .getText(
                                                'ex56tyvn' /* SFZ */,
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
                                                        fontSize: 22.0,
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
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                child: TextFormField(
                                                  controller:
                                                      _model.textController1,
                                                  focusNode: _model
                                                      .textFieldFocusNode1,
                                                  onChanged: (_) =>
                                                      EasyDebounce.debounce(
                                                    '_model.textController1',
                                                    Duration(
                                                        milliseconds: 2000),
                                                    () async {
                                                      _model.recipientAccountNumber =
                                                          _model.textController1
                                                              .text;
                                                      safeSetState(() {});
                                                      if (functions
                                                              .classifyRecipientInput(
                                                                  _model
                                                                      .textController1
                                                                      .text) ==
                                                          'account') {
                                                        _model.recipientLookupAttempted =
                                                            true;
                                                        safeSetState(() {});
                                                        _model.recipientLookupResult =
                                                            await actions
                                                                .lookupRecipientByAccountNumber(
                                                          'SFZ${_model.textController1.text}',
                                                          currentUserUid,
                                                        );
                                                        if (functions.getJsonFieldAsString(
                                                                _model
                                                                    .recipientLookupResult!,
                                                                '\$.success') ==
                                                            'true') {
                                                          _model.recipientFound =
                                                              true;
                                                          _model.recipientUserId =
                                                              functions.getJsonFieldAsString(
                                                                  _model
                                                                      .recipientLookupResult!,
                                                                  '\$.userId');
                                                          _model.recipientName =
                                                              functions.getJsonFieldAsString(
                                                                  _model
                                                                      .recipientLookupResult!,
                                                                  '\$.fullName');
                                                          _model.recipientAvatarUrl =
                                                              functions.getJsonFieldAsString(
                                                                  _model
                                                                      .recipientLookupResult!,
                                                                  '\$.avatarUrl');
                                                          _model.recipientCurrency =
                                                              functions.getJsonFieldAsString(
                                                                  _model
                                                                      .recipientLookupResult!,
                                                                  '\$.currency');
                                                          _model.recipientInvalid =
                                                              false;
                                                          _model.recipientMatchType =
                                                              'account';
                                                          safeSetState(() {});
                                                          _model.recipientWalletQueryNew =
                                                              await WalletsTable()
                                                                  .queryRows(
                                                            queryFn: (q) =>
                                                                q.eqOrNull(
                                                              'user_id',
                                                              currentUserUid,
                                                            ),
                                                          );
                                                          _model.recipientKycStatus =
                                                              _model
                                                                  .recipientWalletQueryNew!
                                                                  .firstOrNull!
                                                                  .kycStatus!;
                                                          safeSetState(() {});
                                                        } else {
                                                          _model.recipientFound =
                                                              false;
                                                          _model.recipientInvalid =
                                                              true;
                                                          safeSetState(() {});
                                                        }
                                                      } else {
                                                        if (functions.classifyRecipientInput(
                                                                _model
                                                                    .textController1
                                                                    .text) ==
                                                            'username') {
                                                          _model.recipientLookupAttempted =
                                                              true;
                                                          safeSetState(() {});
                                                          _model.usernameLookupResultNew =
                                                              await actions
                                                                  .lookupRecipientByUsername(
                                                            _model
                                                                .textController1
                                                                .text,
                                                            currentUserUid,
                                                          );
                                                          if (functions.getJsonFieldAsString(
                                                                  _model
                                                                      .usernameLookupResultNew!,
                                                                  '\$.success') ==
                                                              'true') {
                                                            _model.recipientFound =
                                                                true;
                                                            _model.recipientUserId =
                                                                functions.getJsonFieldAsString(
                                                                    _model
                                                                        .usernameLookupResultNew!,
                                                                    '\$.userId');
                                                            _model.recipientName =
                                                                functions.getJsonFieldAsString(
                                                                    _model
                                                                        .usernameLookupResultNew!,
                                                                    '\$.fullName');
                                                            _model.recipientAvatarUrl =
                                                                functions.getJsonFieldAsString(
                                                                    _model
                                                                        .usernameLookupResultNew!,
                                                                    '\$.avatarUrl');
                                                            _model.recipientCurrency =
                                                                functions.getJsonFieldAsString(
                                                                    _model
                                                                        .usernameLookupResultNew!,
                                                                    '\$.currency');
                                                            _model.recipientUsername =
                                                                functions.getJsonFieldAsString(
                                                                    _model
                                                                        .usernameLookupResultNew!,
                                                                    '\$.username');
                                                            _model.recipientMatchType =
                                                                'username';
                                                            _model.recipientInvalid =
                                                                false;
                                                            safeSetState(() {});
                                                            _model.recipientWalletQuery =
                                                                await WalletsTable()
                                                                    .queryRows(
                                                              queryFn: (q) =>
                                                                  q.eqOrNull(
                                                                'user_id',
                                                                currentUserUid,
                                                              ),
                                                            );
                                                            _model.recipientKycStatus =
                                                                _model
                                                                    .recipientWalletQuery!
                                                                    .firstOrNull!
                                                                    .kycStatus!;
                                                            safeSetState(() {});
                                                          } else {
                                                            _model.recipientFound =
                                                                false;
                                                            _model.recipientInvalid =
                                                                true;
                                                            safeSetState(() {});
                                                          }
                                                        } else {
                                                          _model.recipientFound =
                                                              false;
                                                          _model.recipientLookupAttempted =
                                                              false;
                                                          _model.recipientInvalid =
                                                              false;
                                                          _model.recipientMatchType =
                                                              ' ';
                                                          safeSetState(() {});
                                                        }
                                                      }

                                                      safeSetState(() {});
                                                    },
                                                  ),
                                                  autofocus: false,
                                                  enabled: true,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    labelStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium
                                                            .override(
                                                              font: GoogleFonts
                                                                  .plusJakartaSans(
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                              ),
                                                              letterSpacing:
                                                                  0.0,
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
                                                        FFLocalizations.of(
                                                                context)
                                                            .getText(
                                                      'f4iycxad' /* Enter schatz account numer / U... */,
                                                    ),
                                                    hintStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium
                                                            .override(
                                                              font: GoogleFonts
                                                                  .plusJakartaSans(
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                              ),
                                                              letterSpacing:
                                                                  0.0,
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
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: FlutterFlowTheme
                                                            .of(context)
                                                        .secondaryBackground,
                                                    suffixIcon:
                                                        _model.textController1!
                                                                .text.isNotEmpty
                                                            ? InkWell(
                                                                onTap:
                                                                    () async {
                                                                  _model
                                                                      .textController1
                                                                      ?.clear();
                                                                  _model.recipientAccountNumber =
                                                                      _model
                                                                          .textController1
                                                                          .text;
                                                                  safeSetState(
                                                                      () {});
                                                                  if (functions.classifyRecipientInput(_model
                                                                          .textController1
                                                                          .text) ==
                                                                      'account') {
                                                                    _model.recipientLookupAttempted =
                                                                        true;
                                                                    safeSetState(
                                                                        () {});
                                                                    _model.recipientLookupResult =
                                                                        await actions
                                                                            .lookupRecipientByAccountNumber(
                                                                      'SFZ${_model.textController1.text}',
                                                                      currentUserUid,
                                                                    );
                                                                    if (functions.getJsonFieldAsString(
                                                                            _model.recipientLookupResult!,
                                                                            '\$.success') ==
                                                                        'true') {
                                                                      _model.recipientFound =
                                                                          true;
                                                                      _model.recipientUserId = functions.getJsonFieldAsString(
                                                                          _model
                                                                              .recipientLookupResult!,
                                                                          '\$.userId');
                                                                      _model.recipientName = functions.getJsonFieldAsString(
                                                                          _model
                                                                              .recipientLookupResult!,
                                                                          '\$.fullName');
                                                                      _model.recipientAvatarUrl = functions.getJsonFieldAsString(
                                                                          _model
                                                                              .recipientLookupResult!,
                                                                          '\$.avatarUrl');
                                                                      _model.recipientCurrency = functions.getJsonFieldAsString(
                                                                          _model
                                                                              .recipientLookupResult!,
                                                                          '\$.currency');
                                                                      _model.recipientInvalid =
                                                                          false;
                                                                      _model.recipientMatchType =
                                                                          'account';
                                                                      safeSetState(
                                                                          () {});
                                                                      _model.recipientWalletQueryNew =
                                                                          await WalletsTable()
                                                                              .queryRows(
                                                                        queryFn:
                                                                            (q) =>
                                                                                q.eqOrNull(
                                                                          'user_id',
                                                                          currentUserUid,
                                                                        ),
                                                                      );
                                                                      _model.recipientKycStatus = _model
                                                                          .recipientWalletQueryNew!
                                                                          .firstOrNull!
                                                                          .kycStatus!;
                                                                      safeSetState(
                                                                          () {});
                                                                    } else {
                                                                      _model.recipientFound =
                                                                          false;
                                                                      _model.recipientInvalid =
                                                                          true;
                                                                      safeSetState(
                                                                          () {});
                                                                    }
                                                                  } else {
                                                                    if (functions.classifyRecipientInput(_model
                                                                            .textController1
                                                                            .text) ==
                                                                        'username') {
                                                                      _model.recipientLookupAttempted =
                                                                          true;
                                                                      safeSetState(
                                                                          () {});
                                                                      _model.usernameLookupResultNew =
                                                                          await actions
                                                                              .lookupRecipientByUsername(
                                                                        _model
                                                                            .textController1
                                                                            .text,
                                                                        currentUserUid,
                                                                      );
                                                                      if (functions.getJsonFieldAsString(
                                                                              _model.usernameLookupResultNew!,
                                                                              '\$.success') ==
                                                                          'true') {
                                                                        _model.recipientFound =
                                                                            true;
                                                                        _model.recipientUserId = functions.getJsonFieldAsString(
                                                                            _model.usernameLookupResultNew!,
                                                                            '\$.userId');
                                                                        _model.recipientName = functions.getJsonFieldAsString(
                                                                            _model.usernameLookupResultNew!,
                                                                            '\$.fullName');
                                                                        _model.recipientAvatarUrl = functions.getJsonFieldAsString(
                                                                            _model.usernameLookupResultNew!,
                                                                            '\$.avatarUrl');
                                                                        _model.recipientCurrency = functions.getJsonFieldAsString(
                                                                            _model.usernameLookupResultNew!,
                                                                            '\$.currency');
                                                                        _model.recipientUsername = functions.getJsonFieldAsString(
                                                                            _model.usernameLookupResultNew!,
                                                                            '\$.username');
                                                                        _model.recipientMatchType =
                                                                            'username';
                                                                        _model.recipientInvalid =
                                                                            false;
                                                                        safeSetState(
                                                                            () {});
                                                                        _model.recipientWalletQuery =
                                                                            await WalletsTable().queryRows(
                                                                          queryFn: (q) =>
                                                                              q.eqOrNull(
                                                                            'user_id',
                                                                            currentUserUid,
                                                                          ),
                                                                        );
                                                                        _model.recipientKycStatus = _model
                                                                            .recipientWalletQuery!
                                                                            .firstOrNull!
                                                                            .kycStatus!;
                                                                        safeSetState(
                                                                            () {});
                                                                      } else {
                                                                        _model.recipientFound =
                                                                            false;
                                                                        _model.recipientInvalid =
                                                                            true;
                                                                        safeSetState(
                                                                            () {});
                                                                      }
                                                                    } else {
                                                                      _model.recipientFound =
                                                                          false;
                                                                      _model.recipientLookupAttempted =
                                                                          false;
                                                                      _model.recipientInvalid =
                                                                          false;
                                                                      _model.recipientMatchType =
                                                                          ' ';
                                                                      safeSetState(
                                                                          () {});
                                                                    }
                                                                  }

                                                                  safeSetState(
                                                                      () {});
                                                                  safeSetState(
                                                                      () {});
                                                                },
                                                                child: Icon(
                                                                  Icons.clear,
                                                                  color: Color(
                                                                      0xFF935CCC),
                                                                  size: 22,
                                                                ),
                                                              )
                                                            : null,
                                                  ),
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
                                                        fontSize: 22.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                  maxLength: 16,
                                                  maxLengthEnforcement:
                                                      MaxLengthEnforcement
                                                          .enforced,
                                                  buildCounter: (context,
                                                          {required currentLength,
                                                          required isFocused,
                                                          maxLength}) =>
                                                      null,
                                                  keyboardType:
                                                      (FFKeyboardType.multiline)
                                                          .flutterValue,
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  enableInteractiveSelection:
                                                      true,
                                                  validator: _model
                                                      .textController1Validator
                                                      .asValidator(context),
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(
                                                            '[a-zA-Z0-9]'))
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(height: 5.0)),
                                ),
                              ),
                            ].divide(SizedBox(height: 2.0)),
                          ),
                        ),
                      ),
                    ),
                    if (_model.recipientMatchType == 'account')
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.task_alt,
                            color: Color(0xFF19D86A),
                            size: 16.0,
                          ),
                          Text(
                            FFLocalizations.of(context).getText(
                              '3ewk1qaf' /* Valid account number */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: Color(0xFF19D86A),
                                  fontSize: 10.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ].divide(SizedBox(width: 5.0)),
                      ),
                    if (_model.recipientMatchType == 'username')
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Color(0xFF19D86A),
                            size: 16.0,
                          ),
                          Text(
                            FFLocalizations.of(context).getText(
                              'toaz5wib' /* Valid Username */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: Color(0xFF19D86A),
                                  fontSize: 10.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ].divide(SizedBox(width: 5.0)),
                      ),
                    if (_model.recipientInvalid == true)
                      Align(
                        alignment: AlignmentDirectional(-1.0, -1.0),
                        child: Text(
                          FFLocalizations.of(context).getText(
                            'pyu7nlvt' /* Invalid account number / Usern... */,
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: Color(0xFFDF1609),
                                    fontSize: 10.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                      ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          borderRadius: BorderRadius.circular(22.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              if (_model.recipientFound == true)
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    height: 73.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: Color(0xFFD0BFF2),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          15.0, 0.0, 10.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            (FFMainAxisAlignment.spaceBetween)
                                                .flutterValue,
                                        children: [
                                          if (_model.recipientFound == true)
                                            Flexible(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    (FFMainAxisAlignment.start)
                                                        .flutterValue,
                                                children: [
                                                  Container(
                                                    width: 50.0,
                                                    height: 50.0,
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: cachedNetworkImage(
                                                      valueOrDefault<String>(
                                                        '${_model.recipientAvatarUrl}',
                                                        'https://plus.unsplash.com/premium_photo-1739786995646-480d5cfd83dc?q=80&w=580&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  15.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            (FFMainAxisAlignment
                                                                    .center)
                                                                .flutterValue,
                                                        crossAxisAlignment:
                                                            (FFCrossAxisAlignment
                                                                    .start)
                                                                .flutterValue,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          Text(
                                                            FFLocalizations.of(
                                                                    context)
                                                                .getText(
                                                              'fkzd1tzq' /* Recipient */,
                                                            ),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .plusJakartaSans(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  fontSize:
                                                                      12.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                          ),
                                                          Text(
                                                            valueOrDefault<
                                                                String>(
                                                              _model
                                                                  .recipientName,
                                                              'Emma John',
                                                            ),
                                                            maxLines: 1,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
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
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          AutoSizeText(
                                                            valueOrDefault<
                                                                String>(
                                                              functions.formatRecipientHandle(
                                                                  _model
                                                                      .recipientMatchType,
                                                                  _model
                                                                      .recipientAccountNumber,
                                                                  _model
                                                                      .recipientUsername),
                                                              'account/username',
                                                            ),
                                                            maxLines: 1,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .plusJakartaSans(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  fontSize:
                                                                      11.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            height: 3.0)),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    20.0, 0.0, 0.0, 0.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  (FFMainAxisAlignment.end)
                                                      .flutterValue,
                                              children: [
                                                Icon(
                                                  Icons.verified_user,
                                                  color: Color(0xFF19D86A),
                                                  size: 16.0,
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          5.0, 0.0, 0.0, 0.0),
                                                  child: Text(
                                                    FFLocalizations.of(context)
                                                        .getText(
                                                      'mn2lk7mg' /* Verified */,
                                                    ),
                                                    maxLines: 1,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .plusJakartaSans(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color:
                                                              Color(0xFF19D86A),
                                                          fontSize: 10.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                    ),
                                  ),
                                ),
                              if (_model.recipientUserId == currentUserUid)
                                Align(
                                  alignment: AlignmentDirectional(-1.0, -1.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 5.0, 0.0, 0.0),
                                    child: Text(
                                      FFLocalizations.of(context).getText(
                                        'ytlsno6n' /* You Can’t Transfer Money to Yo... */,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: Color(0xFFDF1609),
                                            fontSize: 10.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 20.0, 0.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      (FFCrossAxisAlignment.start).flutterValue,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      FFLocalizations.of(context).getText(
                                        'xucfv2an' /* Amount */,
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
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 95.0,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        border: Border.all(
                                          color: Color(0xFFD0BFF2),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            15.0, 0.0, 15.0, 0.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              (FFMainAxisAlignment.spaceEvenly)
                                                  .flutterValue,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  (FFCrossAxisAlignment.center)
                                                      .flutterValue,
                                              textBaseline:
                                                  TextBaseline.alphabetic,
                                              children: [
                                                Icon(
                                                  FFIcons.kschatzToken,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 30.0,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    width: double.infinity,
                                                    child: TextFormField(
                                                      controller: _model
                                                          .amountTextFieldTextController,
                                                      focusNode: _model
                                                          .amountTextFieldFocusNode,
                                                      onChanged: (_) =>
                                                          EasyDebounce.debounce(
                                                        '_model.amountTextFieldTextController',
                                                        Duration(
                                                            milliseconds: 2000),
                                                        () async {
                                                          _model.sfzAmount = functions
                                                              .parseAmountInput(
                                                                  _model
                                                                      .amountTextFieldTextController
                                                                      .text);
                                                          safeSetState(() {});
                                                          if (_model.sfzAmount >
                                                              _model
                                                                  .senderWalletQuery!
                                                                  .firstOrNull!
                                                                  .schatzBalance!) {
                                                            _model.exceedsBalance =
                                                                true;
                                                            safeSetState(() {});
                                                          } else {
                                                            _model.exceedsBalance =
                                                                false;
                                                            safeSetState(() {});
                                                          }

                                                          if (_model.sfzAmount >
                                                              functions
                                                                  .getSingleTransferLimit(
                                                                      _model
                                                                          .senderKycStatus)) {
                                                            _model.exceedsSenderLimit =
                                                                true;
                                                            safeSetState(() {});
                                                          } else {
                                                            _model.exceedsSenderLimit =
                                                                false;
                                                            safeSetState(() {});
                                                          }
                                                        },
                                                      ),
                                                      autofocus: false,
                                                      enabled: true,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .none,
                                                      obscureText: false,
                                                      decoration:
                                                          InputDecoration(
                                                        isDense: true,
                                                        labelStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .plusJakartaSans(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
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
                                                          'ilxw6gjq' /* 10.00-5,000 */,
                                                        ),
                                                        hintStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .plusJakartaSans(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: Color(
                                                                      0x43667781),
                                                                  fontSize:
                                                                      35.0,
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
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0x6FD0BFF2),
                                                            width: 0.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      0.0),
                                                        ),
                                                        focusedBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: Color(
                                                                0xFFD0BFF2),
                                                            width: 0.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      0.0),
                                                        ),
                                                        errorBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .error,
                                                            width: 0.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      0.0),
                                                        ),
                                                        focusedErrorBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .error,
                                                            width: 0.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      0.0),
                                                        ),
                                                        filled: true,
                                                        fillColor: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        suffixIcon: _model
                                                                .amountTextFieldTextController!
                                                                .text
                                                                .isNotEmpty
                                                            ? InkWell(
                                                                onTap:
                                                                    () async {
                                                                  _model
                                                                      .amountTextFieldTextController
                                                                      ?.clear();
                                                                  _model.sfzAmount =
                                                                      functions.parseAmountInput(_model
                                                                          .amountTextFieldTextController
                                                                          .text);
                                                                  safeSetState(
                                                                      () {});
                                                                  if (_model
                                                                          .sfzAmount >
                                                                      _model
                                                                          .senderWalletQuery!
                                                                          .firstOrNull!
                                                                          .schatzBalance!) {
                                                                    _model.exceedsBalance =
                                                                        true;
                                                                    safeSetState(
                                                                        () {});
                                                                  } else {
                                                                    _model.exceedsBalance =
                                                                        false;
                                                                    safeSetState(
                                                                        () {});
                                                                  }

                                                                  if (_model
                                                                          .sfzAmount >
                                                                      functions.getSingleTransferLimit(
                                                                          _model
                                                                              .senderKycStatus)) {
                                                                    _model.exceedsSenderLimit =
                                                                        true;
                                                                    safeSetState(
                                                                        () {});
                                                                  } else {
                                                                    _model.exceedsSenderLimit =
                                                                        false;
                                                                    safeSetState(
                                                                        () {});
                                                                  }

                                                                  safeSetState(
                                                                      () {});
                                                                },
                                                                child: Icon(
                                                                  Icons.clear,
                                                                  color: Color(
                                                                      0xFF935CCC),
                                                                  size: 22,
                                                                ),
                                                              )
                                                            : null,
                                                      ),
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .displayLarge
                                                              .override(
                                                                font: GoogleFonts
                                                                    .plusJakartaSans(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .displayLarge
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .displayLarge
                                                                      .fontStyle,
                                                                ),
                                                                fontSize: 35.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .displayLarge
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .displayLarge
                                                                    .fontStyle,
                                                              ),
                                                      maxLength: 13,
                                                      maxLengthEnforcement:
                                                          MaxLengthEnforcement
                                                              .enforced,
                                                      buildCounter: (context,
                                                              {required currentLength,
                                                              required isFocused,
                                                              maxLength}) =>
                                                          null,
                                                      keyboardType:
                                                          (FFKeyboardType
                                                                  .decimal)
                                                              .flutterValue,
                                                      cursorColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      enableInteractiveSelection:
                                                          true,
                                                      validator: _model
                                                          .amountTextFieldTextControllerValidator
                                                          .asValidator(context),
                                                      inputFormatters: [
                                                        if (!isAndroid &&
                                                            !isiOS)
                                                          TextInputFormatter
                                                              .withFunction(
                                                                  (oldValue,
                                                                      newValue) {
                                                            return TextEditingValue(
                                                              selection: newValue
                                                                  .selection,
                                                              text: newValue
                                                                  .text
                                                                  .toCapitalization(
                                                                      TextCapitalization
                                                                          .none),
                                                            );
                                                          }),
                                                        FilteringTextInputFormatter
                                                            .allow(
                                                                RegExp('[0-9]'))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.0, 0.0),
                                                  child: Text(
                                                    valueOrDefault<String>(
                                                      functions
                                                          .formatSendAmountEquivalent(
                                                              _model.sfzAmount,
                                                              _model
                                                                  .senderCurrency,
                                                              _model
                                                                  .senderFxRate),
                                                      '~N0',
                                                    ),
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
                                                              .secondaryText,
                                                          fontSize: 12.0,
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
                                                Text(
                                                  FFLocalizations.of(context)
                                                      .getText(
                                                    'ci7zphc9' /* ( Estimated ) */,
                                                  ),
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
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        fontSize: 12.0,
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
                                                Icon(
                                                  Icons.error_outline,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 15.0,
                                                ),
                                              ].divide(SizedBox(width: 5.0)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(height: 5.0)),
                                ),
                              ),
                              if (_model.exceedsSenderLimit == true)
                                Align(
                                  alignment: AlignmentDirectional(-1.0, -1.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 5.0, 0.0, 0.0),
                                    child: Text(
                                      FFLocalizations.of(context).getText(
                                        'zu38yqw9' /* Transaction Limit Exceeded. */,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: Color(0xFFDF1609),
                                            fontSize: 10.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                  ),
                                ),
                              if (_model.exceedsBalance == true)
                                Align(
                                  alignment: AlignmentDirectional(-1.0, -1.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 5.0, 0.0, 0.0),
                                    child: Text(
                                      FFLocalizations.of(context).getText(
                                        '0q31fuwz' /* Insufficient Funds */,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: Color(0xFFDF1609),
                                            fontSize: 10.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                  ),
                                ),
                              if (_model.exceedsTopUpLimit == true)
                                Align(
                                  alignment: AlignmentDirectional(-1.0, -1.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 5.0, 0.0, 0.0),
                                    child: Text(
                                      FFLocalizations.of(context).getText(
                                        '9i0tfpcl' /* Transaction Amount Exceeds Rec... */,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: Color(0xFFDF1609),
                                            fontSize: 10.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 20.0, 0.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          _model.sfzAmount = 50.0;
                                          safeSetState(() {});
                                          safeSetState(() {
                                            _model.amountTextFieldTextController
                                                ?.text = '50';
                                          });
                                        },
                                        child: Container(
                                          width: 90.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                            color: Color(0x2F935CCC),
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            border: Border.all(
                                              color: Color(0xFFD0BFF2),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(3.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  (FFMainAxisAlignment.center)
                                                      .flutterValue,
                                              children: [
                                                Icon(
                                                  FFIcons.kschatzToken,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 16.0,
                                                ),
                                                Text(
                                                  FFLocalizations.of(context)
                                                      .getText(
                                                    'zbjl608t' /* 50 */,
                                                  ),
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
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        fontSize: 16.0,
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
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          _model.sfzAmount = 100.0;
                                          safeSetState(() {});
                                          safeSetState(() {
                                            _model.amountTextFieldTextController
                                                ?.text = '100';
                                          });
                                        },
                                        child: Container(
                                          width: 90.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                            color: Color(0x2F935CCC),
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            border: Border.all(
                                              color: Color(0xFFD0BFF2),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(3.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  (FFMainAxisAlignment.center)
                                                      .flutterValue,
                                              children: [
                                                Icon(
                                                  FFIcons.kschatzToken,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 16.0,
                                                ),
                                                Text(
                                                  FFLocalizations.of(context)
                                                      .getText(
                                                    'p9dzibvd' /* 100 */,
                                                  ),
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
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        fontSize: 16.0,
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
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          _model.sfzAmount = 150.0;
                                          safeSetState(() {});
                                          safeSetState(() {
                                            _model.amountTextFieldTextController
                                                ?.text = '150';
                                          });
                                        },
                                        child: Container(
                                          width: 90.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                            color: Color(0x2F935CCC),
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            border: Border.all(
                                              color: Color(0xFFD0BFF2),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(3.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  (FFMainAxisAlignment.center)
                                                      .flutterValue,
                                              children: [
                                                Icon(
                                                  FFIcons.kschatzToken,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 16.0,
                                                ),
                                                Text(
                                                  FFLocalizations.of(context)
                                                      .getText(
                                                    'cv85x6et' /* 150 */,
                                                  ),
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
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        fontSize: 16.0,
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
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: 15.0)),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 30.0, 0.0, 0.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(22.0),
                                      bottomRight: Radius.circular(22.0),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 10.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          (FFMainAxisAlignment.start)
                                              .flutterValue,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 3.0),
                                          child: Text(
                                            FFLocalizations.of(context).getText(
                                              'leuke6sz' /* Add a note (optional) */,
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
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 13.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 5.0, 0.0, 0.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                border: Border.all(
                                                  color: Color(0xFFD0BFF2),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    (FFCrossAxisAlignment.start)
                                                        .flutterValue,
                                                textBaseline:
                                                    TextBaseline.alphabetic,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                15.0,
                                                                10.0,
                                                                10.0,
                                                                0.0),
                                                    child: Icon(
                                                      Icons.edit_outlined,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      size: 24.0,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  5.0,
                                                                  15.0,
                                                                  5.0),
                                                      child: Container(
                                                        width: double.infinity,
                                                        child: TextFormField(
                                                          controller: _model
                                                              .textController3,
                                                          focusNode: _model
                                                              .textFieldFocusNode2,
                                                          onChanged: (_) =>
                                                              EasyDebounce
                                                                  .debounce(
                                                            '_model.textController3',
                                                            Duration(
                                                                milliseconds:
                                                                    2000),
                                                            () async {
                                                              await Future
                                                                  .delayed(
                                                                Duration(
                                                                  milliseconds:
                                                                      50,
                                                                ),
                                                              );
                                                              _model.noteText =
                                                                  _model
                                                                      .textController3
                                                                      .text;
                                                              safeSetState(
                                                                  () {});
                                                            },
                                                          ),
                                                          autofocus: false,
                                                          enabled: true,
                                                          obscureText: false,
                                                          decoration:
                                                              InputDecoration(
                                                            isDense: true,
                                                            hintText:
                                                                FFLocalizations.of(
                                                                        context)
                                                                    .getText(
                                                              'm51df3j2' /* Enter note */,
                                                            ),
                                                            enabledBorder:
                                                                InputBorder
                                                                    .none,
                                                            focusedBorder:
                                                                InputBorder
                                                                    .none,
                                                            errorBorder:
                                                                InputBorder
                                                                    .none,
                                                            focusedErrorBorder:
                                                                InputBorder
                                                                    .none,
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
                                                          minLines: 1,
                                                          maxLength: 30,
                                                          maxLengthEnforcement:
                                                              MaxLengthEnforcement
                                                                  .enforced,
                                                          cursorColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primaryText,
                                                          enableInteractiveSelection:
                                                              true,
                                                          validator: _model
                                                              .textController3Validator
                                                              .asValidator(
                                                                  context),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          if (_model.exceedsSenderLimit != true) {
                            if (_model.recipientFound == false) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please enter a valid recipient account number',
                                    style: TextStyle(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                    ),
                                  ),
                                  duration: Duration(milliseconds: 4000),
                                  backgroundColor:
                                      FlutterFlowTheme.of(context).secondary,
                                ),
                              );
                            } else {
                              if (_model.sfzAmount <= 0.0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Enter a valid amount',
                                      style: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                      ),
                                    ),
                                    duration: Duration(milliseconds: 4000),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).secondary,
                                  ),
                                );
                              } else {
                                if (_model.sfzAmount >
                                    functions.getSingleDepositLimit(
                                        _model.recipientKycStatus)) {
                                  _model.exceedsTopUpLimit = true;
                                  safeSetState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Transaction amount exceeds recipient’s top-up limit',
                                        style: TextStyle(
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                      ),
                                      duration: Duration(milliseconds: 4000),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .secondary,
                                    ),
                                  );
                                } else {
                                  _model.exceedsTopUpLimit = false;
                                  safeSetState(() {});
                                  if (_model.sfzAmount >
                                      functions.getSingleTransferLimit(
                                          _model.senderKycStatus)) {
                                    _model.exceedsSenderLimit = true;
                                    safeSetState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Transaction limit exceeded',
                                          style: TextStyle(
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                          ),
                                        ),
                                        duration: Duration(milliseconds: 4000),
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .secondary,
                                      ),
                                    );
                                  } else {
                                    _model.exceedsSenderLimit = false;
                                    safeSetState(() {});
                                    await showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      enableDrag: false,
                                      context: context,
                                      builder: (context) {
                                        return Padding(
                                          padding:
                                              MediaQuery.viewInsetsOf(context),
                                          child: SendmoneyFinalWidget(
                                            recipientName: _model.recipientName,
                                            recipientAvatarUrl:
                                                _model.recipientAvatarUrl,
                                            recipientAccountNumber:
                                                functions.formatRecipientHandle(
                                                    _model.recipientMatchType,
                                                    _model
                                                        .recipientAccountNumber,
                                                    _model.recipientUsername),
                                            sfzAmount: _model.sfzAmount,
                                            localEquivalentText: functions
                                                .formatSendAmountEquivalent(
                                                    _model.sfzAmount,
                                                    _model.senderCurrency,
                                                    _model.senderFxRate),
                                            senderUserId: currentUserUid,
                                            recipientUserId:
                                                _model.recipientUserId,
                                            recipientCurrency:
                                                _model.recipientCurrency,
                                            noteText:
                                                _model.textController3.text,
                                            senderName: _model.senderName,
                                          ),
                                        );
                                      },
                                    ).then((value) => safeSetState(() {}));
                                  }
                                }
                              }
                            }
                          }
                        },
                        text: FFLocalizations.of(context).getText(
                          'h1cehve1' /* Continue */,
                        ),
                        icon: Icon(
                          Icons.arrow_forward,
                          size: 15.0,
                        ),
                        options: FFButtonOptions(
                          width: 450.0,
                          height: 50.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconAlignment: IconAlignment.end,
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: _model.exceedsSenderLimit == true
                              ? Color(0xFFD2D0D3)
                              : FlutterFlowTheme.of(context).primary,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.verified_user_rounded,
                            color: Color(0xFF935CCC),
                            size: 16.0,
                          ),
                          Text(
                            FFLocalizations.of(context).getText(
                              't2u8heht' /* Secure transfer */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  fontSize: 10.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                          Container(
                            width: 5.0,
                            height: 5.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryText,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            FFLocalizations.of(context).getText(
                              '8gi4kvl5' /* Protected by SchatzApp */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  fontSize: 10.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ].divide(SizedBox(width: 5.0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
