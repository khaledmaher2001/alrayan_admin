import 'package:alrayan_admin/core/design/ds.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/constants.dart';

/// Wraps [child] in the same shimmer sweep used across the app (home page,
/// image placeholders, etc.) — same colors, so every skeleton loader reads
/// as one consistent effect no matter which screen it's on.
Widget appShimmer({required Widget child}) {
  return Shimmer.fromColors(
    baseColor: DsColor.border,
    highlightColor: DsColor.fill,
    child: child,
  );
}

/// A solid placeholder block — the shimmer sweep paints over this shape.
Widget shimmerBox(
  BuildContext context, {
  required double width,
  required double height,
  double? radius,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius ?? AppConstants.sp10(context)),
    ),
  );
}

Widget shimmerCircle({required double size}) {
  return Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
  );
}
