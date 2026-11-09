import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'phone_verify_component_model.dart';
export 'phone_verify_component_model.dart';

class PhoneVerifyComponentWidget extends StatefulWidget {
  const PhoneVerifyComponentWidget({
    super.key,
    String? parameter1,
    String? parameter2,
    String? parameter3,
    String? parameter4,
    this.onWalletCreated,
  })  : this.parameter1 = parameter1 ?? '',
        this.parameter2 = parameter2 ?? '',
        this.parameter3 = parameter3 ?? '',
        this.parameter4 = parameter4 ?? '';

  final String parameter1;
  final String parameter2;
  final String parameter3;
  final String parameter4;
  final Future Function()? onWalletCreated;

  @override
  State<PhoneVerifyComponentWidget> createState() =>
      _PhoneVerifyComponentWidgetState();
}

class _PhoneVerifyComponentWidgetState
    extends State<PhoneVerifyComponentWidget> {
  late PhoneVerifyComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PhoneVerifyComponentModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      while (_model.secondsLeft > 0) {
        await Future.delayed(
          Duration(
            milliseconds: 1000,
          ),
        );
        _model.secondsLeft = _model.secondsLeft + -1;
        safeSetState(() {});
      }
    });

    _model.phonePinCodeFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 20.0),
          child: PinCodeTextField(
            autoDisposeControllers: false,
            appContext: context,
            length: 6,
            textStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight:
                        FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                    fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                  ),
                  letterSpacing: 0.0,
                  fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                ),
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            enableActiveFill: false,
            autoFocus: true,
            focusNode: _model.phonePinCodeFocusNode,
            enablePinAutofill: false,
            errorTextSpace: 16.0,
            showCursor: true,
            cursorColor: FlutterFlowTheme.of(context).primary,
            obscureText: false,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            pinTheme: PinTheme(
              fieldHeight: 50.0,
              fieldWidth: 44.0,
              borderWidth: 2.0,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12.0),
                bottomRight: Radius.circular(12.0),
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
              shape: PinCodeFieldShape.box,
              activeColor: FlutterFlowTheme.of(context).primaryText,
              inactiveColor: FlutterFlowTheme.of(context).alternate,
              selectedColor: FlutterFlowTheme.of(context).primary,
            ),
            controller: _model.phonePinCode,
            onChanged: (_) {},
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: _model.phonePinCodeValidator.asValidator(context),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
          child: Text(
            valueOrDefault<String>(
              'Resend code in ${functions.formatCountdown(_model.secondsLeft)}',
              'Resend code in 00:45',
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: Color(0xFF935CCC),
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              _model.walletCreateResult = await actions.checkWalletOtp(
                'sms',
                widget.parameter3,
                _model.phonePinCode!.text,
              );
              if (_model.walletCreateResult == true) {
                await actions.createWallet(
                  currentUserUid,
                  widget.parameter1,
                  widget.parameter2,
                  FFAppState().selectedCountry.dialCode,
                  FFAppState().selectedCountry.isoCode,
                  widget.parameter3,
                );
                if (_model.walletCreateResult == true) {
                  await widget.onWalletCreated?.call();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Wallet creation failed. Please try again.',
                        style: TextStyle(
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                      ),
                      duration: Duration(milliseconds: 4000),
                      backgroundColor: FlutterFlowTheme.of(context).secondary,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Invalid or expired code. Please try again.',
                      style: TextStyle(
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                    duration: Duration(milliseconds: 4000),
                    backgroundColor: FlutterFlowTheme.of(context).secondary,
                  ),
                );
              }

              safeSetState(() {});
            },
            child: Container(
              width: double.infinity,
              height: 50.0,
              decoration: BoxDecoration(
                color: Color(0xFF935CCC),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Text(
                  FFLocalizations.of(context).getText(
                    '6x1jgyja' /* Verify */,
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: (FFMainAxisAlignment.center).flutterValue,
            children: [
              Text(
                FFLocalizations.of(context).getText(
                  '4dt1sdcs' /* Didn't receive the code? */,
                ),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 13.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
              InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  if (_model.secondsLeft == 0) {
                    await actions.sendWalletOtp(
                      'sms',
                      widget.parameter3,
                    );
                    _model.secondsLeft = 45;
                    safeSetState(() {});
                    while (_model.secondsLeft > 0) {
                      await Future.delayed(
                        Duration(
                          milliseconds: 1000,
                        ),
                      );
                      _model.secondsLeft = _model.secondsLeft + -1;
                      safeSetState(() {});
                    }
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      FFLocalizations.of(context).getText(
                        'xdd2smtw' /* Resend */,
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            color: Color(0xFF935CCC),
                            fontSize: 13.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                  ],
                ),
              ),
            ].divide(SizedBox(width: 10.0)),
          ),
        ),
      ],
    );
  }
}
