import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/home/data/models/home_statistics_model.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_home_statistics/get_home_statistics_cubit.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_home_statistics/get_home_statistics_states.dart';
import 'package:alrayan_admin/features/orders/presentation/utils/order_status_ui.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_orders/get_orders_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/order_status_filter/order_status_filter_cubit.dart';
import 'package:flutter/material.dart';
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
      height: MediaQuery.of(context).size.height * .105,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(vertical: 1),
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
                label: isAll ? "الكل" : AppConstants.getStatusText(status),
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
    final bg = selected ? AppColors.secondaryColor : Colors.white;
    final fg = selected ? Colors.white : const Color(0xff0F0F0E);
    final iconColor = selected ? Colors.white : AppConstants.getTextColor(status);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: BoxConstraints(minWidth: AppConstants.width50(context) * 1.5),
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.width15(context),
              vertical: AppConstants.height10(context),
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
              border: Border.all(color: selected ? bg : const Color(0xffE3E7EC)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: Styles.inter14500black(context).copyWith(color: fg, fontWeight: FontWeight.w600),
                    ),
                    if (!isAll) ...[
                      SizedBox(width: AppConstants.width5(context)),
                      Icon(OrderStatusUi.icon(status), size: 16, color: iconColor),
                    ],
                  ],
                ),
                SizedBox(height: AppConstants.height5(context)),
                Text(
                  "$count",
                  style: Styles.inter18500Black(context).copyWith(color: fg),
                ),
              ],
            ),
          ),
          if (showDot)
            PositionedDirectional(
              top: -4,
              end: -4,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
