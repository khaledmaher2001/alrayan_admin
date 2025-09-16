import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:flutter/material.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
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
    return CachedNetworkImage(
      width: imageWidth,
      height: imageHeight,
      imageUrl: imageUrl??"",
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[900]!,
        highlightColor: Colors.grey[200]!,
        child: Container(
          height: imageHeight,
          width: imageWidth,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          ),
        ),
      ),
      errorWidget: (context, url, error) =>  Container(decoration:BoxDecoration(
        color: color??Colors.white38,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),child: Center(child: Text(char??"",style: Styles.DIN24500(context).copyWith(
        color: Colors.white
      ),))),
      fit: fit??BoxFit.cover,
    );
  }
}
