import 'dart:io';

import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

/// Compact lock-screen card so staff see what customers get.
class PushPreview extends StatelessWidget {
  const PushPreview({super.key, required this.title, required this.message, this.imageUrl, this.localImage});

  final String title;
  final String message;
  final String? imageUrl;
  final File? localImage;

  @override
  Widget build(BuildContext context) {
    Widget? image;
    if (localImage != null) {
      image = Image.file(localImage!, width: 56, height: 56, fit: BoxFit.cover);
    } else if ((imageUrl ?? '').isNotEmpty) {
      image = Image.network(
        imageUrl!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox(width: 56, height: 56),
      );
    }
    return Container(
      padding: const EdgeInsets.all(DsSpace.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DsRadius.lg),
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [Color(0xff3b3b55), Color(0xff15151f)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("sn_preview".tr(), style: DsText.caption.copyWith(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: DsSpace.sm),
          Container(
            padding: const EdgeInsets.all(DsSpace.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .95),
              borderRadius: BorderRadius.circular(DsRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(AssetData.logo, width: 16, height: 16, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: DsSpace.sm),
                    Expanded(
                      child: Text("sn_brand".tr(), style: DsText.caption.copyWith(fontWeight: FontWeight.w700, fontSize: 11)),
                    ),
                    Text("sn_preview_now".tr(), style: DsText.caption.copyWith(fontSize: 11)),
                  ],
                ),
                const SizedBox(height: DsSpace.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.trim().isEmpty ? "sn_preview_title".tr() : title.trim(),
                            style: DsText.bodyStrong.copyWith(color: DsColor.onPrimarySoft),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            message.trim().isEmpty ? "sn_preview_msg".tr() : message.trim(),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: DsText.caption.copyWith(color: DsColor.text2),
                          ),
                        ],
                      ),
                    ),
                    if (image != null) ...[
                      const SizedBox(width: DsSpace.md),
                      ClipRRect(borderRadius: BorderRadius.circular(DsRadius.sm), child: image),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
