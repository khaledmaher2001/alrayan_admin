import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_widgets/notification_bell_button.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/get_settings/get_settings_cubit.dart';
import 'package:alrayan_admin/features/home/data/models/home_statistics_model.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_home_statistics/get_home_statistics_cubit.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_home_statistics/get_home_statistics_states.dart';
import 'package:alrayan_admin/features/home/presentation/views/low_stock_products_view.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/home_analytics_sections.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/home_dashboard_v2.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/most_ordered_item.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/reviews_summary_statistics.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/top_customer_item.dart';
import 'package:alrayan_admin/features/main_layout/view_model/change_nav_bar_status/change_nav_bar_status_cubit.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/features/profile/presentation/view_model/get_profile/get_profile_cubit.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/get_profile/get_profile_state.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/api_service.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/complaints/data/admin_complaints_repo.dart';
import 'package:alrayan_admin/features/complaints/presentation/admin_complaints_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class HomeViewBody extends StatefulWidget {
  const HomeViewBody({super.key});

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody> {
  DashboardPeriod _period = DashboardPeriod.today;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetProfileCubit, GetProfileStates>(
      builder: (context, profileState) {
        final profile = profileState is GetProfileSuccessState ? profileState.model.data : null;
        // The figures need the "orders" or "reports" permission (server rule);
        // other staff get a simple start page instead of an endless skeleton.
        if (profile != null && !profile.can("orders") && !profile.can("reports")) {
          return _StaffStartPage(name: profile.fullName);
        }
        return _buildStats(context, profile?.fullName);
      },
    );
  }

  Widget _buildStats(BuildContext context, String? name) {
    return BlocBuilder<GetHomeStatisticsCubit, GetHomeStatisticsStates>(
      builder: (context, state) {
        if (state is GetHomeStatisticsErrorState) {
          return SafeArea(
            child: _HomeMessage(
              icon: Icons.wifi_off_rounded,
              title: "home_load_failed".tr(),
              action: TextButton(
                onPressed: () => context.read<GetHomeStatisticsCubit>().getHomeStatistics(),
                child: Text("home_retry".tr(), style: DsText.bodyStrong.copyWith(color: DsColor.primary)),
              ),
            ),
          );
        }
        if (state is GetHomeStatisticsSuccessState) {
          final overview = state.model.overview;
          final ordersByStatus = state.model.orderStats?.ordersByStatus ?? [];
          final pendingCount = ordersByStatus.firstWhere((s) => s.status == "pending", orElse: () => OrdersByStatus(count: 0)).count ?? 0;
          // "قيد التوصيل" = كل طلب اتأكد ولسه ماوصلش للعميل (تم تأكيده +
          // تم الشحن) — "طلبات جديدة" فوق دي بتغطي pending لوحدها، وتم
          // التسليم مش جزء من "قيد التوصيل".
          final inDeliveryCount = ordersByStatus.where((s) => s.status == "confirmed" || s.status == "shipped").fold<int>(0, (sum, s) => sum + (s.count ?? 0));

          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([context.read<GetHomeStatisticsCubit>().getHomeStatistics(), context.read<GetSettingsCubit>().getSettings()]);
            },
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: DsSpace.page),
                  child: Column(
                    children: [
                      const SizedBox(height: DsSpace.md),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_hello(name), maxLines: 1, overflow: TextOverflow.ellipsis, style: DsText.title),
                                Text("home_subtitle".tr(), maxLines: 1, overflow: TextOverflow.ellipsis, style: DsText.caption.copyWith(fontSize: 13)),
                              ],
                            ),
                          ),
                          const SizedBox(width: DsSpace.sm),
                          const NotificationBellButton(),
                        ],
                      ),
                      const SizedBox(height: DsSpace.lg),
                      DashboardPeriodSelector(selected: _period, onChanged: (period) => setState(() => _period = period)),
                      const SizedBox(height: DsSpace.md),
                      TotalSalesHeroCard(
                        period: _period,
                        recentStats: state.model.recentStats,
                        trends: state.model.trends,
                        totalOrders: overview?.totalOrders,
                        totalCustomers: overview?.totalCustomers,
                      ),
                      DsSectionHeader(title: "home_needs_action".tr()),
                      DsGroup(
                        children: [
                          DashboardActionRow(
                            icon: Icons.shopping_bag_outlined,
                            title: "home_new_orders".tr(),
                            count: pendingCount,
                            tone: DsColor.warning,
                            toneBg: DsColor.warningBg,
                            onTap: () => context.read<ChangeNavBarStatusCubit>().changeNavBarIndex(1),
                          ),
                          DashboardActionRow(
                            icon: Icons.local_shipping_outlined,
                            title: "home_in_delivery".tr(),
                            count: inDeliveryCount,
                            tone: DsColor.info,
                            toneBg: DsColor.infoBg,
                            onTap: () => context.read<ChangeNavBarStatusCubit>().changeNavBarIndex(1),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DashboardActionRow(
                                icon: Icons.inventory_2_outlined,
                                title: "home_low_stock".tr(),
                                count: state.lowStockProductsTotal ?? state.lowStockProducts.length,
                                tone: DsColor.danger,
                                toneBg: DsColor.dangerBg,
                                onTap: () => NavigationUtils.navigateTo(context: context, destinationScreen: const LowStockProductsView()),
                              ),
                              const _ComplaintsNeedsAction(),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: DsSpace.section),
                      SalesPerformanceSection(period: _period, trends: state.model.trends, overview: overview),
                      const SizedBox(height: DsSpace.md),
                      OrderStatusDonutSection(ordersByStatus: ordersByStatus, totalOrders: overview?.totalOrders ?? 0),
                      DsSectionHeader(title: "home_highlights".tr()),
                      if (state.model.reviewStats != null) ...[ReviewsSummaryStatistic(instance: state.model.reviewStats!), const SizedBox(height: DsSpace.md)],
                      if ((state.model.topCustomers ?? []).isNotEmpty) ...[
                        TopCustomerItem(instance: state.model.topCustomers!.first, fromHome: true, index: 0),
                        const SizedBox(height: DsSpace.md),
                      ],
                      if ((state.model.productStats?.topSellingProducts ?? []).isNotEmpty)
                        MostOrderedItem(instance: state.model.productStats!.topSellingProducts!.first, fromHome: true),
                      const SizedBox(height: DsSpace.section),
                      InventoryAnalyticsSection(items: state.inventoryAnalytics, error: state.inventoryAnalyticsError),
                      const SizedBox(height: DsSpace.section),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([context.read<GetHomeStatisticsCubit>().getHomeStatistics(), context.read<GetSettingsCubit>().getSettings()]);
            },
            child: SafeArea(child: const HomeViewBodyShimmer()),
          );
        }
      },
    );
  }
}

