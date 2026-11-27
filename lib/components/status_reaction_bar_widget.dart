import '/flutter_flow/ff_builtin_enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'status_reaction_bar_model.dart';
export 'status_reaction_bar_model.dart';

class StatusReactionBarWidget extends StatefulWidget {
  const StatusReactionBarWidget({
    super.key,
    this.statusId,
    this.viewerId,
  });

  final String? statusId;
  final String? viewerId;

  @override
  State<StatusReactionBarWidget> createState() =>
      _StatusReactionBarWidgetState();
}

class _StatusReactionBarWidgetState extends State<StatusReactionBarWidget> {
  late StatusReactionBarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StatusReactionBarModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.getReaction = await actions.getReactionSummary(
        '',
        widget.viewerId!,
      );
      _model.favoriteCount = _model.getReaction!.favoriteCount;
      _model.peaceCount = _model.getReaction!.peaceCount;
      _model.thumbsCount = _model.getReaction!.thumbsCount;
      _model.favoriteActive = _model.getReaction!.favoriteActive;
      _model.peaceActive = _model.getReaction!.peaceActive;
      _model.thumbsActive = _model.getReaction!.thumbsActive;
      safeSetState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(15.0, 0.0, 15.0, 20.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: (FFCrossAxisAlignment.start).flutterValue,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      await actions.toggleReaction(
                        widget.statusId!,
                        widget.viewerId!,
                        'favorite',
                      );
                      if (_model.favoriteActive == true) {
                        _model.favoriteActive = false;
                        safeSetState(() {});
                        _model.favoriteCount = _model.favoriteCount + 1;
                        safeSetState(() {});
                      } else {
                        _model.favoriteActive = true;
                        safeSetState(() {});
                        _model.favoriteCount = _model.favoriteCount + 1;
                        safeSetState(() {});
                      }
                    },
                    child: Icon(
                      Icons.favorite_border,
                      color: _model.favoriteActive == true
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      size: 25.0,
                    ),
                  ),
                  Text(
                    valueOrDefault<String>(
                      _model.favoriteCount.toString(),
                      '0',
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ].divide(SizedBox(width: 3.0)),
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
                      await actions.toggleReaction(
                        widget.statusId!,
                        widget.viewerId!,
                        'peace',
                      );
                      if (_model.favoriteActive == true) {
                        _model.favoriteActive = false;
                        safeSetState(() {});
                        _model.favoriteCount = _model.favoriteCount + 1;
                        safeSetState(() {});
                      } else {
                        _model.favoriteActive = true;
                        safeSetState(() {});
                        _model.favoriteCount = _model.favoriteCount + 1;
                        safeSetState(() {});
                      }
                    },
                    child: FaIcon(
                      FaIconData(const IconData(/* handPeace */ 0xf25b,
                          fontFamily: 'FontAwesomeRegular',
                          fontPackage: 'font_awesome_flutter')),
                      color: _model.favoriteActive == true
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      size: 25.0,
                    ),
                  ),
                  Text(
                    valueOrDefault<String>(
                      _model.favoriteCount.toString(),
                      '0',
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ].divide(SizedBox(width: 3.0)),
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
                      await actions.toggleReaction(
                        widget.statusId!,
                        widget.viewerId!,
                        'thumbs',
                      );
                      if (_model.favoriteActive == true) {
                        _model.favoriteActive = false;
                        safeSetState(() {});
                        _model.favoriteCount = _model.favoriteCount + 1;
                        safeSetState(() {});
                      } else {
                        _model.favoriteActive = true;
                        safeSetState(() {});
                        _model.favoriteCount = _model.favoriteCount + 1;
                        safeSetState(() {});
                      }
                    },
                    child: FaIcon(
                      FaIconData(const IconData(/* thumbsUp */ 0xf164,
                          fontFamily: 'FontAwesomeRegular',
                          fontPackage: 'font_awesome_flutter')),
                      color: _model.favoriteActive == true
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      size: 25.0,
                    ),
                  ),
                  Text(
                    valueOrDefault<String>(
                      _model.favoriteCount.toString(),
                      '0',
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ].divide(SizedBox(width: 3.0)),
              ),
            ].divide(SizedBox(width: 25.0)),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: (FFCrossAxisAlignment.center).flutterValue,
            textBaseline: TextBaseline.alphabetic,
            children: [
              FaIcon(
                FaIconData(const IconData(/* share */ 0xf064,
                    fontFamily: 'FontAwesomeSolid',
                    fontPackage: 'font_awesome_flutter')),
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 24.0,
              ),
              Text(
                FFLocalizations.of(context).getText(
                  '7udrbfcq' /* Share */,
                ),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 3.0, 0.0, 0.0),
                child: Text(
                  FFLocalizations.of(context).getText(
                    '2z8c7f6u' /* 53 */,
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
              ),
            ].divide(SizedBox(width: 5.0)),
          ),
        ],
      ),
    );
  }
}
