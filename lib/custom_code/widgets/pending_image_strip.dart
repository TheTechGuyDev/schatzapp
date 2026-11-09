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

import 'dart:convert';
import 'dart:typed_data';

class PendingImageStrip extends StatelessWidget {
  const PendingImageStrip({
    super.key,
    this.width,
    this.height,
    required this.images,
    required this.onRemove,
    required this.onUpdated,
  });

  final double? width;
  final double? height;
  final List<PendingWebImageStruct> images;
  final Future Function(int index) onRemove;
  final Future Function(List<PendingWebImageStruct> updatedImages) onUpdated;

  bool _isDoc(PendingWebImageStruct e) => e.mediaType.startsWith('document:');

  String _docName(PendingWebImageStruct e) =>
      e.mediaType.length > 9 ? e.mediaType.substring(9) : 'Document';

  Future<void> _openBatchEditor(BuildContext context, int index) async {
    // Documents cannot be edited, so the editor only sees the other items.
    final editIdx = <int>[
      for (var i = 0; i < images.length; i++)
        if (!_isDoc(images[i])) i
    ];
    final identifiers =
        editIdx.map((i) => 'b64:${images[i].base64Data}').toList();
    final startAt = editIdx.indexOf(index);

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BatchEditImagePage(
          mediaIdentifiers: identifiers,
          initialIndex: startAt < 0 ? 0 : startAt,
          onDone: (editedByIndex, removedIndexes) async {
            final edited = editedByIndex as Map<int, Uint8List>;

            final removed = removedIndexes as Set<int>;

            final updated = <PendingWebImageStruct>[];

            for (var i = 0; i < images.length; i++) {
              final k = editIdx.indexOf(i);
              if (k >= 0 && removed.contains(k)) {
                continue;
              }

              if (k >= 0 && edited.containsKey(k)) {
                updated.add(
                  PendingWebImageStruct(
                    base64Data: base64Encode(edited[k]!),
                    mediaType: images[i].mediaType,
                  ),
                );
              } else {
                updated.add(images[i]);
              }
            }

            await onUpdated(updated);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: width,
      height: height ?? 74,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isDoc = _isDoc(images[i]);
          final isVideo = images[i].mediaType == 'video';
          final bytes =
              (isVideo || isDoc) ? null : base64Decode(images[i].base64Data);
          final docName = isDoc ? _docName(images[i]) : '';
          final docExt = docName.contains('.')
              ? docName.split('.').last.toUpperCase()
              : 'FILE';

          return Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: isDoc
                    ? Container(
                        width: 62,
                        height: 62,
                        color: const Color(0xFFF3F4F6),
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.insert_drive_file_rounded,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 22),
                            Text(
                              docExt.length > 5
                                  ? docExt.substring(0, 5)
                                  : docExt,
                              style: const TextStyle(
                                  fontSize: 9, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              docName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 8),
                            ),
                          ],
                        ),
                      )
                    : isVideo
                        ? Container(
                            width: 62,
                            height: 62,
                            color: const Color(0xFF1E1E1E),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 30,
                            ),
                          )
                        : Image.memory(
                            bytes!,
                            width: 62,
                            height: 62,
                            fit: BoxFit.cover,
                          ),
              ),
              if (!isVideo && !isDoc)
                Positioned(
                  top: -4,
                  left: -4,
                  child: InkWell(
                    onTap: () => _openBatchEditor(context, i),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 11,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: -4,
                right: -4,
                child: InkWell(
                  onTap: () => onRemove(i),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
