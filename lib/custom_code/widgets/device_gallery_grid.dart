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

/// DeviceGalleryGrid

import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';

class DeviceGalleryGrid extends StatefulWidget {
  const DeviceGalleryGrid({
    super.key,
    this.width,
    this.height,
    required this.onSelectionChanged,
    required this.existingSelectedPaths,
    required this.onCameraTap,
  });

  final double? width;
  final double? height;
  final Future Function(List<String> selectedPaths) onSelectionChanged;
  final List<String> existingSelectedPaths;
  final Future Function() onCameraTap;

  @override
  State<DeviceGalleryGrid> createState() => _DeviceGalleryGridState();
}

class _DeviceGalleryGridState extends State<DeviceGalleryGrid> {
  List<AssetEntity> _assets = [];
  List<String> _selectedIds = [];
  bool _permissionDenied = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedIds = List<String>.from(widget.existingSelectedPaths);
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth && !permission.hasAccess) {
      setState(() {
        _permissionDenied = true;
        _loading = false;
      });
      return;
    }

    final albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
    );

    if (albums.isEmpty) {
      setState(() {
        _loading = false;
      });
      return;
    }

    final recentAssets = await albums.first.getAssetListPaged(
      page: 0,
      size: 60,
    );

    setState(() {
      _assets = recentAssets;
      _loading = false;
    });
  }

  void _toggleSelect(AssetEntity asset) {
    setState(() {
      if (_selectedIds.contains(asset.id)) {
        _selectedIds.remove(asset.id);
      } else {
        _selectedIds.add(asset.id);
      }
    });
    widget.onSelectionChanged(_selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        width: widget.width,
        height: widget.height ?? 200,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_permissionDenied) {
      return SizedBox(
        width: widget.width,
        height: widget.height ?? 200,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Allow photo access in Settings to see your gallery here.',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
          ),
        ),
      );
    }

    // itemCount = 1 extra slot for the camera tile at index 0
    final cappedAssets = _assets.take(10).toList();
    final itemCount = cappedAssets.length + 1;
    const tileSize = 90.0;

    return SizedBox(
      width: widget.width,
      height: widget.height ?? 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // First cell is always the camera tile
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: GestureDetector(
                onTap: () => widget.onCameraTap(),
                child: Container(
                  width: tileSize,
                  height: tileSize,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 24.0,
                  ),
                ),
              ),
            );
          }

          final asset = cappedAssets[index - 1];
          final isSelected = _selectedIds.contains(asset.id);
          final selectionNumber =
              isSelected ? _selectedIds.indexOf(asset.id) + 1 : null;

          return Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: GestureDetector(
              onTap: () => _toggleSelect(asset),
              child: SizedBox(
                width: tileSize,
                height: tileSize,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: FutureBuilder<Uint8List?>(
                        future: asset.thumbnailDataWithSize(
                          const ThumbnailSize.square(200),
                        ),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) {
                            return Container(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                            );
                          }
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    if (isSelected)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).primary,
                            width: 3.0,
                          ),
                        ),
                      ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? FlutterFlowTheme.of(context).primary
                              : Colors.black.withOpacity(0.4),
                          border: Border.all(color: Colors.white, width: 1.0),
                        ),
                        child: Center(
                          child: isSelected
                              ? Text(
                                  '$selectionNumber',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
