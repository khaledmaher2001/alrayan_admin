import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/all_users/data/models/customer_lifetime_value_model.dart';
import 'package:alrayan_admin/features/all_users/data/repo/all_users_repo_impl.dart';
import 'package:alrayan_admin/features/all_users/presentation/view_models/get_customer_lifetime_value/get_customer_lifetime_value_cubit.dart';
import 'package:alrayan_admin/features/all_users/presentation/view_models/get_customer_lifetime_value/get_customer_lifetime_value_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/services/remote_services/service_locator.dart';

class CustomerAnalysisBottomSheet extends StatelessWidget {
  const CustomerAnalysisBottomSheet({
    super.key,
    required this.userId,
    required this.userName,
  });

  final int userId;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetCustomerLifetimeValueCubit(getIt.get<AllUsersRepoImpl>())
        ..getCustomerLifetimeValue(userId),
      child: _AnalysisSheetBody(userName: userName),
    );
  }
}

class _AnalysisSheetBody extends StatelessWidget {
  const _AnalysisSheetBody({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          SizedBox(height: AppConstants.height15(context)),
          Center(
            child: Container(
              height: AppConstants.height5(context),
              width: MediaQuery.of(context).size.width * 0.15,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                color: DsColor.border,
              ),
            ),
          ),
          SizedBox(height: AppConstants.height15(context)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppConstants.sp10(context)),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                  ),
                  child: Icon(Icons.bar_chart_rounded,
                      color: Colors.white, size: AppConstants.sp20(context)),
                ),
                SizedBox(width: AppConstants.width10(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("s_customer_analysis".tr(), style: Styles.inter16500black(context)),
                      Text(
                        userName,
                        style: Styles.inter10400grey(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Divider(color: DsColor.fill),
          Expanded(
            child: BlocBuilder<GetCustomerLifetimeValueCubit, GetCustomerLifetimeValueState>(
              builder: (context, state) {
                if (state is GetCustomerLifetimeValueLoading ||
                    state is GetCustomerLifetimeValueInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is GetCustomerLifetimeValueError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            color: DsColor.danger, size: 40),
                        SizedBox(height: AppConstants.height10(context)),
                        Text(state.message,
                            style: Styles.inter12500Black(context)),
                      ],
                    ),
                  );
                }
                if (state is GetCustomerLifetimeValueSuccess) {
                  return _AnalysisContent(data: state.data);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisContent extends StatelessWidget {
  const _AnalysisContent({required this.data});

  final CustomerLifetimeValueModel data;

  @override
  Widget build(BuildContext context) {
    final hasOrders = (data.totalOrders ?? 0) > 0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.sp20(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero card: total spend
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppConstants.sp15(context)),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
            ),
            child: Row(
              children: [

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "s_total_spent".tr(),
                        style: Styles.inter10400grey(
                          context,
                        ).copyWith(color: Colors.white70),
                      ),
                      SizedBox(height: AppConstants.height5(context) / 2),
                      Text(
                        "${_fmtMoney(data.totalSpent)} ${"s_egp".tr()}",
                        style: Styles.inter18500Black(
                          context,
                        ).copyWith(color: Colors.white),
                      ),
                      SizedBox(height: AppConstants.height5(context) / 2),
                      Text(
                        "i_through_x_5".tr(namedArgs: {"a": "${_ordersPhrase(data.totalOrders)}"}),
                        style: Styles.inter10400grey(
                          context,
                        ).copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppConstants.width10(context)),
                Container(
                  padding: EdgeInsets.all(AppConstants.sp10(context)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.sp10(context),
                    ),
                  ),
                  child: Icon(
                    Icons.payments_outlined,
                    color: DsColor.success,
                    size: AppConstants.sp20(context),
                  ),
                ),

              ],
            ),
          ),
          SizedBox(height: AppConstants.height10(context)),
          Row(
            children: [
              Expanded(
                child: _BigStatCard(
                  label: "s_total_orders".tr(),
                  value: _fmt(data.totalOrders),
                  icon: Icons.shopping_bag_outlined,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
              Expanded(
                child: _BigStatCard(
                  label: "s_average_order".tr(),
                  value: "${_fmtMoney(data.averageOrderValue)} ${"s_egp".tr()}",
                  icon: Icons.trending_up_rounded,
                  color: DsColor.info,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height10(context)),
          Row(
            children: [
              Expanded(
                child: _BigStatCard(
                  label: "s_coupons_used".tr(),
                  value: _fmt(data.totalUsedCoupons),
                  icon: Icons.discount_outlined,
                  color: DsColor.warning,
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
              Expanded(
                child: _BigStatCard(
                  label: "s_cancelled_orders".tr(),
                  value: _fmt(data.totalCanceldOrders),
                  icon: Icons.cancel_outlined,
                  color: DsColor.danger,
                ),
              ),
            ],
          ),
          if (hasOrders) ...[
            SizedBox(height: AppConstants.height20(context)),
            Text("s_order_history".tr(), style: Styles.inter14500black(context)),
            SizedBox(height: AppConstants.height10(context)),
            Container(
              padding: EdgeInsets.all(AppConstants.sp15(context)),
              decoration: BoxDecoration(
                color: DsColor.page,
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                border: Border.all(color: DsColor.border),
              ),
              child: _OrdersTimeline(
                firstOrderDate: _formatDate(data.firstOrderDate),
                lastOrderDate: _formatDate(data.lastOrderDate),
              ),
            ),
          ],
          if (!hasOrders) ...[
            SizedBox(height: AppConstants.height20(context)),
            Center(
              child: Column(
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      color: DsColor.border, size: 48),
                  SizedBox(height: AppConstants.height10(context)),
                  Text("s_no_orders_for_this_customer".tr(),
                      style: Styles.inter12500Black(context)
                          .copyWith(color: DsColor.textMuted)),
                ],
              ),
            ),
          ],
          SizedBox(height: AppConstants.height20(context)),
          // Summary note
          Container(
            padding: EdgeInsets.all(AppConstants.sp15(context)),
            decoration: BoxDecoration(
              color: DsColor.infoBg,
              borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    color: DsColor.info, size: AppConstants.sp20(context)),
                SizedBox(width: AppConstants.width10(context)),
                Expanded(
                  child: Text(
                    hasOrders
                        ? "i_this_customer_placed_x_totalling_e_7".tr(namedArgs: {"a": "${_ordersPhrase(data.totalOrders)}", "b": "${_fmtMoney(data.totalSpent)}"})
                        : "s_this_customer_hasn_t_placed_any_orde".tr(),
                    style: Styles.inter12500Black(context)
                        .copyWith(color: DsColor.info),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppConstants.height20(context)),
        ],
      ),
    );
  }

  String _ordersPhrase(num? v) {
    final count = v?.toInt() ?? 0;
    if (count == 1) return "s_one_order".tr();
    if (count == 2) return "s_two_orders".tr();
    return "i_x_orders_8".tr(namedArgs: {"a": "${count}"});
  }

  String _fmt(num? v) => v == null ? '0' : v.toInt().toString();

  String _fmtMoney(num? v) {
    if (v == null) return '0';
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  String _formatDate(String? raw) {
    if (raw == null) return '—';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return "${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return raw;
    }
  }
}

class _BigStatCard extends StatelessWidget {
  const _BigStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp15(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppConstants.sp10(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
              border: Border.all(color: color.withValues(alpha: 0.2))
            ),
            child: Icon(icon, color: color, size: AppConstants.sp20(context)),
          ),
          SizedBox(width: AppConstants.width10(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Styles.inter10400grey(context)),
                SizedBox(height: AppConstants.height5(context)),
                Text(
                  value,
                  style: Styles.inter14500black(context).copyWith(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersTimeline extends StatelessWidget {
  const _OrdersTimeline({
    required this.firstOrderDate,
    required this.lastOrderDate,
  });

  final String firstOrderDate;
  final String lastOrderDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TimelineRow(
          label: "s_first_order".tr(),
          value: firstOrderDate,
          isLast: false,
        ),
        _TimelineRow(
          label: "s_last_order".tr(),
          value: lastOrderDate,
          isLast: true,
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.label,
    required this.value,
    required this.isLast,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: AppConstants.sp10(context),
                height: AppConstants.sp10(context),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryColor,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    margin: EdgeInsets.symmetric(
                      vertical: AppConstants.height5(context) / 2,
                    ),
                    color: DsColor.border,
                  ),
                ),
            ],
          ),
          SizedBox(width: AppConstants.width10(context)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppConstants.height15(context),
              ),
              child: Row(
                children: [
                  Text(label, style: Styles.inter12500Black(context)),
                  const Spacer(),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: AppConstants.sp15(context),
                    color: AppColors.gray,
                  ),
                  SizedBox(width: AppConstants.width5(context)),
                  Text(
                    value,
                    style: Styles.inter10400grey(context),
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
