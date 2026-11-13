import 'package:alrayan_admin/core/design/ds.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DefaultCachedNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final String? char;
  final double? imageWidth;
  final double? imageHeight;
  final BoxFit? fit;
  final Color? color;
  const DefaultCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.imageHeight,
    this.imageWidth, this.fit, this.color, this.char,
  });

  @override
  Widget build(BuildContext context) {
    // Neutral placeholders: a light shimmer while loading, a quiet image icon
    // (or the first letter) when there is no picture. [color] tints that tile.
    Widget tile({Widget? child}) => Container(
          width: imageWidth,
          height: imageHeight,
          alignment: Alignment.center,
          color: color ?? DsColor.fill,
          child: child,
        );
    final side = [imageWidth ?? 48, imageHeight ?? 48].reduce((a, b) => a < b ? a : b);
    return CachedNetworkImage(
      width: imageWidth,
      height: imageHeight,
      imageUrl: imageUrl ?? "",
      placeholder: (context, url) => Shimmer.fromColors(baseColor: DsColor.border, highlightColor: DsColor.fill, child: tile()),
      errorWidget: (context, url, error) => tile(
        child: (char ?? "").isNotEmpty
            ? Text(char!.toUpperCase(), style: DsText.bodyStrong.copyWith(color: DsColor.textMuted, fontSize: (side * .4).clamp(12, 28)))
            : Icon(Icons.image_outlined, color: DsColor.textSubtle, size: (side * .4).clamp(16, 40)),
      ),
      fit: fit ?? BoxFit.cover,
    );
  }
}
