import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/delivery/data/repo/delivery_repo_impl.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_statistics/get_delivery_statistics_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/delivery_accounts_view.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/release_logs_view.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/remittances_view.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/delivery_statistics_section.dart';
import 'package:alrayan_admin/features/orders/presentation/view/awaiting_customer_orders_view.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Delivery hub (reached from More): what needs attention, the team and the
/// money at a glance, then the four sub-sections as one grouped list.
class DeliveryManagementView extends StatelessWidget {
  const DeliveryManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetDeliveryStatisticsCubit(getIt<DeliveryRepoImpl>())..getStatistics(),
      child: const _DeliveryManagementBody(),
    );
  }
}

class _DeliveryManagementBody extends StatelessWidget {
  const _DeliveryManagementBody();

  @override
  Widget build(BuildContext context) {
    void go(Widget w) => NavigationUtils.navigateTo(context: context, destinationScreen: w);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DsTopBar(title: "delivery_management".tr(), subtitle: "s_follow_the_delivery_team_and_orders".tr()),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<GetDeliveryStatisticsCubit>().getStatistics(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(DsSpace.page, 0, DsSpace.page, DsSpace.xxxl),
                  children: [
                    const DeliveryStatisticsSection(),
                    DsSectionHeader(title: "s_delivery_management".tr()),
                    DsGroup(
                      children: [
                        DsRow(
                          icon: Icons.two_wheeler_rounded,
                          title: "delivery_couriers".tr(),
                          subtitle: "delivery_couriers_subtitle".tr(),
                          onTap: () => go(const DeliveryAccountsView()),
                        ),
                        DsRow(
                          icon: Icons.person_pin_circle_outlined,
                          title: "awaiting_customer_orders".tr(),
                          subtitle: "awaiting_customer_orders_subtitle".tr(),
                          onTap: () => go(const AwaitingCustomerOrdersView()),
                        ),
                        DsRow(
                          icon: Icons.fact_check_outlined,
                          title: "delivery_release_logs".tr(),
                          subtitle: "delivery_release_logs_subtitle".tr(),
                          onTap: () => go(const ReleaseLogsView()),
                        ),
                        DsRow(
                          icon: Icons.account_balance_wallet_outlined,
                          title: "delivery_remittances".tr(),
                          subtitle: "delivery_remittances_subtitle".tr(),
                          onTap: () => go(const RemittancesView()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
