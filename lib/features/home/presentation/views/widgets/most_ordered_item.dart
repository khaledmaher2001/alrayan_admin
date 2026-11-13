import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/home/data/models/home_statistics_model.dart';
import 'package:alrayan_admin/features/top_products/presentation/views/top_products_view.dart';
import 'package:flutter/material.dart';

import '../../../../../core/shared_widgets/default_cached_network_image.dart';
import 'home_analytics_sections.dart';

/// Best-selling product: thumbnail, name, units sold, revenue.
/// On home it sits in a section card with "view all".
class MostOrderedItem extends StatelessWidget {
  const MostOrderedItem({super.key, required this.instance, required this.fromHome});
  final TopSellingProducts instance;
  final bool fromHome;

  @override
  Widget build(BuildContext context) {
    final revenue = instance.revenue is num ? instance.revenue as num : num.tryParse('${instance.revenue}');
    final row = Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(DsRadius.md),
          child: DefaultCachedNetworkImage(
            imageUrl: instance.image ?? '',
            imageHeight: 48,
            imageWidth: 48,
            fit: BoxFit.cover,
            char: instance.name?.isNotEmpty == true ? instance.name![0] : '',
          ),
        ),
        const SizedBox(width: DsSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(instance.name ?? '-', maxLines: 1, overflow: TextOverflow.ellipsis, style: DsText.bodyStrong),
              Text("i_sold_x_times_52".tr(namedArgs: {"a": DsFormat.count(instance.totalSold ?? 0)}), style: DsText.caption),
            ],
          ),
        ),
        if (revenue != null) ...[
          const SizedBox(width: DsSpace.sm),
          Text(DsFormat.money(revenue), style: DsText.bodyStrong.copyWith(color: DsColor.primary)),
        ],
      ],
    );
    if (!fromHome) return DsCard(child: row);
    return HomeAnalyticsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(
            title: "s_best_sellers".tr(),
            subtitle: "s_keep_the_most_requested_products_wel".tr(),
            trailing: HomeViewAllButton(onTap: () => NavigationUtils.navigateTo(context: context, destinationScreen: TopProductsView())),
          ),
          const SizedBox(height: DsSpace.md),
          row,
        ],
      ),
    );
  }
}
