import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/orders/presentation/utils/order_status_ui.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_orders/get_orders_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/order_status_filter/order_status_filter_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bottom sheet with the full status list — a second, more discoverable
/// entry point into the same filter the status cards row already offers.
Future<void> showOrderStatusFilterSheet(BuildContext context) {
  final filterCubit = context.read<OrderStatusFilterCubit>();
  final ordersCubit = context.read<GetOrdersCubit>();

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.sp20(context))),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppConstants.height20(sheetContext)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("s_sort_by_status".tr(), style: Styles.inter18500Black(sheetContext)),
              SizedBox(height: AppConstants.height15(sheetContext)),
              ...List.generate(filterCubit.status.length, (index) {
                final status = filterCubit.status[index];
                final isAll = status == null;
                final selected = filterCubit.selectedFilterIndex == index;
                return ListTile(
                  onTap: () {
                    if (filterCubit.selectedFilterIndex != index) {
                      filterCubit.selectIndex(index: index);
                      ordersCubit.getOrders(status: status);
                    }
                    Navigator.of(sheetContext).pop();
                  },
                  leading: Icon(
                    OrderStatusUi.icon(status),
                    color: selected ? AppColors.primaryColor : AppConstants.getTextColor(status),
                  ),
                  title: Text(
                    isAll ? "s_all".tr() : AppConstants.getStatusText(status),
                    style: Styles.inter16500black(sheetContext).copyWith(
                      color: selected ? AppColors.primaryColor : Colors.black,
                    ),
                  ),
                  trailing: selected ? Icon(Icons.check_circle_rounded, color: AppColors.primaryColor) : null,
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}
