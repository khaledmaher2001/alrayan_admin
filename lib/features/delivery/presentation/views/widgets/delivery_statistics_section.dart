import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/delivery/data/models/delivery_statistics_model.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_statistics/get_delivery_statistics_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_statistics/get_delivery_statistics_states.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/remittances_view.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// `GET /delivery/statistics` overview — shown on the delivery management
/// home screen so an admin can see the whole operation at a glance before
/// drilling into couriers/orders/remittances.
class DeliveryStatisticsSection extends StatelessWidget {
  const DeliveryStatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetDeliveryStatisticsCubit, GetDeliveryStatisticsStates>(
      builder: (context, state) {
        if (state is GetDeliveryStatisticsLoadingState ||
            state is GetDeliveryStatisticsInitState) {
          return const _StatisticsLoadingCard();
        }
        if (state is GetDeliveryStatisticsErrorState) {
          return _StatisticsErrorCard(message: state.errMessage);
        }
        final overview =
            (state as GetDeliveryStatisticsSuccessState).model.overview;
        if (overview == null) return const SizedBox.shrink();
        return _StatisticsContent(overview: overview);
      },
    );
  }
}

class _StatisticsLoadingCard extends StatelessWidget {
  const _StatisticsLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: AppConstants.height30(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
        border: Border.all(color: const Color(0xffE3E7EC)),
      ),
      child: CustomLoadingItem(
        size: MediaQuery.of(context).size.width * .08,
      ),
    );
  }
}

class _StatisticsErrorCard extends StatelessWidget {
  const _StatisticsErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.sp15(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
        border: Border.all(color: const Color(0xffE3E7EC)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.redColor,
            size: AppConstants.sp30(context),
          ),
          SizedBox(height: AppConstants.height10(context)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Styles.inter12500Black(
              context,
            ).copyWith(color: Colors.grey.shade600),
          ),
          SizedBox(height: AppConstants.height10(context)),
          TextButton(
            onPressed: () =>
                context.read<GetDeliveryStatisticsCubit>().getStatistics(),
            child: Text("retry".tr(), style: Styles.inter14600black(context)),
          ),
        ],
      ),
    );
  }
}

/// "الملخص المالي" — two separate cards, because the API separates them too:
/// "هذا الشهر" ([DeliveryStatisticsOverview.thisMonth], resets every month)
/// and "الإجمالي" (the `total*` overview fields, running since day one).
class _StatisticsContent extends StatelessWidget {
  const _StatisticsContent({required this.overview});

  final DeliveryStatisticsOverview overview;

  @override
  Widget build(BuildContext context) {
    final pending = overview.pendingRemittances;
    final thisMonth = overview.thisMonth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (thisMonth != null) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppConstants.sp15(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
              border: Border.all(color: const Color(0xffE3E7EC)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "delivery_stat_this_month".tr(),
                  style: Styles.inter14500black(context).copyWith(color: const Color(0xff9CA4AB)),
                ),
                SizedBox(height: AppConstants.height10(context)),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _MiniStat(
                          label: "delivery_stat_remitted".tr(),
                          value: _formatMoney(thisMonth.remitted),
                        ),
                      ),
                      VerticalDivider(width: 1, color: Colors.grey.shade200),
                      Expanded(
                        child: _MiniStat(
                          label: "delivery_stat_gross_collected".tr(),
                          value: _formatMoney(thisMonth.grossCollected),
                        ),
                      ),
                      VerticalDivider(width: 1, color: Colors.grey.shade200),
                      Expanded(
                        child: _MiniStat(
                          label: "delivery_stat_earnings".tr(),
                          value: _formatMoney(thisMonth.earnings),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppConstants.height15(context)),
        ],
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppConstants.sp15(context)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
            border: Border.all(color: const Color(0xffE3E7EC)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "الإجمالي",
                style: Styles.inter14500black(context).copyWith(color: const Color(0xff9CA4AB)),
              ),
              SizedBox(height: AppConstants.height10(context)),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _FinanceCell(
                        label: "delivery_stat_remitted".tr(),
                        value: _formatMoney(overview.totalRemitted),
                        icon: Icons.price_check_rounded,
                        emphasize: true,
                      ),
                    ),
                    SizedBox(width: AppConstants.width5(context)),
                    VerticalDivider(width: 1, color: Colors.grey.shade200),
                    SizedBox(width: AppConstants.width5(context)),
                    Expanded(
                      child: _FinanceCell(
                        label: "delivery_stat_gross_collected".tr(),
                        value: _formatMoney(overview.totalGrossCollected),
                        icon: Icons.payments_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: AppConstants.height20(context), color: Colors.grey.shade200),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _FinanceCell(
                        label: "delivery_stat_owed_to_store".tr(),
                        value: _formatMoney(overview.totalOwedToStore),
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                    ),
                    SizedBox(width: AppConstants.width5(context)),
                    VerticalDivider(width: 1, color: Colors.grey.shade200),
                    SizedBox(width: AppConstants.width5(context)),
                    Expanded(
                      child: _FinanceCell(
                        label: "delivery_stat_earnings".tr(),
                        value: _formatMoney(overview.totalEarnings),
                        icon: Icons.trending_up_rounded,
                        emphasize: true,
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
        if (pending != null) ...[
          SizedBox(height: AppConstants.height10(context)),
          _PendingRemittancesBanner(pending: pending),
        ],
      ],
    );
  }
}

