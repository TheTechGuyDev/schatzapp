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
import 'email_verify_component_model.dart';
export 'email_verify_component_model.dart';

class EmailVerifyComponentWidget extends StatefulWidget {
  const EmailVerifyComponentWidget({
    super.key,
    this.onEmailVerified,
    this.signupPhone,
    this.signupEmail,
  });

  final Future Function()? onEmailVerified;
  final String? signupPhone;
  final String? signupEmail;

  @override
  State<EmailVerifyComponentWidget> createState() =>
      _EmailVerifyComponentWidgetState();
}

class _EmailVerifyComponentWidgetState
    extends State<EmailVerifyComponentWidget> {
  late EmailVerifyComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmailVerifyComponentModel());

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

    _model.verifyPinCodeFocusNode ??= FocusNode();

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
            focusNode: _model.verifyPinCodeFocusNode,
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
            controller: _model.verifyPinCode,
            onChanged: (_) {},
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: _model.verifyPinCodeValidator.asValidator(context),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: (FFMainAxisAlignment.center).flutterValue,
          children: [
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
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
            ),
          ].divide(SizedBox(width: 15.0)),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              _model.emailOtpResult = await actions.checkWalletOtp(
                'email',
                widget.signupEmail!,
                _model.verifyPinCode!.text,
              );
              if (_model.emailOtpResult == true) {
                await actions.sendWalletOtp(
                  'sms',
                  widget.signupPhone!,
                );
                await widget.onEmailVerified?.call();
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
                    'd3ky7sc7' /* Verify */,
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
                  '138ojfrf' /* Didn't receive the code? */,
                ),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 12.0,
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
                      'email',
                      widget.signupEmail!,
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
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          if (_model.secondsLeft == 0) {
                            await actions.sendWalletOtp(
                              'email',
                              widget.signupEmail!,
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
                        child: Text(
                          FFLocalizations.of(context).getText(
                            'cm7thjl1' /* Check spam or resend */,
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: Color(0xFF935CCC),
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ].divide(SizedBox(width: 10.0)),
          ),
        ),
      ].divide(SizedBox(height: 10.0)),
    );
  }
}