class HomeViewBodyShimmer extends StatelessWidget {
  const HomeViewBodyShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: DsColor.border,
      highlightColor: DsColor.fill,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
          child: Column(
            children: [
              SizedBox(height: AppConstants.height20(context)),
              Row(
                children: [
                  _shimmerBox(context, width: AppConstants.sp30(context), height: AppConstants.sp30(context), radius: AppConstants.sp5(context)),
                  SizedBox(width: AppConstants.width10(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerBox(context, width: MediaQuery.of(context).size.width * .38, height: AppConstants.height15(context)),
                        SizedBox(height: AppConstants.height10(context) / 2),
                        _shimmerBox(context, width: MediaQuery.of(context).size.width * .48, height: AppConstants.height10(context)),
                      ],
                    ),
                  ),
                  SizedBox(width: AppConstants.width10(context)),
                  _shimmerCircle(size: MediaQuery.of(context).size.width * .1),
                ],
              ),
              SizedBox(height: AppConstants.height20(context)),
              Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) SizedBox(width: AppConstants.width10(context)),
                    Expanded(
                      child: _shimmerBox(context, width: double.infinity, height: AppConstants.height20(context) * 2, radius: AppConstants.sp30(context)),
                    ),
                  ],
                ],
              ),
              SizedBox(height: AppConstants.height20(context)),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _shimmerBox(context, width: double.infinity, height: double.infinity, radius: AppConstants.sp15(context)),
                    ),
                    SizedBox(width: AppConstants.width10(context)),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Expanded(child: StatisticsHomeItemShimmer()),
                          SizedBox(height: AppConstants.height10(context)),
                          Expanded(child: StatisticsHomeItemShimmer()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppConstants.height10(context)),
              _shimmerBox(context, width: double.infinity, height: AppConstants.height20(context) * 3.2, radius: AppConstants.sp10(context)),
              SizedBox(height: AppConstants.height10(context)),
              Row(
                children: [
                  const Expanded(child: StatisticsHomeItemShimmer()),
                  SizedBox(width: AppConstants.width10(context)),
                  const Expanded(child: StatisticsHomeItemShimmer()),
                  SizedBox(width: AppConstants.width10(context)),
                  const Expanded(child: StatisticsHomeItemShimmer()),
                ],
              ),
              SizedBox(height: AppConstants.height20(context)),
              const HomeAnalyticsSectionShimmer(),
              SizedBox(height: AppConstants.height10(context)),
              const OrdersStatusItemShimmer(),
              SizedBox(height: AppConstants.height20(context)),
              _shimmerBox(context, width: MediaQuery.of(context).size.width * .3, height: AppConstants.height15(context)),
              SizedBox(height: AppConstants.height10(context)),
              const ReviewsSummaryStatisticShimmer(),
              SizedBox(height: AppConstants.height15(context)),
              const TopCustomerItemShimmer(),
              SizedBox(height: AppConstants.height15(context)),
              const MostOrderedItemShimmer(),
              SizedBox(height: AppConstants.height20(context)),
              const InventoryAnalyticsSectionShimmer(),
              SizedBox(height: AppConstants.height20(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class StatisticsHomeItemShimmer extends StatelessWidget {
  const StatisticsHomeItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp10(context)),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppConstants.sp10(context))),
      child: Column(
        children: [
          _shimmerBox(
            context,
            width: MediaQuery.of(context).size.width * .08,
            height: MediaQuery.of(context).size.width * .08,
            radius: AppConstants.sp10(context),
          ),
          SizedBox(height: AppConstants.height10(context)),
          _shimmerBox(context, width: MediaQuery.of(context).size.width * .16, height: AppConstants.height10(context)),
          SizedBox(height: AppConstants.height5(context)),
          _shimmerBox(context, width: MediaQuery.of(context).size.width * .10, height: AppConstants.height10(context)),
        ],
      ),
    );
  }
}

