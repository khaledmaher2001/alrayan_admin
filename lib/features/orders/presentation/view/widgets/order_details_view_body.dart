import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/orders/data/repo/orders_repo_impl.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/payment_amount_item.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/row_item.dart';
import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/cancel_order/cancel_order_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/cancel_order/cancel_order_states.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/change_order_status/change_order_status_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/change_order_status/change_order_status_states.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/order_details_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OrderDetailsViewBody extends StatefulWidget {
  const OrderDetailsViewBody({super.key, required this.orderData});

  final Items orderData;

  @override
  State<OrderDetailsViewBody> createState() => _OrderDetailsViewBodyState();
}

class _OrderDetailsViewBodyState extends State<OrderDetailsViewBody> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: AppConstants.height10(context)),
          CustomAppBar(title: "orderDetails".tr(), textColor: AppColors.primaryColor, hasBack: true),
          SizedBox(height: AppConstants.height10(context)),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppConstants.sp10(context)),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xffE3E7EC)),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(AppConstants.sp5(context)),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Color(0xffF6F8FE)),
                                  ),
                                  child: SvgPicture.asset(
                                    AppConstants.getStatusIcon(widget.orderData.status),
                                    color: Colors.black,
                                    width: MediaQuery.of(context).size.width * .08,
                                  ),
                                ),
                                SizedBox(width: AppConstants.width10(context)),
                                Expanded(
                                  child: Text(
                                    AppConstants.getStatusText(widget.orderData.status),
                                    style: Styles.inter14600black(
                                      context,
                                    ).copyWith(color: AppConstants.getTextColor(widget.orderData.status)),
                                  ),
                                ),
                                if (widget.orderData.status == "shipped") ...[
                                  SizedBox(width: AppConstants.width10(context)),
                                  Text(
                                    "10-20 دقيقة",
                                    style: Styles.inter14600black(context).copyWith(color: AppColors.primaryColor),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppConstants.height10(context)),
                      Text(
                        "address".tr(),
                        style: Styles.inter14600black(context).copyWith(color: AppColors.primaryColor),
                      ),
                      SizedBox(height: AppConstants.height10(context)),
                      Text(
                        "${widget.orderData.shippingAddress!.title!} - ${widget.orderData.shippingAddress!.description!}",
                        style: Styles.inter14500black(context),
                      ),
                      SizedBox(height: AppConstants.height20(context)),
                      DottedLine(dashColor: Color(0xffE5E7EB)),
                      SizedBox(height: AppConstants.height20(context)),
                      PaymentAmountItem(padding: 0, title: "before".tr(), amount: widget.orderData.subtotal.toString()),
                      SizedBox(height: AppConstants.height10(context)),
                      PaymentAmountItem(
                        padding: 0,
                        title: "delivery".tr(),
                        amount: widget.orderData.shippingAmount.toString(),
                      ),
                      SizedBox(height: AppConstants.height10(context)),
                      RowItem(value: "${widget.orderData.discountAmount} جنية", title: "الخصم", discount: true),
                      SizedBox(height: AppConstants.height10(context)),
                      DottedLine(dashColor: Color(0xffE5E7EB)),
                      SizedBox(height: AppConstants.height10(context)),
                      PaymentAmountItem(
                        padding: 0,
                        title: "totalCost".tr(),
                        amount: widget.orderData.totalAmount.toString(),
                        isTotal: true,
                      ),
                      SizedBox(height: AppConstants.height30(context)),
                    ],
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => OrderDetailsItem(items: widget.orderData.orderItems!, index: index),
                  separatorBuilder: (context, index) => SizedBox(height: AppConstants.height10(context)),
                  itemCount: widget.orderData.orderItems!.length,
                ),
              ],
            ),
          ),
          SizedBox(height: AppConstants.height20(context)),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
            child: Row(
              children: [
                if (widget.orderData.status == "pending") ...[
                  Expanded(
                    child: BlocProvider(
                      create: (BuildContext context) => CancelOrderCubit(getIt.get<OrdersRepoImpl>()),
                      child: BlocConsumer<CancelOrderCubit, CancelOrderStates>(
                        listener: (context, state) {
                          if (state is CancelOrderSuccessState) {
                            cherryToast(text: state.message, context: context);
                            setState(() {
                              widget.orderData.status = "cancelled";
                            });
                          } else if (state is CancelOrderErrorState) {
                            cherryToast(text: state.error, isSuccess: false, context: context);
                          }
                        },
                        builder: (context, state) {
                          return state is CancelOrderLoadingState
                              ? const CustomLoadingItem()
                              : DefaultButton(
                                  onPress: () {
                                    context.read<CancelOrderCubit>().cancelOrder(orderId: widget.orderData.id!);
                                  },
                                  text: "الغاء الطلب",
                                  borderRadius: AppConstants.sp10(context),
                                  height: AppConstants.height15(context),
                                  hasBorder: true,
                                  textColor: AppColors.redColor,
                                  shadowColor: Colors.transparent,
                                  borderColor: AppColors.redColor,
                                  backgroundColor: Colors.transparent,
                                );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: AppConstants.width15(context)),
                ],
                if (widget.orderData.status == "pending" ||
                    widget.orderData.status == "confirmed" ||
                    widget.orderData.status == "shipped")
                  Expanded(
                    child: BlocProvider(
                      create: (BuildContext context) => ChangeOrderStatusCubit(getIt.get<OrdersRepoImpl>()),
                      child: BlocConsumer<ChangeOrderStatusCubit, ChangeOrderStatusStates>(
                        listener: (context, state) {
                          if (state is ChangeOrderStatusSuccessState) {
                            cherryToast(text: state.message, context: context);
                            setState(() {
                              widget.orderData.status == "pending"
                                  ? widget.orderData.status = "confirmed"
                                  : widget.orderData.status == "confirmed"
                                  ? widget.orderData.status = "shipped"
                                  : widget.orderData.status = "delivered";
                            });
                          } else if (state is ChangeOrderStatusErrorState) {
                            cherryToast(text: state.error, isSuccess: false, context: context);
                          }
                        },
                        builder: (context, state) {
                          return state is ChangeOrderStatusLoadingState
                              ? const CustomLoadingItem()
                              : DefaultButton(
                                  onPress: () {
                                    context.read<ChangeOrderStatusCubit>().changeOrderStatus(
                                      orderId: widget.orderData.id!,
                                      data: {
                                        "status": widget.orderData.status == "pending"
                                            ? "confirmed"
                                            : widget.orderData.status == "confirmed"
                                            ? "shipped"
                                            : widget.orderData.status == "shipped"
                                            ? "delivered"
                                            : "",
                                      },
                                    );
                                  },
                                  text: widget.orderData.status == "pending"
                                      ? "تأكيد الطلب"
                                      : widget.orderData.status == "confirmed"
                                      ? "بدأ التوصيل"
                                      : widget.orderData.status == "shipped"
                                      ? "تم التوصيل"
                                      : "",
                                  borderRadius: AppConstants.sp10(context),
                                  height: AppConstants.height15(context),
                                  backgroundColor: AppColors.primaryColor,
                                );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (widget.orderData.status == "delivered" ||
              widget.orderData.status == "cancelled" ||
              widget.orderData.status == "refunded")
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.width15(context),
                vertical: AppConstants.height15(context),
              ),
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: AppConstants.width15(context)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                color: widget.orderData.status == "delivered" ? AppColors.primaryColor : AppColors.redColor,
              ),
              child: Text(
                AppConstants.getStatusText(widget.orderData.status),
                textAlign: TextAlign.center,
                style: Styles.inter16500black(context).copyWith(color: Colors.white),
              ),
            ),
          SizedBox(height: AppConstants.height20(context)),
        ],
      ),
    );
  }
}