/// Compact centered value+label pair used in the "هذا الشهر" strip — lighter
/// weight than [_FinanceCell] since it's the secondary card.
class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Styles.inter16500black(context),
        ),
        SizedBox(height: AppConstants.height5(context) / 2),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Styles.inter14500black(context).copyWith(color: const Color(0xff9CA4AB), fontSize: 11),
        ),
      ],
    );
  }
}

class _FinanceCell extends StatelessWidget {
  const _FinanceCell({
    required this.label,
    required this.value,
    required this.icon,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final IconData icon;

  /// Pink icon + red value for the two "headline" figures (remitted /
  /// platform earnings), matching the design; the other two stay neutral.
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final iconBg = emphasize ? AppColors.primaryColor.shade50 : const Color(0xffF5F6FA);
    final iconColor = emphasize ? AppColors.primaryColor : AppColors.secondaryColor;
    final valueColor = emphasize ? AppColors.primaryColor : const Color(0xff0F0F0E);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppConstants.height5(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppConstants.sp10(context)),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(AppConstants.sp10(context))),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(width: AppConstants.width5(context),),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.inter14500black(context).copyWith(color: const Color(0xff9CA4AB), fontSize: 12),
                ),
                SizedBox(height: AppConstants.height5(context) / 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.inter18500Black(context).copyWith(color: valueColor),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

class _PendingRemittancesBanner extends StatelessWidget {
  const _PendingRemittancesBanner({required this.pending});

  final PendingRemittances pending;

  @override
  Widget build(BuildContext context) {
    final hasPending = (pending.count ?? 0) > 0;
    final color = hasPending ? Colors.orange : Colors.green;

    return GestureDetector(
      onTap: () => NavigationUtils.navigateTo(
        context: context,
        destinationScreen: const RemittancesView(),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppConstants.sp10(context)),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          border: Border.all(color: color.shade200),
        ),
        child: Row(
          children: [
            Icon(
              hasPending ? Icons.notifications_active_rounded : Icons.check_circle_rounded,
              color: color.shade700,
              size: AppConstants.sp20(context),
            ),
            SizedBox(width: AppConstants.width10(context)),
            Expanded(
              child: Text(
                hasPending
                    ? "delivery_stat_pending_remittances".tr(
                        namedArgs: {
                          'count': "${pending.count}",
                          'amount': _formatMoney(pending.amount),
                        },
                      )
                    : "لا توجد طلبات تسليم فلوس بانتظار المراجعة حاليًا",
                style: Styles.inter12500Black(
                  context,
                ).copyWith(color: color.shade900),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: color.shade700,
              size: AppConstants.sp20(context),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatMoney(num? value) {
  if (value == null) return '0';
  final v = value.toDouble();
  final formatted = v == v.roundToDouble()
      ? v.toInt().toString()
      : v.toStringAsFixed(1);
  return "$formatted ج.م";
}
