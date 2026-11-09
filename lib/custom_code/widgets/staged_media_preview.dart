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

import 'dart:io';
import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';
import '/custom_code/actions/staged_edit_registry.dart';

class StagedMediaPreview extends StatefulWidget {
  const StagedMediaPreview({
    super.key,
    this.width,
    this.height,
    required this.existingSelectedPaths,
    required this.onRemove,
    required this.onUpdated,
    required this.onAllRemoved,
  });

  final double? width;
  final double? height;
  final List<String> existingSelectedPaths;
  final Future Function(String assetId) onRemove;
  final Future Function(dynamic updatedIdentifiers) onUpdated;
  final Future Function() onAllRemoved;

  @override
  State<StagedMediaPreview> createState() => _StagedMediaPreviewState();
}

class _StagedMediaPreviewState extends State<StagedMediaPreview> {
  bool _isVideoPath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.3gp') ||
        lower.endsWith('.webm');
  }

  Widget _videoTile(double size) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFF1E1E1E),
      alignment: Alignment.center,
      child:
          Icon(Icons.play_circle_fill, color: Colors.white, size: size * 0.55),
    );
  }

  Widget _buildThumbnail(String identifier, double size) {
    if (identifier.startsWith('/') && _isVideoPath(identifier)) {
      return _videoTile(size);
    }
    if (identifier.startsWith('/')) {
      // Camera capture: raw file path
      return Image.file(
        File(identifier),
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    // Gallery pick: photo_manager asset ID
    return FutureBuilder<AssetEntity?>(
      future: AssetEntity.fromId(identifier),
      builder: (context, assetSnapshot) {
        if (!assetSnapshot.hasData || assetSnapshot.data == null) {
          return Container(
            width: size,
            height: size,
            color: FlutterFlowTheme.of(context).primaryBackground,
          );
        }
        return FutureBuilder<Uint8List?>(
          future: assetSnapshot.data!.thumbnailDataWithSize(
            const ThumbnailSize.square(120),
          ),
          builder: (context, thumbSnapshot) {
            if (!thumbSnapshot.hasData || thumbSnapshot.data == null) {
              return Container(
                width: size,
                height: size,
                color: FlutterFlowTheme.of(context).primaryBackground,
              );
            }
            final thumb = Image.memory(
              thumbSnapshot.data!,
              width: size,
              height: size,
              fit: BoxFit.cover,
            );
            if (assetSnapshot.data!.type != AssetType.video) return thumb;
            return Stack(
              alignment: Alignment.center,
              children: [
                thumb,
                Container(width: size, height: size, color: Colors.black26),
                Icon(Icons.play_circle_fill,
                    color: Colors.white, size: size * 0.5),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openBatchEditor(String topIdentifier) async {
    // Snapshot the identifiers as they are right now, so the indexes used
    // below line up with what the batch editor actually shows.
    final identifiers = List<String>.from(widget.existingSelectedPaths);
    final initialIndex = identifiers.indexOf(topIdentifier);

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BatchEditImagePage(
          mediaIdentifiers: identifiers,
          initialIndex: initialIndex < 0 ? 0 : initialIndex,
          onDone: (editedByIndex, removedIndexes) async {
            final edited = editedByIndex as Map<int, Uint8List>;
            final removed = removedIndexes as Set<int>;

            final keptIdentifiers = <String>[];
            for (var i = 0; i < identifiers.length; i++) {
              final identifier = identifiers[i];
              if (removed.contains(i)) {
                clearStagedEdit(identifier);
                continue;
              }
              if (edited.containsKey(i)) {
                setStagedEdit(identifier, edited[i]!);
              }
              keptIdentifiers.add(identifier);
            }

            await widget.onUpdated(keptIdentifiers);
            if (keptIdentifiers.isEmpty) {
              await widget.onAllRemoved();
            }
          },
        ),
      ),
    );

    // Whether or not anything changed, refresh so the "Edited" badge
    // reflects the current registry state.
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.existingSelectedPaths.isEmpty) {
      return const SizedBox.shrink();
    }

    final topIdentifier = widget.existingSelectedPaths.last;
    final count = widget.existingSelectedPaths.length;
    final size = widget.width ?? 40;
    final isEdited = getStagedEdit(topIdentifier) != null;

    return SizedBox(
      width: size,
      height: widget.height ?? 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: _buildThumbnail(topIdentifier, size),
          ),
          Positioned(
            top: -4,
            right: -4,
            child: GestureDetector(
              onTap: () => _openBatchEditor(topIdentifier),
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black87,
                ),
                child: const Icon(
                  Icons.edit,
                  size: 9,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (isEdited)
            Positioned(
              bottom: -4,
              left: -4,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FlutterFlowTheme.of(context).success,
                  border: Border.all(color: Colors.white, width: 1.0),
                ),
                child: const Icon(
                  Icons.check,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
          if (count > 1)
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FlutterFlowTheme.of(context).primary,
                  border: Border.all(color: Colors.white, width: 1.0),
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
