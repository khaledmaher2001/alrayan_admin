import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:alrayan_admin/features/orders/presentation/view/order_details_view.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/row_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OrdersItem extends StatelessWidget {
  final Items orderData;

  const OrdersItem({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        NavigationUtils.navigateTo(
          context: context,
          destinationScreen: OrderDetailsView(orderData: orderData),
        );
      },
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppConstants.width10(context),
          vertical: AppConstants.height10(context),
        ),
        margin: EdgeInsetsDirectional.symmetric(
          horizontal: AppConstants.width15(context),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          color: Colors.white,
          border: Border.all(color: Color(0xffE3E7EC)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat("yyyy-MM-dd  hh:mm a").format(DateTime.parse(orderData.createdAt ?? "")),
                          style: Styles.inter14500black(context).copyWith(color: Color(0xff9CA4AB)),
                        ),
                      ),
                      SizedBox(width: AppConstants.width10(context)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.width15(context),
                          vertical: AppConstants.height5(context) / 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.getStatusColor(orderData.status ?? ''),
                          borderRadius: BorderRadius.circular(AppConstants.sp30(context) * 3),
                        ),
                        child: Text(
                          AppConstants.getStatusText(orderData.status ?? ''),
                          style: Styles.inter14500black(
                            context,
                          ).copyWith(color: AppConstants.getTextColor(orderData.status ?? '')),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppConstants.height5(context)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "رقم الطلب : ",
                        style: Styles.inter14500black(
                          context,
                        ).copyWith(color: Colors.black, fontWeight: FontWeight.w600),
                      ),
                      Expanded(
                        child: Text(
                          orderData.orderNumber!,
                          style: Styles.inter14500black(
                            context,
                          ).copyWith(color: Colors.black, fontWeight: FontWeight.w300),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppConstants.height10(context)),
                  RowItem(
                    value: "${orderData.totalAmount} جنية",
                    title: "التكلفة الكلية",
                    valueColor: AppColors.primaryColor,
                    titleColor: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