class OrdersStatusItemShimmer extends StatelessWidget {
  const OrdersStatusItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp20(context)),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppConstants.sp10(context))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(context, width: MediaQuery.of(context).size.width * .28, height: AppConstants.height15(context)),
          SizedBox(height: AppConstants.height20(context)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _shimmerCircle(size: MediaQuery.of(context).size.width * .32),
              SizedBox(width: AppConstants.width20(context)),
              Expanded(
                child: Column(
                  children: List.generate(
                    6,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: AppConstants.height10(context)),
                      child: Row(
                        children: [
                          _shimmerBox(context, width: 10, height: 10, radius: 5),
                          SizedBox(width: AppConstants.width10(context)),
                          Expanded(
                            child: _shimmerBox(context, width: double.infinity, height: AppConstants.height10(context)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReviewsSummaryStatisticShimmer extends StatelessWidget {
  const ReviewsSummaryStatisticShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp20(context)),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppConstants.sp10(context))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _shimmerBox(context, width: double.infinity, height: AppConstants.height15(context)),
              ),
              SizedBox(width: AppConstants.width10(context)),
              _shimmerBox(context, width: MediaQuery.of(context).size.width * .20, height: AppConstants.height30(context), radius: AppConstants.sp5(context)),
            ],
          ),
          SizedBox(height: AppConstants.height20(context)),
          _shimmerBox(context, width: MediaQuery.of(context).size.width * .35, height: AppConstants.height20(context)),
          SizedBox(height: AppConstants.height20(context)),
          ...List.generate(
            5,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: AppConstants.height20(context)),
              child: Row(
                children: [
                  _shimmerBox(context, width: MediaQuery.of(context).size.width * .15, height: AppConstants.height10(context)),
                  SizedBox(width: AppConstants.width10(context)),
                  Expanded(
                    child: _shimmerBox(context, width: double.infinity, height: AppConstants.height10(context), radius: AppConstants.sp30(context)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MostOrderedItemShimmer extends StatelessWidget {
  const MostOrderedItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp20(context)),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppConstants.sp10(context))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _shimmerBox(context, width: double.infinity, height: AppConstants.height15(context)),
              ),
              SizedBox(width: AppConstants.width20(context)),
              _shimmerBox(context, width: MediaQuery.of(context).size.width * .18, height: AppConstants.height30(context), radius: AppConstants.sp5(context)),
            ],
          ),
          SizedBox(height: AppConstants.height10(context) / 2),
          _shimmerBox(context, width: MediaQuery.of(context).size.width * .50, height: AppConstants.height10(context)),
          SizedBox(height: AppConstants.height20(context)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _shimmerBox(
                context,
                width: MediaQuery.of(context).size.width * .12,
                height: MediaQuery.of(context).size.width * .12,
                radius: AppConstants.sp10(context),
              ),
              SizedBox(width: AppConstants.width15(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(context, width: MediaQuery.of(context).size.width * .3, height: AppConstants.height10(context)),
                    SizedBox(height: AppConstants.height10(context) / 2),
                    _shimmerBox(context, width: MediaQuery.of(context).size.width * .22, height: AppConstants.height10(context)),
                    SizedBox(height: AppConstants.height10(context) / 2),
                    _shimmerBox(context, width: MediaQuery.of(context).size.width * .26, height: AppConstants.height10(context)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TopCustomerItemShimmer extends StatelessWidget {
  const TopCustomerItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp20(context)),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppConstants.sp10(context))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _shimmerBox(context, width: double.infinity, height: AppConstants.height15(context)),
              ),
              SizedBox(width: AppConstants.width20(context)),
              _shimmerBox(context, width: MediaQuery.of(context).size.width * .18, height: AppConstants.height30(context), radius: AppConstants.sp5(context)),
            ],
          ),
          SizedBox(height: AppConstants.height10(context) / 2),
          _shimmerBox(context, width: MediaQuery.of(context).size.width * .48, height: AppConstants.height10(context)),
          SizedBox(height: AppConstants.height20(context)),
          Row(
            children: [
              _shimmerBox(
                context,
                width: MediaQuery.of(context).size.width * .12,
                height: MediaQuery.of(context).size.width * .12,
                radius: AppConstants.sp10(context),
              ),
              SizedBox(width: AppConstants.width10(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(context, width: MediaQuery.of(context).size.width * .26, height: AppConstants.height10(context)),
                    SizedBox(height: AppConstants.height10(context) / 2),
                    _shimmerBox(context, width: MediaQuery.of(context).size.width * .30, height: AppConstants.height10(context)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _shimmerBox(context, width: MediaQuery.of(context).size.width * .10, height: AppConstants.height10(context)),
                  SizedBox(height: AppConstants.height10(context) / 2),
                  _shimmerBox(context, width: MediaQuery.of(context).size.width * .14, height: AppConstants.height10(context)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeAnalyticsSectionShimmer extends StatelessWidget {
  const HomeAnalyticsSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp20(context)),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppConstants.sp10(context))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(context, width: MediaQuery.of(context).size.width * .32, height: AppConstants.height15(context)),
                    SizedBox(height: AppConstants.height10(context) / 2),
                    _shimmerBox(context, width: MediaQuery.of(context).size.width * .5, height: AppConstants.height10(context)),
                  ],
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
              _shimmerBox(context, width: MediaQuery.of(context).size.width * .18, height: AppConstants.height30(context), radius: AppConstants.sp5(context)),
            ],
          ),
          SizedBox(height: AppConstants.height20(context)),
          _shimmerBox(context, width: double.infinity, height: MediaQuery.of(context).size.height * .18),
          SizedBox(height: AppConstants.height15(context)),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(context, width: MediaQuery.of(context).size.width * .28, height: AppConstants.height10(context)),
                    SizedBox(height: AppConstants.height5(context)),
                    _shimmerBox(context, width: MediaQuery.of(context).size.width * .2, height: AppConstants.height15(context)),
                  ],
                ),
              ),
              Container(width: 1, height: AppConstants.height30(context), color: Colors.white),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: AppConstants.width15(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(context, width: MediaQuery.of(context).size.width * .28, height: AppConstants.height10(context)),
                      SizedBox(height: AppConstants.height5(context)),
                      _shimmerBox(context, width: MediaQuery.of(context).size.width * .2, height: AppConstants.height15(context)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InventoryAnalyticsSectionShimmer extends StatelessWidget {
  const InventoryAnalyticsSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp20(context)),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppConstants.sp10(context))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(context, width: MediaQuery.of(context).size.width * .32, height: AppConstants.height15(context)),
                    SizedBox(height: AppConstants.height10(context) / 2),
                    _shimmerBox(context, width: MediaQuery.of(context).size.width * .5, height: AppConstants.height10(context)),
                  ],
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
              _shimmerBox(context, width: MediaQuery.of(context).size.width * .18, height: AppConstants.height30(context), radius: AppConstants.sp5(context)),
            ],
          ),
          SizedBox(height: AppConstants.height20(context)),
          for (var i = 0; i < 2; i++) ...[
            Row(
              children: [
                _shimmerBox(context, width: AppConstants.width20(context) * 2, height: AppConstants.width20(context) * 2),
                SizedBox(width: AppConstants.width10(context)),
                Expanded(
                  child: _shimmerBox(context, width: double.infinity, height: AppConstants.height15(context)),
                ),
                SizedBox(width: AppConstants.width10(context)),
                _shimmerBox(context, width: 50, height: AppConstants.height15(context)),
              ],
            ),
            SizedBox(height: AppConstants.height15(context)),
            _shimmerBox(context, width: double.infinity, height: AppConstants.height10(context) - 2, radius: 30),
            SizedBox(height: AppConstants.height10(context)),
            Row(
              children: [
                _shimmerBox(context, width: 70, height: AppConstants.height20(context), radius: 30),
                SizedBox(width: AppConstants.width10(context)),
                _shimmerBox(context, width: 70, height: AppConstants.height20(context), radius: 30),
                SizedBox(width: AppConstants.width10(context)),
                _shimmerBox(context, width: 70, height: AppConstants.height20(context), radius: 30),
              ],
            ),
            if (i == 0) SizedBox(height: AppConstants.height15(context)),
          ],
        ],
      ),
    );
  }
}

