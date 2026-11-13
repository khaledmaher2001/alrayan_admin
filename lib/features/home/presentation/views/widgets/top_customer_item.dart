import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/home/data/models/home_statistics_model.dart';
import 'package:alrayan_admin/features/top_users/presentation/views/top_users_view.dart';
import 'package:flutter/material.dart';

import 'home_analytics_sections.dart';

/// Most active customer: neutral initials avatar, name + email, order count.
/// On home it sits in a section card with "view all".
class TopCustomerItem extends StatelessWidget {
  const TopCustomerItem({super.key, required this.instance, required this.fromHome, required this.index});
  final TopCustomers instance;
  final bool fromHome;
  final int index;

  @override
  Widget build(BuildContext context) {
    final initials = (instance.fullName ?? '').split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase();
    final row = Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: DsColor.primarySoft, shape: BoxShape.circle),
          child: Text(initials, style: DsText.bodyStrong.copyWith(color: DsColor.onPrimarySoft)),
        ),
        const SizedBox(width: DsSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(instance.fullName ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: DsText.bodyStrong),
              Text(instance.email ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr, textAlign: TextAlign.start, style: DsText.caption),
            ],
          ),
        ),
        const SizedBox(width: DsSpace.sm),
        DsStatusBadge(status: null, label: "i_x_orders_55".tr(namedArgs: {"a": DsFormat.count(instance.orderCount)}), fg: DsColor.text2, bg: DsColor.fill),
      ],
    );
    if (!fromHome) return DsCard(child: row);
    return HomeAnalyticsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(
            title: "s_most_active_customers".tr(),
            subtitle: "s_create_discount_coupons_to_reward_yo".tr(),
            trailing: HomeViewAllButton(onTap: () => NavigationUtils.navigateTo(context: context, destinationScreen: TopUsersView())),
          ),
          const SizedBox(height: DsSpace.md),
          row,
        ],
      ),
    );
  }
}
