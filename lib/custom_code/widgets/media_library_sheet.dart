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

import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';
import 'package:google_fonts/google_fonts.dart';

class MediaLibrarySheet extends StatefulWidget {
  const MediaLibrarySheet({
    super.key,
    this.width,
    this.height,
    required this.existingSelectedPaths,
    required this.onSelectionChanged,
    required this.onClose,
    required this.onSend,
  });

  final double? width;
  final double? height;
  final List<String> existingSelectedPaths;
  final Future Function(List<String> selectedPaths) onSelectionChanged;
  final Future Function() onClose;
  final Future Function(List<String> selectedPaths, String caption) onSend;

  @override
  State<MediaLibrarySheet> createState() => _MediaLibrarySheetState();
}

class _MediaLibrarySheetState extends State<MediaLibrarySheet> {
  int _tabIndex = 0;
  List<String> _selectedIds = [];
  final TextEditingController _captionController = TextEditingController();

  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _openAlbum;

  List<AssetEntity> _assets = [];
  int _page = 0;
  bool _hasMore = true;
  bool _loading = true;
  bool _loadingMore = false;
  bool _sending = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedIds = List<String>.from(widget.existingSelectedPaths);
    _scrollController.addListener(_onScroll);
    _init();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_loadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _init() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth && !permission.hasAccess) {
      setState(() => _loading = false);
      return;
    }
    _albums = await PhotoManager.getAssetPathList(type: RequestType.common);
    await _loadPage(reset: true);
  }

  Future<void> _loadPage({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _page = 0;
        _assets = [];
        _hasMore = true;
      });
    }

    final source = _openAlbum ??
        (_albums.isNotEmpty
            ? await PhotoManager.getAssetPathList(
                onlyAll: true,
                type: RequestType.common,
              ).then((v) => v.first)
            : null);

    if (source == null) {
      setState(() {
        _loading = false;
        _loadingMore = false;
      });
      return;
    }

    final newAssets = await source.getAssetListPaged(page: _page, size: 60);

    setState(() {
      _assets.addAll(newAssets);
      _hasMore = newAssets.length == 60;
      _loading = false;
      _loadingMore = false;
    });
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    _page += 1;
    await _loadPage();
  }

  Future<void> _openAlbumView(AssetPathEntity album) async {
    setState(() {
      _openAlbum = album;
      _tabIndex = 0;
    });
    await _loadPage(reset: true);
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

  Future<void> _handleSend() async {
    if (_selectedIds.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await widget.onSend(_selectedIds, _captionController.text);
    } catch (e) {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => widget.onClose(),
                  child: Icon(
                    Icons.close,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 24.0,
                  ),
                ),
                const Spacer(),
                if (_openAlbum != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _openAlbum = null;
                        _tabIndex = 0;
                      });
                      _loadPage(reset: true);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 14.0,
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                        Text(
                          'Albums',
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      ],
                    ),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _tabIndex = 0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            'Photos',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(),
                                  fontWeight: _tabIndex == 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _tabIndex = 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            'Albums',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(),
                                  fontWeight: _tabIndex == 1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const Spacer(),
                const SizedBox(width: 24.0),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : (_openAlbum == null && _tabIndex == 1)
                    ? _buildAlbumList()
                    : _buildPhotoGrid(),
          ),
          if (_selectedIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  SizedBox(
                    height: 40,
                    child: Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: FlutterFlowTheme.of(context)
                                .primary
                                .withOpacity(0.15),
                          ),
                          child: Center(
                            child: Text(
                              '${_selectedIds.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextField(
                      controller: _captionController,
                      decoration: InputDecoration(
                        hintText: 'Add a caption...',
                        border: InputBorder.none,
                        hintStyle: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  GestureDetector(
                    onTap: _sending ? null : _handleSend,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                      child: _sending
                          ? const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 18.0,
                            ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(4.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _assets.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _assets.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.0),
              ),
            ),
          );
        }

        final asset = _assets[index];
        final isSelected = _selectedIds.contains(asset.id);
        final selectionNumber =
            isSelected ? _selectedIds.indexOf(asset.id) + 1 : null;
        final isVideo = asset.type == AssetType.video;

        return GestureDetector(
          onTap: () => _toggleSelect(asset),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: FutureBuilder<Uint8List?>(
                  future: asset.thumbnailDataWithSize(
                    const ThumbnailSize.square(200),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Container(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                      );
                    }
                    return Image.memory(snapshot.data!, fit: BoxFit.cover);
                  },
                ),
              ),
              if (isVideo)
                Positioned(
                  left: 4,
                  bottom: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_circle_fill,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 2),
                      Text(
                        _formatDuration(asset.videoDuration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(blurRadius: 2, color: Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (isSelected)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
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
                  width: 18,
                  height: 18,
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
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlbumList() {
    if (_albums.isEmpty) {
      return Center(
        child: Text(
          'No albums found.',
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _albums.length,
      itemBuilder: (context, index) {
        final album = _albums[index];
        return FutureBuilder<int>(
          future: album.assetCountAsync,
          builder: (context, countSnapshot) {
            return FutureBuilder<List<AssetEntity>>(
              future: album.getAssetListPaged(page: 0, size: 1),
              builder: (context, coverSnapshot) {
                final hasCover =
                    coverSnapshot.hasData && coverSnapshot.data!.isNotEmpty;
                return GestureDetector(
                  onTap: () => _openAlbumView(album),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: hasCover
                              ? FutureBuilder<Uint8List?>(
                                  future: coverSnapshot.data!.first
                                      .thumbnailDataWithSize(
                                    const ThumbnailSize.square(120),
                                  ),
                                  builder: (context, thumbSnap) {
                                    return Container(
                                      width: 56,
                                      height: 56,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      child: thumbSnap.hasData &&
                                              thumbSnap.data != null
                                          ? Image.memory(
                                              thumbSnap.data!,
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    );
                                  },
                                )
                              : Container(
                                  width: 56,
                                  height: 56,
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            album.name,
                            style: FlutterFlowTheme.of(context).bodyMedium,
                          ),
                        ),
                        Text(
                          countSnapshot.hasData ? '${countSnapshot.data}' : '',
                          style: FlutterFlowTheme.of(context).bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
