import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

/// Drop-in replacement for [Image.network] that keeps a copy on the device,
/// so avatars, photos and story images still show with no internet.
Image cachedNetworkImage(
  String src, {
  Key? key,
  double scale = 1.0,
  ImageFrameBuilder? frameBuilder,
  ImageLoadingBuilder? loadingBuilder,
  ImageErrorWidgetBuilder? errorBuilder,
  String? semanticLabel,
  bool excludeFromSemantics = false,
  double? width,
  double? height,
  Color? color,
  Animation<double>? opacity,
  BlendMode? colorBlendMode,
  BoxFit? fit,
  AlignmentGeometry alignment = Alignment.center,
  ImageRepeat repeat = ImageRepeat.noRepeat,
  Rect? centerSlice,
  bool matchTextDirection = false,
  bool gaplessPlayback = false,
  FilterQuality filterQuality = FilterQuality.medium,
  bool isAntiAlias = false,
  Map<String, String>? headers,
  int? cacheWidth,
  int? cacheHeight,
}) {
  return Image(
    key: key,
    image: ResizeImage.resizeIfNeeded(
      cacheWidth,
      cacheHeight,
      CachedNetworkImageProvider(src, scale: scale, headers: headers),
    ),
    frameBuilder: frameBuilder,
    loadingBuilder: loadingBuilder,
    errorBuilder: errorBuilder,
    semanticLabel: semanticLabel,
    excludeFromSemantics: excludeFromSemantics,
    width: width,
    height: height,
    color: color,
    opacity: opacity,
    colorBlendMode: colorBlendMode,
    fit: fit,
    alignment: alignment,
    repeat: repeat,
    centerSlice: centerSlice,
    matchTextDirection: matchTextDirection,
    gaplessPlayback: gaplessPlayback,
    filterQuality: filterQuality,
    isAntiAlias: isAntiAlias,
  );
}

/// Drop-in replacement for [NetworkImage] with an on-device cache.
ImageProvider cachedNetworkImageProvider(String url,
        {double scale = 1.0, Map<String, String>? headers}) =>
    CachedNetworkImageProvider(url, scale: scale, headers: headers);
