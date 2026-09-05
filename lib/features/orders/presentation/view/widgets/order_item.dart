import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:alrayan_admin/features/orders/presentation/utils/order_status_ui.dart';
import 'package:alrayan_admin/features/orders/presentation/view/order_details_view.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_orders/get_orders_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/order_status_filter/order_status_filter_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersItem extends StatelessWidget {
  final Items orderData;

  const OrdersItem({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final isNew = context.select<GetOrdersCubit, bool>(
      (cubit) => orderData.id != null && cubit.newOrderIds.contains(orderData.id),
    );
    final statusColor = AppConstants.getStatusColor(orderData.status ?? '');
    final statusTextColor = AppConstants.getTextColor(orderData.status ?? '');

    return GestureDetector(
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
      child: Container(
        margin: EdgeInsetsDirectional.symmetric(horizontal: AppConstants.width15(context)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
          color: isNew ? AppColors.primaryColor.shade50 : Colors.white,
          border: Border.all(
            color: isNew ? AppColors.primaryColor : const Color(0xffE3E7EC),
            width: isNew ? 1.3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status accent bar — sits at the card's leading (physical
              // right in RTL) edge.
              Container(width: 4, color: statusTextColor),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: AppConstants.width15(context),
                    vertical: AppConstants.height15(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isNew) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppConstants.width10(context),
                                vertical: AppConstants.height5(context) / 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(AppConstants.sp30(context) * 3),
                              ),
                              child: Text(
                                "جديد",
                                style: Styles.inter14500black(
                                  context,
                                ).copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                              ),
                            ),
                            SizedBox(width: AppConstants.width10(context)),
                          ],
                          Expanded(
                            child: Text(
                              DateFormat("yyyy-MM-dd  hh:mm a").format(DateTime.parse(orderData.createdAt ?? "").toLocal()),
                              style: Styles.inter14500black(context).copyWith(color: const Color(0xff9CA4AB)),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppConstants.width10(context),
                              vertical: AppConstants.height5(context) / 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(AppConstants.sp30(context) * 3),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppConstants.getStatusText(orderData.status ?? ''),
                                  style: Styles.inter14500black(context).copyWith(color: statusTextColor),
                                ),
                                SizedBox(width: AppConstants.width5(context)),
                                Icon(OrderStatusUi.icon(orderData.status), size: 14, color: statusTextColor),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppConstants.height15(context)),
                      Text(
                        "رقم الطلب",
                        style: Styles.inter14500black(context).copyWith(color: const Color(0xff9CA4AB)),
                      ),
                      SizedBox(height: AppConstants.height5(context) / 2),
                      Text(
                        orderData.orderNumber ?? '',
                        style: Styles.inter16500black(
                          context,
                        ).copyWith(color: Colors.black, letterSpacing: 0.6),
                      ),
                      SizedBox(height: AppConstants.height15(context)),
                      Divider(height: 1, color: Colors.grey.shade200),
                      SizedBox(height: AppConstants.height10(context)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(AppConstants.sp5(context)),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.shade50,
                                  borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                                ),
                                child: Icon(
                                  Icons.receipt_long_rounded,
                                  size: 16,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              SizedBox(width: AppConstants.width10(context)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "الإجمالي",
                                    style: Styles.inter14500black(context).copyWith(color: const Color(0xff9CA4AB), fontSize: 11),
                                  ),
                                  Text(
                                    "${orderData.totalAmount} ج.م",
                                    style: Styles.inter16500black(context).copyWith(color: AppColors.primaryColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "عرض التفاصيل",
                                style: Styles.inter14500black(context).copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                              ),
                              Icon(Icons.chevron_right_rounded, color: AppColors.primaryColor, size: 20),
                            ],
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
      ),
    );
  }
}
