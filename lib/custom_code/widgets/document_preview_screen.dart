// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DocumentPreviewScreen extends StatefulWidget {
  const DocumentPreviewScreen({
    super.key,
    this.width,
    this.height,
    required this.url,
    required this.name,
  });

  final double? width;
  final double? height;
  final String url;
  final String name;

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  PdfControllerPinch? _controller;
  WebViewController? _web;
  bool _loading = true;
  bool _failed = false;

  bool get _isPdf => widget.name.toLowerCase().endsWith('.pdf');

  bool get _isOffice {
    final n = widget.name.toLowerCase();
    return ['.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx']
        .any((e) => n.endsWith(e));
  }

  // Word, Excel and PowerPoint files are shown inside the app through the
  // Google document viewer, with the file name as the title.
  void _setupOffice() {
    final c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
        onWebResourceError: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ))
      ..loadRequest(Uri.parse(
          'https://docs.google.com/gview?embedded=1&url=${Uri.encodeComponent(widget.url)}'));
    _web = c;
  }

  @override
  void initState() {
    super.initState();
    if (_isPdf && !kIsWeb) {
      _loadPdf();
    } else if (_isOffice && !kIsWeb) {
      _setupOffice();
    } else {
      _loading = false;
    }
  }

  Future<void> _loadPdf() async {
    try {
      final res = await http.get(Uri.parse(widget.url));
      if (res.statusCode != 200 || res.bodyBytes.isEmpty) {
        throw Exception('download failed');
      }
      final controller = PdfControllerPinch(
        document: PdfDocument.openData(res.bodyBytes),
      );
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  Future<void> _openExternal() async {
    final uri = Uri.tryParse(widget.url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _body() {
    if (_web != null) {
      return Stack(
        children: [
          WebViewWidget(controller: _web!),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      );
    }
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller != null) {
      return PdfViewPinch(
        controller: _controller!,
        backgroundDecoration: const BoxDecoration(color: Color(0xFFE5E7EB)),
      );
    }
    final accent = FlutterFlowTheme.of(context).primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file_rounded, size: 64, color: accent),
            const SizedBox(height: 12),
            Text(
              widget.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _failed
                  ? 'This preview could not be loaded.'
                  : 'Preview is not available for this file type.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _openExternal,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Open file'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0.5,
        titleSpacing: 0,
        title: Text(
          widget.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_controller != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: PdfPageNumber(
                  controller: _controller!,
                  builder: (context, loadingState, page, pagesCount) => Text(
                    '$page / ${pagesCount ?? 0}',
                    style:
                        const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Open in browser',
            icon: const Icon(Icons.open_in_new_rounded),
            onPressed: _openExternal,
          ),
        ],
      ),
      body: _body(),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
