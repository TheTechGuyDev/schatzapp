import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'scan_web_model.dart';
export 'scan_web_model.dart';

/// Link a Device sheet. The camera starts as soon as the sheet opens and
/// scans inside the box (no full-screen scanner, no button). A SchatzApp QR
/// is linked straight away and the sheet closes.
class ScanWebWidget extends StatefulWidget {
  const ScanWebWidget({super.key});

  @override
  State<ScanWebWidget> createState() => _ScanWebWidgetState();
}

class _ScanWebWidgetState extends State<ScanWebWidget> {
  static const Color _purple = Color(0xFF935CCC);
  static const String _qrPrefix = 'schatzapp://link-device';

  late ScanWebModel _model;

  final MobileScannerController _scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );

  bool _linking = false;
  String _lastBadCode = '';

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ScanWebModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _scanner.dispose();
    _model.maybeDispose();

    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_linking) return;
    String? code;
    for (final b in capture.barcodes) {
      final v = b.rawValue?.trim();
      if (v != null && v.isNotEmpty) {
        code = v;
        break;
      }
    }
    if (code == null) return;

    // Not a SchatzApp code: say so once, keep scanning.
    if (!code.startsWith(_qrPrefix)) {
      if (code != _lastBadCode) {
        _lastBadCode = code;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
              content: Text('This is not a SchatzApp QR code.')));
      }
      return;
    }

    _model.scannedQr = code;
    safeSetState(() => _linking = true);
    await _scanner.stop();

    final ok = await actions.linkWebDevice(code, confirm: false);
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }

    // Failed (expired code, device limit, no internet): scan again.
    safeSetState(() => _linking = false);
    try {
      await _scanner.start();
    } catch (_) {}
  }

  Widget _scannerError(MobileScannerException error) {
    final denied =
        error.errorCode == MobileScannerErrorCode.permissionDenied;
    return Container(
      color: const Color(0xFF111B21),
      padding: const EdgeInsets.all(24.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.no_photography_outlined,
              color: Colors.white70, size: 40.0),
          const SizedBox(height: 12.0),
          Text(
            denied
                ? 'Camera access is off. Allow camera for SchatzApp in your phone settings to scan.'
                : 'Could not start the camera. Close this and try again.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14.0),
          ),
        ],
      ),
    );
  }

  Widget _scannerBox() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: SizedBox(
        width: double.infinity,
        height: 350.0,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _scanner,
              onDetect: _onDetect,
              errorBuilder: (context, error) => _scannerError(error),
            ),
            // Scan frame.
            IgnorePointer(
              child: Center(
                child: Container(
                  width: 230.0,
                  height: 230.0,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3.0),
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
            ),
            if (_linking)
              Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 12.0),
                    Text('Linking device...',
                        style: TextStyle(color: Colors.white, fontSize: 14.0)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 650.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.pop();
                    },
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 1.0,
                        ),
                      ),
                      child: Icon(
                        Icons.close,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 24.0,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Align(
                      alignment: const AlignmentDirectional(0.0, -1.0),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 30.0, 0.0),
                        child: Text(
                          FFLocalizations.of(context).getText(
                            'jn6gq0q9' /* Scan QR code */,
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
              child: Text(
                FFLocalizations.of(context).getText(
                  '5s2jadmb' /* Open web.schatzapp.com on your... */,
                ),
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              child: _scannerBox(),
            ),
            Text(
              FFLocalizations.of(context).getText(
                '8z30d5ig' /* You can also link your phone n... */,
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    color: _purple,
                    fontSize: 15.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
          ].divide(const SizedBox(height: 30.0)),
        ),
      ),
    );
  }
}
