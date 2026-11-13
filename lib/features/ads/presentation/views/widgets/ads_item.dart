import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/features/ads/data/models/offer_banner_model.dart';
import 'package:alrayan_admin/features/ads/presentation/views/add_ads_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/shared_widgets/default_cached_network_image.dart';
import '../../../../../core/utils/navigation_utility.dart';
import '../../view_models/delete_banner/delete_banner_cubit.dart';

/// Banner card: the artwork is the content, so it leads as a wide preview
/// (as customers see it); type, copy and destination follow; edit/delete in ⋯.
class AdsItem extends StatelessWidget {
  const AdsItem({
    super.key,
    required this.instance,
    required this.onDeleteTap,
  });

  final Data instance;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context) {
    final isOffer = instance.type == "discount";
    final hasLink = instance.link != null && instance.link!.isNotEmpty;
    return DsCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 7,
            child: LayoutBuilder(
              builder: (context, c) => DefaultCachedNetworkImage(
                imageUrl: instance.imagePath ?? "",
                imageWidth: c.maxWidth,
                imageHeight: c.maxHeight,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(DsSpace.lg, DsSpace.md, DsSpace.xs, DsSpace.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DsStatusBadge(
                        status: null,
                        icon: isOffer ? Icons.local_offer_outlined : Icons.campaign_outlined,
                        label: isOffer ? "ds_ad_product_offer".tr() : "ds_ad_regular".tr(),
                        fg: isOffer ? DsColor.onPrimarySoft : DsColor.text2,
                        bg: isOffer ? DsColor.primarySoft : DsColor.fill,
                      ),
                      const SizedBox(height: DsSpace.sm),
                      if ((instance.title ?? '').isNotEmpty) Text(instance.title!, style: DsText.bodyStrong),
                      if ((instance.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(instance.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: DsText.caption),
                      ],
                      const SizedBox(height: DsSpace.sm),
                      if (instance.product != null)
                        _Meta(icon: Icons.inventory_2_outlined, text: "i_linked_product".tr(namedArgs: {"a": instance.product?.name ?? ""})),
                      _Meta(icon: Icons.link_rounded, text: hasLink ? instance.link! : "s_no_link".tr(), ltr: hasLink),
                    ],
                  ),
                ),
                BlocBuilder<DeleteBannersCubit, DeleteBannersState>(
                  builder: (context, state) {
                    final deleting = state is DeleteBannersLoading && context.read<DeleteBannersCubit>().selectedBanner == instance.id;
                    if (deleting) {
                      return const SizedBox(
                        width: DsSize.touch,
                        height: DsSize.touch,
                        child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: DsColor.danger))),
                      );
                    }
                    return PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, color: DsColor.textMuted),
                      onSelected: (v) {
                        if (v == 'edit') {
                          NavigationUtils.navigateTo(context: context, destinationScreen: AddAdsView(editingBanner: instance));
                        } else {
                          onDeleteTap();
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [const Icon(Icons.edit_outlined, size: 20, color: DsColor.text2), const SizedBox(width: DsSpace.md), Text("s_edit".tr(), style: DsText.body)]),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            const Icon(Icons.delete_outline_rounded, size: 20, color: DsColor.danger),
                            const SizedBox(width: DsSpace.md),
                            Text("s_delete".tr(), style: DsText.body.copyWith(color: DsColor.danger)),
                          ]),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text, this.ltr = false});
  final IconData icon;
  final String text;
  final bool ltr;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          children: [
            Icon(icon, size: 14, color: DsColor.textMuted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: ltr ? TextDirection.ltr : null,
                textAlign: TextAlign.start,
                style: DsText.caption,
              ),
            ),
          ],
        ),
      );
}
