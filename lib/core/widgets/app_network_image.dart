import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Cached network image with a branded shimmer placeholder and graceful
/// fallback. Pass [url]; if empty, [fallbackUrl] (a dummy photo) is used.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    required this.fallbackUrl,
    this.fit = BoxFit.cover,
    this.tint,
  });

  final String url;
  final String fallbackUrl;
  final BoxFit fit;

  /// Placeholder tint. Null takes the theme's elevated surface — it cannot
  /// default to a token in the initialiser list, because tokens are resolved
  /// from the tree and a `const` constructor runs long before there is one.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final src = url.isNotEmpty ? url : fallbackUrl;
    return CachedNetworkImage(
      imageUrl: src,
      fit: fit,
      placeholder: (_, _) => _fallback(context),
      errorWidget: (_, _, _) => _fallback(context),
    );
  }

  Widget _fallback(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [tint ?? context.colors.surfaceHigh, context.colors.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );
}