String _hello(String? name) {
  final first = (name ?? "").trim().split(" ").first;
  return first.isEmpty ? "home_hello".tr() : "home_hello_name".tr(namedArgs: {"name": first});
}

/// Start page for staff whose permissions don't include the store figures.
class _StaffStartPage extends StatelessWidget {
  const _StaffStartPage({this.name});
  final String? name;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _HomeMessage(
        icon: Icons.waving_hand_outlined,
        title: _hello(name),
        subtitle: "home_staff_hint".tr(),
        action: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: DsColor.primary,
            minimumSize: const Size(200, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => context.read<ChangeNavBarStatusCubit>().changeNavBarIndex(3),
          icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
          label: Text("home_open_more".tr(), style: DsText.bodyStrong.copyWith(color: Colors.white)),
        ),
      ),
    );
  }
}

class _HomeMessage extends StatelessWidget {
  const _HomeMessage({required this.icon, required this.title, this.subtitle, this.action});
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.width20(context) * 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: DsColor.primary.withValues(alpha: .08), shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: DsColor.primary),
            ),
            SizedBox(height: AppConstants.height15(context)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: DsText.heading,
            ),
            if (subtitle != null) ...[
              SizedBox(height: AppConstants.height10(context)),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: DsText.body.copyWith(color: DsColor.textMuted),
              ),
            ],
            if (action != null) ...[SizedBox(height: AppConstants.height20(context)), action!],
          ],
        ),
      ),
    );
  }
}

