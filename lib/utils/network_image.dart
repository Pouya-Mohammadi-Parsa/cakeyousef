import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Memory-aware image: network (cached) or local `assets/...` paths.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholderColor,
    this.errorWidget,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? placeholderColor;
  final Widget? errorWidget;

  bool get _isAsset => url.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    final fill = placeholderColor ?? AppColors.creamDark;
    if (url.isEmpty) {
      return _box(errorWidget ?? ColoredBox(color: fill));
    }

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final memW = width != null ? (width! * dpr).round() : null;
    final memH = height != null ? (height! * dpr).round() : null;

    Widget image;
    if (_isAsset) {
      image = Image.asset(
        url,
        fit: fit,
        width: width,
        height: height,
        cacheWidth: memW,
        cacheHeight: memH,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) =>
            errorWidget ??
            ColoredBox(
              color: fill,
              child: Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.warm400,
                size: 28,
              ),
            ),
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        width: width,
        height: height,
        memCacheWidth: memW,
        memCacheHeight: memH,
        fadeInDuration: const Duration(milliseconds: 180),
        fadeOutDuration: const Duration(milliseconds: 120),
        placeholder: (_, __) => ColoredBox(color: fill),
        errorWidget: (_, __, ___) =>
            errorWidget ??
            ColoredBox(
              color: fill,
              child: Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.warm400,
                size: 28,
              ),
            ),
      );
    }

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _box(Widget child) {
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}
