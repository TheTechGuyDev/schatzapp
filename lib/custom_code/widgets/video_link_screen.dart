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
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoLinkScreen extends StatefulWidget {
  const VideoLinkScreen({
    super.key,
    this.width,
    this.height,
    required this.url,
    required this.title,
  });

  final double? width;
  final double? height;
  final String url;
  final String title;

  @override
  State<VideoLinkScreen> createState() => _VideoLinkScreenState();
}

class _VideoLinkScreenState extends State<VideoLinkScreen> {
  WebViewController? _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) _setup();
  }

  String? _youtubeId(Uri? u) {
    if (u == null) return null;
    final host = u.host.toLowerCase();
    String? id;
    if (host == 'youtu.be') {
      if (u.pathSegments.isNotEmpty) id = u.pathSegments.first;
    } else if (host.endsWith('youtube.com') ||
        host.endsWith('youtube-nocookie.com')) {
      if (u.path == '/watch') {
        id = u.queryParameters['v'];
      } else if (u.pathSegments.length >= 2 &&
          ['shorts', 'embed', 'live', 'v'].contains(u.pathSegments.first)) {
        id = u.pathSegments[1];
      }
    }
    if (id != null && RegExp(r'^[\w-]{6,15}$').hasMatch(id)) return id;
    return null;
  }

  void _setup() {
    final uri = Uri.tryParse(widget.url);
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
        onWebResourceError: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ));

    final host = (uri?.host ?? '').toLowerCase();
    final ytId = _youtubeId(uri);
    if (ytId != null) {
      final html = '<!DOCTYPE html><html><head>'
          '<meta name="viewport" content="width=device-width, initial-scale=1.0">'
          '<style>html,body{margin:0;height:100%;background:#000}'
          'iframe{position:absolute;top:0;left:0;width:100%;height:100%;border:0}</style>'
          '</head><body>'
          '<iframe src="https://www.youtube.com/embed/$ytId?autoplay=1&playsinline=1&rel=0" '
          'allow="autoplay; encrypted-media; picture-in-picture; fullscreen" '
          'allowfullscreen></iframe></body></html>';
      controller.loadHtmlString(html, baseUrl: 'https://www.youtube.com');
    } else if (host.contains('facebook.com') ||
        host == 'fb.watch' ||
        host.contains('fb.com')) {
      controller.loadRequest(Uri.parse(
          'https://www.facebook.com/plugins/video.php?href=${Uri.encodeComponent(widget.url)}&show_text=false&autoplay=true'));
    } else if (host.contains('instagram.com') && uri != null) {
      var path = uri.path;
      if (!path.endsWith('/')) path = '$path/';
      controller
          .loadRequest(Uri.parse('https://www.instagram.com${path}embed'));
    } else if (uri != null) {
      controller.loadRequest(uri);
    }
    _controller = controller;
  }

  Future<void> _openOutside() async {
    final uri = Uri.tryParse(widget.url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title.isEmpty ? 'Video' : widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Open in browser',
            icon: const Icon(Icons.open_in_new, color: Colors.white),
            onPressed: _openOutside,
          ),
        ],
      ),
      body: _controller == null
          ? Center(
              child: ElevatedButton.icon(
                onPressed: _openOutside,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open in browser'),
              ),
            )
          : Stack(
              children: [
                WebViewWidget(controller: _controller!),
                if (_loading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
              ],
            ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