Widget _shimmerBox(BuildContext context, {required double width, required double height, double? radius}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius ?? AppConstants.sp10(context))),
  );
}

Widget _shimmerCircle({required double size}) {
  return Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
  );
}

/// "New complaints" shortcut under "Needs action" — only for staff who handle
/// customers; loads the open/overdue counts once and refreshes on return.
class _ComplaintsNeedsAction extends StatefulWidget {
  const _ComplaintsNeedsAction();

  @override
  State<_ComplaintsNeedsAction> createState() => _ComplaintsNeedsActionState();
}

class _ComplaintsNeedsActionState extends State<_ComplaintsNeedsAction> {
  AdminComplaintStats? _stats;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await AdminComplaintsRepo(getIt.get<ApiService>()).stats();
      if (mounted) setState(() => _stats = s);
    } catch (_) {
      // The shortcut simply stays hidden if the counts can't be loaded.
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<GetProfileCubit>().state;
    final profile = profileState is GetProfileSuccessState ? profileState.model.data : null;
    final s = _stats;
    if (profile == null || !profile.can('customers') || s == null) return const SizedBox.shrink();
    // Sits inside the "needs action" group under low stock, so it brings its own hairline.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1, thickness: 1, indent: DsSpace.lg, endIndent: DsSpace.lg, color: DsColor.divider),
        DashboardActionRow(
          icon: Icons.forum_outlined,
          title: "home_new_complaints".tr(),
          count: s.open,
          tone: DsColor.primary,
          toneBg: DsColor.primarySoft,
          extra: s.overdue > 0
              ? DsStatusBadge(status: null, label: "${"adx_late".tr()} ${formatCount(s.overdue)}", fg: DsColor.danger, bg: DsColor.dangerBg)
              : null,
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminComplaintsView()));
            _load();
          },
        ),
      ],
    );
  }
}
