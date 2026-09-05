import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/delivery/data/repo/delivery_repo_impl.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_statistics/get_delivery_statistics_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_statistics/get_delivery_statistics_states.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/delivery_accounts_view.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/release_logs_view.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/remittances_view.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/delivery_statistics_section.dart';
import 'package:alrayan_admin/features/orders/presentation/view/awaiting_customer_orders_view.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Hub screen for "الدليفري" — reached from the Profile menu: a status
/// banner, the financial summary, and a card per sub-section (couriers,
/// orders, release logs, remittances).
class DeliveryManagementView extends StatelessWidget {
  const DeliveryManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetDeliveryStatisticsCubit(getIt<DeliveryRepoImpl>())
            ..getStatistics(),
      child: const _DeliveryManagementBody(),
    );
  }
}

class _DeliveryManagementBody extends StatelessWidget {
  const _DeliveryManagementBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F8),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: AppConstants.height10(context)),
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: AppConstants.width15(context),
              ),
              child: _buildHeader(context),
            ),
            SizedBox(height: AppConstants.height20(context)),
            Expanded(
              child: ListView(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: AppConstants.width15(context),
                ),
                children: [
                  const _DeliveryStatusCard(),
                  SizedBox(height: AppConstants.height20(context)),
                  Text("الملخص المالي", style: Styles.inter18500Black(context)),
                  SizedBox(height: AppConstants.height10(context)),
                  const DeliveryStatisticsSection(),
                  SizedBox(height: AppConstants.height20(context)),
                  Text("إدارة التوصيل", style: Styles.inter18500Black(context)),
                  SizedBox(height: AppConstants.height10(context)),
                  _DeliveryMenuCard(
                    icon: Icons.two_wheeler_rounded,
                    title: "delivery_couriers".tr(),
                    subtitle: "delivery_couriers_subtitle".tr(),
                    onTap: () => NavigationUtils.navigateTo(
                      context: context,
                      destinationScreen: const DeliveryAccountsView(),
                    ),
                  ),
                  SizedBox(height: AppConstants.height15(context)),
                  _DeliveryMenuCard(
                    icon: Icons.person_pin_circle_rounded,
                    title: "awaiting_customer_orders".tr(),
                    subtitle: "awaiting_customer_orders_subtitle".tr(),
                    onTap: () => NavigationUtils.navigateTo(
                      context: context,
                      destinationScreen: const AwaitingCustomerOrdersView(),
                    ),
                  ),
                  SizedBox(height: AppConstants.height15(context)),
                  _DeliveryMenuCard(
                    icon: Icons.fact_check_rounded,
                    title: "delivery_release_logs".tr(),
                    subtitle: "delivery_release_logs_subtitle".tr(),
                    onTap: () => NavigationUtils.navigateTo(
                      context: context,
                      destinationScreen: const ReleaseLogsView(),
                    ),
                  ),
                  SizedBox(height: AppConstants.height15(context)),
                  _DeliveryMenuCard(
                    icon: Icons.account_balance_wallet_rounded,
                    title: "delivery_remittances".tr(),
                    subtitle: "delivery_remittances_subtitle".tr(),
                    onTap: () => NavigationUtils.navigateTo(
                      context: context,
                      destinationScreen: const RemittancesView(),
                    ),
                  ),
                  SizedBox(height: AppConstants.height20(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "delivery_management".tr(),
                    textAlign: TextAlign.center,
                    style: Styles.inter18500Black(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.height5(context) / 2),
            Text(
              "متابعة فريق التوصيل والطلبات",
              style: Styles.inter14500black(
                context,
              ).copyWith(color: const Color(0xff9CA4AB)),
            ),
          ],
        ),
        PositionedDirectional(
          start: 0,
          child: InkWell(
            onTap: () => NavigationUtils.navigateBack(context: context),
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: AppConstants.width20(context) * 2.2,
              height: AppConstants.width20(context) * 2.2,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gray.withValues(alpha: .15),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}

/// Dark "حالة التوصيل اليوم" banner — delivered-orders-today + active
/// couriers at a glance.
class _DeliveryStatusCard extends StatelessWidget {
  const _DeliveryStatusCard();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GetDeliveryStatisticsCubit>().state;
    final overview = state is GetDeliveryStatisticsSuccessState
        ? state.model.overview
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.secondaryColor,
            padding: EdgeInsets.all(AppConstants.sp15(context)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(AppConstants.sp15(context)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.sp15(context),
                    ),
                  ),
                  child: Icon(
                    Icons.two_wheeler_rounded,
                    color: AppColors.secondaryColor,
                    size: 32,
                  ),
                ),
                SizedBox(width: AppConstants.width10(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "حالة التوصيل اليوم",
                        style: Styles.inter16500black(
                          context,
                        ).copyWith(color: Colors.white),
                      ),
                      SizedBox(height: AppConstants.height15(context)),
                      Row(
                        children: [
                          Expanded(
                            child: _StatusMetric(
                              value:
                                  "${overview?.activeCouriers ?? 0} من ${overview?.totalCouriers ?? 0}",
                              label: "مندوبون نشطون",
                              showDot: true,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            color: Colors.white.withValues(alpha: .2),
                          ),
                          Expanded(
                            child: _StatusMetric(
                              value: "${overview?.totalDeliveredOrders ?? 0}",
                              label: "طلبات مسلَّمة",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 4, color: AppColors.primaryColor),
        ],
      ),
    );
  }
}

class _StatusMetric extends StatelessWidget {
  const _StatusMetric({
    required this.value,
    required this.label,
    this.showDot = false,
  });

  final String value;
  final String label;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDot) ...[
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xff34D399),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: AppConstants.width5(context)),
            ],
            Text(
              value,
              style: Styles.inter24600black(
                context,
              ).copyWith(color: Colors.white),
            ),
          ],
        ),
        SizedBox(height: AppConstants.height5(context) / 2),
        Text(
          label,
          style: Styles.inter14500black(
            context,
          ).copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

class _DeliveryMenuCard extends StatelessWidget {
  const _DeliveryMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppConstants.sp15(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
          border: Border.all(color: const Color(0xffE3E7EC)),
        ),
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * .14,
              height: MediaQuery.of(context).size.width * .14,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: AppConstants.sp20(context),
              ),
            ),
            SizedBox(width: AppConstants.width10(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Styles.inter16500black(context)),
                  SizedBox(height: AppConstants.height5(context) / 2),
                  Text(
                    subtitle,
                    style: Styles.inter12500Black(
                      context,
                    ).copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppConstants.width10(context)),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: AppConstants.sp30(context),
            ),
          ],
        ),
      ),
    );
  }
}
