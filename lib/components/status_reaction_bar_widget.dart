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
  static const Color _heart = Color(0xFFE0245E);

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
    SchedulerBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didUpdateWidget(covariant StatusReactionBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statusId != widget.statusId) _load();
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  Future<void> _load() async {
    final statusId = widget.statusId ?? '';
    final viewerId = widget.viewerId ?? '';
    if (statusId.isEmpty || viewerId.isEmpty) return;
    try {
      final summary = await actions.getReactionSummary(statusId, viewerId);
      if (!mounted || statusId != widget.statusId) return;
      safeSetState(() => _model.applySummary(summary));
    } catch (_) {
      // Keep zero counts if the summary fetch fails.
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _showLimit() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text(actions.kReactionLimitMessage)),
      );
  }

  Future<void> _toggle(String type) async {
    final statusId = widget.statusId ?? '';
    final viewerId = widget.viewerId ?? '';
    if (statusId.isEmpty) return;

    final wasActive = _model.mine.contains(type);
    if (!wasActive && _model.mine.length >= 2) {
      _showLimit();
      return;
    }

    // Adding is instant. Removing waits for the server, because a reaction
    // older than 3 seconds is locked and must stay highlighted.
    if (!wasActive) safeSetState(() => _model.flip(type, true));
    try {
      await actions.toggleReaction(statusId, viewerId, type);
      if (wasActive && mounted) safeSetState(() => _model.flip(type, false));
    } on actions.ReactionLockedException {
      if (!mounted) return;
      if (!wasActive) safeSetState(() => _model.flip(type, false));
      _snack(actions.kReactionLockedMessage);
    } on actions.ReactionLimitException {
      if (!mounted) return;
      if (!wasActive) safeSetState(() => _model.flip(type, false));
      _showLimit();
    } catch (_) {
      if (!mounted) return;
      if (!wasActive) safeSetState(() => _model.flip(type, false));
      _snack('Could not save reaction. Try again.');
    }
  }

  TextStyle _countStyle(BuildContext context, {Color? color}) =>
      FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.plusJakartaSans(
              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
            ),
            color: color,
            fontSize: 12.0,
            letterSpacing: 0.0,
            fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
          );

  Widget _icon(String type, bool active) {
    if (type == 'favorite') {
      return Icon(
        active ? Icons.favorite : Icons.favorite_border,
        color:
            active ? _heart : FlutterFlowTheme.of(context).secondaryText,
        size: 25.0,
      );
    }
    return Opacity(
      opacity: active ? 1.0 : 0.6,
      child: Text(
        actions.kReactionEmoji[type] ?? '',
        style: const TextStyle(fontSize: 22.0, height: 1.15),
      ),
    );
  }

  Widget _button(String type) {
    final active = _model.mine.contains(type);
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => _toggle(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: active
              ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _icon(type, active),
            const SizedBox(width: 3.0),
            Text(
              (_model.counts[type] ?? 0).toString(),
              style: _countStyle(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(15.0, 0.0, 15.0, 20.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Reactions scroll sideways on small screens; Share stays visible.
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final t in actions.kReactionTypes) _button(t),
                ].divide(const SizedBox(width: 4.0)),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.share,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 24.0,
              ),
              Text(
                FFLocalizations.of(context).getText(
                  '7udrbfcq' /* Share */,
                ),
                style: _countStyle(context,
                        color: FlutterFlowTheme.of(context).secondaryText)
                    .copyWith(fontSize: 14.0),
              ),
            ].divide(const SizedBox(width: 5.0)),
          ),
        ],
      ),
    );
  }
}
