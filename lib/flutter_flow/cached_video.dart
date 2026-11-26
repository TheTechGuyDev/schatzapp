import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

import '/custom_code/actions/init_offline_store.dart' show OfflineStore;

const _indexKey = 'video_cache_index';

/// Video controller that plays a saved copy when one exists (so viewed
/// stories, For You posts and chat videos still play offline). Otherwise it
/// streams from the network and saves a copy in the background.
VideoPlayerController cachedVideoController(String url) {
  if (kIsWeb || url.isEmpty) {
    return VideoPlayerController.networkUrl(Uri.parse(url));
  }
  try {
    final index = OfflineStore.getMap(_indexKey) ?? const {};
    final path = index[url];
    if (path is String && path.isNotEmpty && File(path).existsSync()) {
      return VideoPlayerController.file(File(path));
    }
  } catch (_) {}
  _saveInBackground(url);
  return VideoPlayerController.networkUrl(Uri.parse(url));
}

final Set<String> _saving = {};

void _saveInBackground(String url) {
  if (_saving.contains(url)) return;
  _saving.add(url);
  DefaultCacheManager().getSingleFile(url).then((file) async {
    final index =
        Map<String, dynamic>.from(OfflineStore.getMap(_indexKey) ?? const {});
    index[url] = file.path;
    // Keep the index small; the cache manager cleans old files itself.
    while (index.length > 300) {
      index.remove(index.keys.first);
    }
    await OfflineStore.putJson(_indexKey, index);
  }).catchError((_) {}).whenComplete(() => _saving.remove(url));
}
