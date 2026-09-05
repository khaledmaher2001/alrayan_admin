import 'package:alrayan_admin/core/shared_widgets/notification_bell_button.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/all_users/presentation/views/all_users_view.dart';
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
    return BlocBuilder<GetHomeStatisticsCubit, GetHomeStatisticsStates>(
      builder: (context, state) {
        if (state is GetHomeStatisticsSuccessState) {
          final overview = state.model.overview;
          final ordersByStatus = state.model.orderStats?.ordersByStatus ?? [];
          final pendingCount = ordersByStatus
              .firstWhere(
                (s) => s.status == "pending",
                orElse: () => OrdersByStatus(count: 0),
              )
              .count ??
              0;
          // "قيد التوصيل" = كل طلب اتأكد ولسه ماوصلش للعميل (تم تأكيده +
          // تم الشحن) — "طلبات جديدة" فوق دي بتغطي pending لوحدها، وتم
          // التسليم مش جزء من "قيد التوصيل".
          final inDeliveryCount = ordersByStatus
              .where((s) => s.status == "confirmed" || s.status == "shipped")
              .fold<int>(0, (sum, s) => sum + (s.count ?? 0));

          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                context.read<GetHomeStatisticsCubit>().getHomeStatistics(),
                context.read<GetSettingsCubit>().getSettings(),
              ]);
            },
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.width20(context),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: AppConstants.height20(context)),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Scaffold.of(context).openDrawer(),
                            child: Icon(
                              Icons.menu,
                              size: AppConstants.sp30(context),
                            ),
                          ),
                          SizedBox(width: AppConstants.width10(context)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "أهلا بك، مدير النظام",
                                  style: Styles.inter18500Black(context),
                                ),
                                Text(
                                  "نظرة سريعة على أداء متجرك",
                                  style: Styles.inter14500black(
                                    context,
                                  ).copyWith(color: AppColors.gray),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: AppConstants.width10(context)),
              
                          NotificationBellButton(
                            backgroundColor: Colors.white,
                          ),
                        ],
                      ),
                      SizedBox(height: AppConstants.height20(context)),
                      DashboardPeriodSelector(
                        selected: _period,
                        onChanged: (period) => setState(() => _period = period),
                      ),
                      SizedBox(height: AppConstants.height20(context)),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TotalSalesHeroCard(
                                period: _period,
                                recentStats: state.model.recentStats,
                                trends: state.model.trends,
                              ),
                            ),
                            SizedBox(width: AppConstants.width10(context)),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: DashboardStatCard(
                                      icon: Icons.shopping_bag_outlined,
                                      iconBackground: AppColors.primaryColor,
                                      title: "عدد الطلبات",
                                      value: "${overview?.totalOrders ?? 0}",
                                    ),
                                  ),
                                  SizedBox(height: AppConstants.height10(context)),
                                  Expanded(
                                    child: DashboardStatCard(
                                      icon: Icons.people_outline,
                                      iconBackground: Colors.green,
                                      title: "عدد العملاء",
                                      value: "${overview?.totalCustomers ?? 0}",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppConstants.height10(context)),
                      _UserManagementCard(),
                      SizedBox(height: AppConstants.height10(context)),
                      Row(
                        children: [
                          Expanded(
                            child: DashboardQuickStatCard(
                              icon: Icons.shopping_bag,
                              iconColor: AppColors.primaryColor,
                              title: "طلبات جديدة",
                              value: "$pendingCount",
                              onTap: () => context
                                  .read<ChangeNavBarStatusCubit>()
                                  .changeNavBarIndex(1),
                            ),
                          ),
                          SizedBox(width: AppConstants.width10(context)),
                          Expanded(
                            child: DashboardQuickStatCard(
                              icon: Icons.local_shipping_outlined,
                              iconColor: Colors.blue,
                              title: "قيد التوصيل",
                              value: "$inDeliveryCount",
                              onTap: () => context
                                  .read<ChangeNavBarStatusCubit>()
                                  .changeNavBarIndex(1),
                            ),
                          ),
                          SizedBox(width: AppConstants.width10(context)),
                          Expanded(
                            child: DashboardQuickStatCard(
                              icon: Icons.warning_amber_rounded,
                              iconColor: Colors.orange,
                              title: "مخزون منخفض",
                              value:
                                  "${state.lowStockProductsTotal ?? state.lowStockProducts.length}",
                              onTap: () => NavigationUtils.navigateTo(
                                context: context,
                                destinationScreen: const LowStockProductsView(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppConstants.height20(context)),
                      SalesPerformanceSection(
                        period: _period,
                        trends: state.model.trends,
                        overview: overview,
                      ),
                      SizedBox(height: AppConstants.height10(context)),
                      OrderStatusDonutSection(
                        ordersByStatus: ordersByStatus,
                        totalOrders: overview?.totalOrders ?? 0,
                      ),
                      SizedBox(height: AppConstants.height20(context)),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "أبرز الأداء",
                              style: Styles.inter16500black(context),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppConstants.height10(context)),
                      if (state.model.reviewStats != null) ...[
                        ReviewsSummaryStatistic(instance: state.model.reviewStats!),
                        SizedBox(height: AppConstants.height15(context)),
                      ],
                      if ((state.model.topCustomers ?? []).isNotEmpty) ...[
                        TopCustomerItem(
                          instance: state.model.topCustomers!.first,
                          fromHome: true,
                          index: 0,
                        ),
                        SizedBox(height: AppConstants.height15(context)),
                      ],
                      if ((state.model.productStats?.topSellingProducts ?? []).isNotEmpty)
                        MostOrderedItem(
                          instance: state.model.productStats!.topSellingProducts!.first,
                          fromHome: true,
                        ),
                      SizedBox(height: AppConstants.height20(context)),
                      InventoryAnalyticsSection(
                        items: state.inventoryAnalytics,
                        error: state.inventoryAnalyticsError,
                      ),
                      SizedBox(height: AppConstants.height20(context)),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                context.read<GetHomeStatisticsCubit>().getHomeStatistics(),
                context.read<GetSettingsCubit>().getSettings(),
              ]);
            },
            child:  SafeArea(child: const HomeViewBodyShimmer()),
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
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.width20(context),
          ),
          child: Column(
            children: [
              SizedBox(height: AppConstants.height20(context)),
              Row(
                children: [
                  _shimmerBox(
                    context,
                    width: AppConstants.sp30(context),
                    height: AppConstants.sp30(context),
                    radius: AppConstants.sp5(context),
                  ),
                  SizedBox(width: AppConstants.width10(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerBox(
                          context,
                          width: MediaQuery.of(context).size.width * .38,
                          height: AppConstants.height15(context),
                        ),
                        SizedBox(height: AppConstants.height10(context) / 2),
                        _shimmerBox(
                          context,
                          width: MediaQuery.of(context).size.width * .48,
                          height: AppConstants.height10(context),
                        ),
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
                      child: _shimmerBox(
                        context,
                        width: double.infinity,
                        height: AppConstants.height20(context) * 2,
                        radius: AppConstants.sp30(context),
                      ),
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
                      child: _shimmerBox(
                        context,
                        width: double.infinity,
                        height: double.infinity,
                        radius: AppConstants.sp15(context),
                      ),
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
              _shimmerBox(
                context,
                width: double.infinity,
                height: AppConstants.height20(context) * 3.2,
                radius: AppConstants.sp10(context),
              ),
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
              _shimmerBox(
                context,
                width: MediaQuery.of(context).size.width * .3,
                height: AppConstants.height15(context),
              ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),
      child: Column(
        children: [
          _shimmerBox(
            context,
            width: MediaQuery.of(context).size.width * .08,
            height: MediaQuery.of(context).size.width * .08,
            radius: AppConstants.sp10(context),
          ),
          SizedBox(height: AppConstants.height10(context)),
          _shimmerBox(
            context,
            width: MediaQuery.of(context).size.width * .16,
            height: AppConstants.height10(context),
          ),
          SizedBox(height: AppConstants.height5(context)),
          _shimmerBox(
            context,
            width: MediaQuery.of(context).size.width * .10,
            height: AppConstants.height10(context),
          ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(
            context,
            width: MediaQuery.of(context).size.width * .28,
            height: AppConstants.height15(context),
          ),
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
                      padding: EdgeInsets.only(
                        bottom: AppConstants.height10(context),
                      ),
                      child: Row(
                        children: [
                          _shimmerBox(context, width: 10, height: 10, radius: 5),
                          SizedBox(width: AppConstants.width10(context)),
                          Expanded(
                            child: _shimmerBox(
                              context,
                              width: double.infinity,
                              height: AppConstants.height10(context),
                            ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _shimmerBox(
                  context,
                  width: double.infinity,
                  height: AppConstants.height15(context),
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
              _shimmerBox(
                context,
                width: MediaQuery.of(context).size.width * .20,
                height: AppConstants.height30(context),
                radius: AppConstants.sp5(context),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height20(context)),
          _shimmerBox(
            context,
            width: MediaQuery.of(context).size.width * .35,
            height: AppConstants.height20(context),
          ),
          SizedBox(height: AppConstants.height20(context)),
          ...List.generate(
            5,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: AppConstants.height20(context)),
              child: Row(
                children: [
                  _shimmerBox(
                    context,
                    width: MediaQuery.of(context).size.width * .15,
                    height: AppConstants.height10(context),
                  ),
                  SizedBox(width: AppConstants.width10(context)),
                  Expanded(
                    child: _shimmerBox(
                      context,
                      width: double.infinity,
                      height: AppConstants.height10(context),
                      radius: AppConstants.sp30(context),
                    ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _shimmerBox(
                  context,
                  width: double.infinity,
                  height: AppConstants.height15(context),
                ),
              ),
              SizedBox(width: AppConstants.width20(context)),
              _shimmerBox(
                context,
                width: MediaQuery.of(context).size.width * .18,
                height: AppConstants.height30(context),
                radius: AppConstants.sp5(context),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height10(context) / 2),
          _shimmerBox(
            context,
            width: MediaQuery.of(context).size.width * .50,
            height: AppConstants.height10(context),
          ),
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
                    _shimmerBox(
                      context,
                      width: MediaQuery.of(context).size.width * .3,
                      height: AppConstants.height10(context),
                    ),
                    SizedBox(height: AppConstants.height10(context) / 2),
                    _shimmerBox(
                      context,
                      width: MediaQuery.of(context).size.width * .22,
                      height: AppConstants.height10(context),
                    ),
                    SizedBox(height: AppConstants.height10(context) / 2),
                    _shimmerBox(
                      context,
                      width: MediaQuery.of(context).size.width * .26,
                      height: AppConstants.height10(context),
                    ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _shimmerBox(
                  context,
                  width: double.infinity,
                  height: AppConstants.height15(context),
                ),
              ),
              SizedBox(width: AppConstants.width20(context)),
              _shimmerBox(
                context,
                width: MediaQuery.of(context).size.width * .18,
                height: AppConstants.height30(context),
                radius: AppConstants.sp5(context),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height10(context) / 2),
          _shimmerBox(
            context,
            width: MediaQuery.of(context).size.width * .48,
            height: AppConstants.height10(context),
          ),
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
                    _shimmerBox(
                      context,
                      width: MediaQuery.of(context).size.width * .26,
                      height: AppConstants.height10(context),
                    ),
                    SizedBox(height: AppConstants.height10(context) / 2),
                    _shimmerBox(
                      context,
                      width: MediaQuery.of(context).size.width * .30,
                      height: AppConstants.height10(context),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _shimmerBox(
                    context,
                    width: MediaQuery.of(context).size.width * .10,
                    height: AppConstants.height10(context),
                  ),
                  SizedBox(height: AppConstants.height10(context) / 2),
                  _shimmerBox(
                    context,
                    width: MediaQuery.of(context).size.width * .14,
                    height: AppConstants.height10(context),
                  ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(
                      context,
                      width: MediaQuery.of(context).size.width * .32,
                      height: AppConstants.height15(context),
                    ),
                    SizedBox(height: AppConstants.height10(context) / 2),
                    _shimmerBox(
                      context,
                      width: MediaQuery.of(context).size.width * .5,
                      height: AppConstants.height10(context),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
              _shimmerBox(
                context,
                width: MediaQuery.of(context).size.width * .18,
                height: AppConstants.height30(context),
                radius: AppConstants.sp5(context),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height20(context)),
          _shimmerBox(
            context,
            width: double.infinity,
            height: MediaQuery.of(context).size.height * .18,
          ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),
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
              _shimmerBox(
                context,
                width: MediaQuery.of(context).size.width * .18,
                height: AppConstants.height30(context),
                radius: AppConstants.sp5(context),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height20(context)),
          for (var i = 0; i < 2; i++) ...[
            Row(
              children: [
                _shimmerBox(context, width: AppConstants.width20(context) * 2, height: AppConstants.width20(context) * 2),
                SizedBox(width: AppConstants.width10(context)),
                Expanded(child: _shimmerBox(context, width: double.infinity, height: AppConstants.height15(context))),
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

class _UserManagementCard extends StatelessWidget {
  const _UserManagementCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => NavigationUtils.navigateTo(
        context: context,
        destinationScreen: const AllUsersView(),
      ),
      borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppConstants.sp15(context)),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.shade700,

          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppConstants.sp10(context)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.2),
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
              ),
              child: Icon(
                Icons.manage_accounts_outlined,
                color: Colors.white,
                size: AppConstants.sp30(context),
              ),
            ),
            SizedBox(width: AppConstants.width15(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "إدارة المستخدمين",
                    style: Styles.inter16500black(
                      context,
                    ).copyWith(color: Colors.white),
                  ),
                  SizedBox(height: AppConstants.height5(context)),
                  Text(
                    "عرض وتحليل وحذف المستخدمين",
                    style: Styles.inter12500Black(
                      context,
                    ).copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: AppConstants.sp15(context),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _shimmerBox(
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

Widget _shimmerCircle({required double size}) {
  return Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
  );
}
