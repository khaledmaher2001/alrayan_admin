import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:alrayan_admin/features/orders/presentation/utils/order_status_ui.dart';
import 'package:alrayan_admin/features/orders/presentation/view/order_details_view.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_orders/get_orders_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/order_status_filter/order_status_filter_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:alrayan_admin/core/design/ds.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersItem extends StatelessWidget {
  final Items orderData;

  const OrdersItem({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final isNew = context.select<GetOrdersCubit, bool>(
      (cubit) => orderData.id != null && cubit.newOrderIds.contains(orderData.id),
    );

    // Compact card: status + time, customer + order number, items/courier + total.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DsSpace.page),
      child: DsCard(
      highlight: isNew ? AppColors.primaryColor : null,
      padding: const EdgeInsets.all(DsSpace.md),
      onTap: () {
        final cubit = context.read<GetOrdersCubit>();
        final filterCubit = context.read<OrderStatusFilterCubit>();
        final currentFilter = filterCubit.status[filterCubit.selectedFilterIndex];
        if (orderData.id != null) cubit.markOrderSeen(orderData.id!);
        NavigationUtils.navigateTo(
          context: context,
          destinationScreen: OrderDetailsView(
            orderData: orderData,
            onStatusChanged: (id, newStatus) {
              cubit.updateOrderStatusLocally(id, newStatus, currentFilter: currentFilter);
            },
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DsStatusBadge(
                status: orderData.status,
                label: AppConstants.getStatusText(orderData.status ?? ''),
                icon: OrderStatusUi.icon(orderData.status),
              ),
              if (isNew) ...[
                const SizedBox(width: DsSpace.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(DsRadius.pill)),
                  child: Text("s_new".tr(), style: DsText.label.copyWith(color: Colors.white, fontSize: 11)),
                ),
              ],
              const Spacer(),
              Text(DsFormat.dateTime(context, orderData.createdAt), style: DsText.caption),
            ],
          ),
          const SizedBox(height: DsSpace.md),
          Text(
            orderData.shippingAddress?.user?.fullName ?? "ord_customer".tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DsText.subheading,
          ),
          const SizedBox(height: 2),
          Text(DsFormat.orderNo(orderData.orderNumber), style: DsText.caption),
          const SizedBox(height: DsSpace.md),
          Row(
            children: [
              const Icon(Icons.shopping_basket_outlined, size: 16, color: DsColor.textMuted),
              const SizedBox(width: 4),
              Text("ord_items".tr(namedArgs: {"n": "${orderData.orderItems?.length ?? 0}"}), style: DsText.caption),
              if (orderData.deliveryUser?.fullName != null) ...[
                const SizedBox(width: DsSpace.md),
                const Icon(Icons.delivery_dining_outlined, size: 16, color: DsColor.textMuted),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(orderData.deliveryUser!.fullName!, maxLines: 1, overflow: TextOverflow.ellipsis, style: DsText.caption),
                ),
              ],
              const Spacer(),
              Text(
                DsFormat.money(num.tryParse('${orderData.totalAmount}')),
                style: DsText.bodyStrong.copyWith(color: AppColors.primaryColor, fontSize: 16),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.chevron_right_rounded, color: DsColor.textSubtle, size: 20),
            ],
          ),
        ],
      ),
    ),
    );
  }
}
