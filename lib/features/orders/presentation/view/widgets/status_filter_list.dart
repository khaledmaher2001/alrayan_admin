import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/features/home/data/models/home_statistics_model.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_home_statistics/get_home_statistics_cubit.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_home_statistics/get_home_statistics_states.dart';
import 'package:alrayan_admin/features/orders/presentation/utils/order_status_ui.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_orders/get_orders_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/order_status_filter/order_status_filter_cubit.dart';
import 'package:flutter/material.dart';
import 'package:alrayan_admin/core/design/ds.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

int? _baseCountForStatus(HomeStatisticsModel? model, String? status) {
  if (model == null) return null;
  if (status == null) return model.overview?.totalOrders;
  final byStatus = model.orderStats?.ordersByStatus;
  if (byStatus == null) return null;
  for (final entry in byStatus) {
    if (entry.status == status) return entry.count;
  }
  return 0;
}

class StatusFilterList extends StatelessWidget {
  const StatusFilterList({super.key});

  @override
  Widget build(BuildContext context) {
    final filterCubit = context.watch<OrderStatusFilterCubit>();
    final ordersCubit = context.watch<GetOrdersCubit>();
    final homeStats = context.watch<GetHomeStatisticsCubit>();

    final HomeStatisticsModel? statsModel = homeStats.state is GetHomeStatisticsSuccessState
        ? (homeStats.state as GetHomeStatisticsSuccessState).model
        : homeStats.ordersModel;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemBuilder: (context, index) {
          final status = filterCubit.status[index];
          final isAll = status == null;
          final selected = filterCubit.selectedFilterIndex == index;
          final base = _baseCountForStatus(statsModel, status) ?? 0;
          final count = base + ordersCubit.deltaFor(status);

          return Row(
            children: [
              if (index == 0) SizedBox(width: AppConstants.width15(context)),
              _StatusFilterCard(
                label: isAll ? "s_all".tr() : AppConstants.getStatusText(status),
                status: status,
                isAll: isAll,
                selected: selected,
                count: count,
                showDot: isAll && ordersCubit.hasUnseenNewOrders,
                onTap: () {
                  if (filterCubit.selectedFilterIndex != index) {
                    filterCubit.selectIndex(index: index);
                    ordersCubit.getOrders(status: status);
                  }
                },
              ),
              if (index == filterCubit.status.length - 1)
                SizedBox(width: AppConstants.width15(context)),
            ],
          );
        },
        separatorBuilder: (context, index) => SizedBox(width: AppConstants.width10(context)),
        itemCount: filterCubit.status.length,
      ),
    );
  }
}

/// Filter chip: label + live count, status icon; the selected one is filled
/// with the brand colour. 40dp tall inside a 48dp row.
class _StatusFilterCard extends StatelessWidget {
  const _StatusFilterCard({
    required this.label,
    required this.status,
    required this.isAll,
    required this.selected,
    required this.count,
    required this.showDot,
    required this.onTap,
  });

  final String label;
  final String? status;
  final bool isAll;
  final bool selected;
  final int count;
  final bool showDot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : DsColor.text;
    final iconColor = selected ? Colors.white : AppConstants.getTextColor(status);
    return Semantics(
      button: true,
      selected: selected,
      label: '$label $count',
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.primaryColor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DsRadius.pill),
          side: BorderSide(color: selected ? AppColors.primaryColor : DsColor.border),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: DsSpace.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isAll) ...[
                  Icon(OrderStatusUi.icon(status), size: 16, color: iconColor),
                  const SizedBox(width: 6),
                ],
                Text(label, style: DsText.body.copyWith(color: fg, fontWeight: FontWeight.w600)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white.withValues(alpha: .22) : DsColor.page,
                    borderRadius: BorderRadius.circular(DsRadius.pill),
                  ),
                  child: Text(DsFormat.count(count), style: DsText.label.copyWith(color: fg)),
                ),
                if (showDot) ...[
                  const SizedBox(width: 6),
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: DsColor.danger, shape: BoxShape.circle)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
