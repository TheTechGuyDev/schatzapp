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

class DocumentMessageCard extends StatelessWidget {
  const DocumentMessageCard({
    super.key,
    this.width,
    this.height,
    required this.url,
    required this.name,
    this.sizeBytes,
    this.pages,
    this.thumbnailUrl,
  });

  final double? width;
  final double? height;
  final String url;
  final String name;
  final int? sizeBytes;
  final int? pages;
  final String? thumbnailUrl;

  String get _ext {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return 'FILE';
    return name.substring(dot + 1).toUpperCase();
  }

  String get _sizeLabel {
    final b = sizeBytes ?? 0;
    if (b <= 0) return '';
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(0)} KB';
    return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get _subtitle {
    final parts = <String>[];
    final p = pages ?? 0;
    if (p > 0) parts.add('$p ${p == 1 ? 'page' : 'pages'}');
    parts.add(_ext);
    if (_sizeLabel.isNotEmpty) parts.add(_sizeLabel);
    return parts.join('  •  ');
  }

  Color get _typeColor {
    switch (_ext) {
      case 'PDF':
        return const Color(0xFFDC2626);
      case 'DOC':
      case 'DOCX':
        return const Color(0xFF2563EB);
      case 'XLS':
      case 'XLSX':
      case 'CSV':
        return const Color(0xFF16A34A);
      case 'PPT':
      case 'PPTX':
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Future<void> _open(BuildContext context) async {
    if (url.isEmpty) return;
    // In the app every file opens in the built-in viewer (file name as the
    // title); in a browser it opens in a new tab.
    if (!kIsWeb) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DocumentPreviewScreen(url: url, name: name),
        ),
      );
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final hasThumb = (thumbnailUrl ?? '').isNotEmpty;
    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        width: width ?? 244,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasThumb)
              SizedBox(
                height: 130,
                child: cachedNetworkImage(
                  thumbnailUrl!,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _typeColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _ext.length > 4 ? _ext.substring(0, 4) : _ext,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13.5, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11.5, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
