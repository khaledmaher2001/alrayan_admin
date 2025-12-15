import 'package:alrayan_admin/core/utils/services/local_services/cache_keys.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/shared_widgets/custom_loading_item.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/services/remote_services/service_locator.dart';
import '../../../../../core/utils/text_styles/styles.dart';
import '../../../../orders/data/repo/orders_repo_impl.dart';
import '../../../../orders/presentation/view/widgets/order_details_item.dart';
import '../../../../orders/presentation/view/widgets/payment_amount_item.dart';
import '../../../../orders/presentation/view/widgets/row_item.dart';
import '../../../../orders/presentation/view_model/change_order_status/change_order_status_cubit.dart';
import '../../../../orders/presentation/view_model/get_order_details/get_order_details_cubit.dart';
import 'custom_bottom_sheet_header.dart';

class OrderBottomSheet extends StatelessWidget {
  const OrderBottomSheet({super.key, required this.orderId, this.isOrder = true});

  final int orderId;
  final bool isOrder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                GetOrderDetailsCubit(getIt<OrdersRepoImpl>())..getOrderDetails(orderId: orderId, withLoading: true),
          ),
          BlocProvider(create: (context) => ChangeOrderStatusCubit(getIt<OrdersRepoImpl>())),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppConstants.height10(context)),
            const CustomBottomSheetHeader(),
            SizedBox(height: AppConstants.height20(context)),
            Expanded(
              child: BlocBuilder<GetOrderDetailsCubit, GetOrderDetailsState>(
                builder: (context, detailsState) {
                  if (detailsState is GetOrderDetailsSuccessState) {
                    String status = detailsState.orderDetailsModel.status!;
                    return ListView(
                      children: [
                        Text("رقم الطلب".tr(), style: Styles.font16600Grey900(context)),
                        SizedBox(height: AppConstants.height5(context)),
                        Text(detailsState.orderDetailsModel.orderNumber ?? "", style: Styles.font16500Grey600(context)),
                        SizedBox(height: AppConstants.height10(context)),
                        Text("التوصيل الي".tr(), style: Styles.font16600Grey900(context)),
                        SizedBox(height: AppConstants.height5(context)),
                        Text(
                          detailsState.orderDetailsModel.shippingAddress!.description ?? "",
                          style: Styles.font16500Grey600(context),
                        ),
                        SizedBox(height: AppConstants.height10(context)),
                        Text("طريقة الدفع".tr(), style: Styles.font16600Grey900(context)),
                        SizedBox(height: AppConstants.height5(context)),
                        Text("كاش عند التوصيل".tr(), style: Styles.font16500Grey600(context)),
                        SizedBox(height: AppConstants.height10(context)),
                        Divider(color: AppColors.greyColor[100]),
                        SizedBox(height: AppConstants.height10(context)),
                        Text("تفاصيل الطلب".tr(), style: Styles.font18600Grey900(context)),
                        SizedBox(height: AppConstants.height20(context)),
                        ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) => OrderDetailsItem(
                              items: detailsState.orderDetailsModel.orderItems!,
                              index: index,
                            ),
                            separatorBuilder: (context, index) => SizedBox(
                              height: AppConstants.height10(context),
                            ),
                            itemCount: detailsState.orderDetailsModel.orderItems!.length),
                        SizedBox(height: AppConstants.height10(context)),
                        Divider(color: AppColors.greyColor[100]),
                        SizedBox(height: AppConstants.height20(context)),
                        PaymentAmountItem(
                          padding: 0,
                          title: "before".tr(),
                          amount: detailsState.orderDetailsModel.subtotal.toString(),
                        ),
                        SizedBox(
                          height: AppConstants.height10(context),
                        ),
                        PaymentAmountItem(
                          padding: 0,
                          title: "delivery".tr(),
                          amount: detailsState.orderDetailsModel.shippingAmount.toString(),
                        ),
                        SizedBox(
                          height: AppConstants.height10(context),
                        ),
                        RowItem(value: "${detailsState.orderDetailsModel.discountAmount} جنية", title: "الخصم",discount: true,),
                        SizedBox(height: AppConstants.height10(context)),
                        DottedLine(dashColor: Color(0xffE5E7EB)),
                        SizedBox(height: AppConstants.height10(context)),
                        PaymentAmountItem(
                          padding: 0,
                          title: "totalCost".tr(),
                          amount: detailsState.orderDetailsModel.totalAmount.toString(),
                          isTotal: true,
                        ),
                        SizedBox(height: AppConstants.height10(context)),
                        Divider(color: AppColors.greyColor[100]),
                        SizedBox(height: AppConstants.height20(context)),
                        if (isOrder && status == "delivered")
                          Container(
                            padding: EdgeInsets.symmetric(vertical: AppConstants.height10(context)),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
                              color: Colors.green.withOpacity(.2),
                            ),
                            child: Column(
                              children: [
                                Text("وقت وصول الاوردر للعميل", style: Styles.font16500Grey900(context)),
                                SizedBox(height: AppConstants.height5(context)),
                                Text(
                                  DateFormat(
                                    "dd MMM, hh:mm a",
                                    CacheKeysManger.getUserLanguageFromCache()
                                  ).format(DateTime.parse(detailsState.orderDetailsModel.deliveredAt ?? "")),
                                  style: Styles.font16500Grey900(context),
                                ),
                              ],
                            ),
                          ),
                        if (isOrder && status == "cancelled")
                          Container(
                            padding: EdgeInsets.symmetric(vertical: AppConstants.height10(context)),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
                              color: AppColors.redColor.withOpacity(.2),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "order_cancellation_time".tr(),
                                  style: Styles.font16500Grey900(context).copyWith(color: const Color(0xff990404)),
                                ),
                                SizedBox(height: AppConstants.height5(context)),
                                Text(
                                  DateFormat(
                                    "dd MMM, hh:mm a",
                                      CacheKeysManger.getUserLanguageFromCache()
                                  ).format(DateTime.parse(detailsState.orderDetailsModel.updatedAt ?? "")),
                                  style: Styles.font16500Grey900(context),
                                ),
                              ],
                            ),
                          ),
                        if (isOrder) SizedBox(height: AppConstants.height20(context)),
                      ],
                    );
                  } else {
                    return const CustomLoadingItem();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
