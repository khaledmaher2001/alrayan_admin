import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_cubit/file_picker_cubit/full_screen_image_viewer.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_back_button.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/delivery_order_item.dart';
import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:alrayan_admin/features/orders/data/repo/orders_repo_impl.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/order_details_item.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/payment_amount_item.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/row_item.dart';
import 'package:alrayan_admin/features/orders/presentation/utils/order_payment_labels.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_order_details/get_order_details_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher_string.dart';

const _deliveryStagesOrder = [
  'assigned',
  'arrived_at_store',
  'picked_up',
  'on_the_way',
  'delivered',
];

/// تفاصيل طلب الدليفري — `GET /orders/{id}`، معروضة بمعلومات العميل، العنوان
/// والإحداثيات، المنتجات، الإجماليات، الدفع، الملاحظات، المندوب الحالي،
/// وTimeline لمراحل التوصيل.
class DeliveryOrderDetailsView extends StatelessWidget {
  const DeliveryOrderDetailsView({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetOrderDetailsCubit(getIt<OrdersRepoImpl>())
            ..getOrderDetails(orderId: orderId, withLoading: true),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: AppConstants.height10(context)),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.width15(context),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CustomBackButton(),
                    Text(
                      "order_details_title".tr(),
                      textAlign: TextAlign.center,
                      style: Styles.inter18500Black(context),
                    ),
                    SizedBox(width: AppConstants.width30(context)),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<GetOrderDetailsCubit, GetOrderDetailsState>(
                  builder: (context, state) {
                    if (state is GetOrderDetailsErrorState) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(
                            AppConstants.width20(context),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: DsColor.danger,
                                size: 48,
                              ),
                              SizedBox(height: AppConstants.height10(context)),
                              Text(
                                state.error,
                                textAlign: TextAlign.center,
                                style: Styles.inter14500black(context),
                              ),
                              SizedBox(height: AppConstants.height15(context)),
                              ElevatedButton(
                                onPressed: () => context
                                    .read<GetOrderDetailsCubit>()
                                    .getOrderDetails(
                                      orderId: orderId,
                                      withLoading: true,
                                    ),
                                child: Text("retry".tr()),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (state is GetOrderDetailsSuccessState) {
                      return _OrderDetailsContent(
                        order: state.orderDetailsModel,
                      );
                    }
                    return const CustomLoadingItem();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderDetailsContent extends StatelessWidget {
  const _OrderDetailsContent({required this.order});

  final Items order;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.width20(context),
        vertical: AppConstants.height15(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.orderNumber ?? '-',
                  style: Styles.inter18500Black(context),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.width15(context),
                  vertical: AppConstants.height5(context) / 2,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.getStatusColor(order.status),
                  borderRadius: BorderRadius.circular(
                    AppConstants.sp30(context),
                  ),
                ),
                child: Text(
                  AppConstants.getStatusText(order.status),
                  style: Styles.inter14500black(
                    context,
                  ).copyWith(color: AppConstants.getTextColor(order.status)),
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height20(context)),

          _Section(
            title: "customer_data".tr(),
            child: Column(
              children: [
                RowItem(
                  title: "customer_name".tr(),
                  value: order.shippingAddress?.user?.fullName ?? '-',
                ),
                SizedBox(height: AppConstants.height10(context),),
                _PhoneRow(
                  label: "phoneNumber".tr(),
                  phone: order.shippingAddress?.phone1,
                ),
                SizedBox(height: AppConstants.height10(context),),
                if ((order.shippingAddress?.phone2 ?? '').isNotEmpty)
                  Column(
                    children: [
                      _PhoneRow(
                        label: "second_phone_number".tr(),
                        phone: order.shippingAddress!.phone2,
                      ),
                      SizedBox(height: AppConstants.height10(context),),
                    ],
                  ),


                RowItem(
                  title: "address".tr(),
                  value:
                      "${order.shippingAddress?.title ?? ''} ${order.shippingAddress?.description ?? ''}"
                          .trim(),
                ),
                if (order.shippingAddress?.latitude != null &&
                    order.shippingAddress?.longitude != null)
                  Padding(
                    padding: EdgeInsets.only(
                      top: AppConstants.height10(context),
                    ),
                    child: _ViewOnMapButton(
                      latitude: order.shippingAddress!.latitude!,
                      longitude: order.shippingAddress!.longitude!,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: AppConstants.height20(context)),

          _Section(
            title: "delivery_courier".tr(),
            child: order.deliveryUser != null
                ? Column(
                    children: [
                      RowItem(
                        title: "courier_name".tr(),
                        value: order.deliveryUser!.fullName ?? '-',
                      ),
                      RowItem(
                        title: "phoneNumber".tr(),
                        value: order.deliveryUser!.phoneNumber ?? '-',
                      ),
                    ],
                  )
                : Text(
                    "unassigned_order".tr(),
                    style: Styles.inter14500black(
                      context,
                    ).copyWith(color: DsColor.textMuted),
                  ),
          ),
          SizedBox(height: AppConstants.height20(context)),

          _Section(
            title: "delivery_timeline".tr(),
            child: _DeliveryTimeline(currentStage: order.deliveryStage),
          ),
          SizedBox(height: AppConstants.height20(context)),

          _Section(
            title: "delivery_proof".tr(),
            child: (order.deliveryProofImage ?? '').isEmpty
                ? Text(
                    "no_delivery_proof".tr(),
                    style: Styles.inter14500black(
                      context,
                    ).copyWith(color: DsColor.textMuted),
                  )
                : _DeliveryProofImage(imageUrl: order.deliveryProofImage!),
          ),
          SizedBox(height: AppConstants.height20(context)),

          if ((order.notes ?? '').isNotEmpty) ...[
            _NotesBanner(notes: order.notes!),
            SizedBox(height: AppConstants.height20(context)),
          ],

          if ((order.orderItems ?? []).isNotEmpty) ...[
            Text("products".tr(), style: Styles.inter16500black(context)),
            SizedBox(height: AppConstants.height10(context)),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.orderItems!.length,
              separatorBuilder: (_, _) =>
                  SizedBox(height: AppConstants.height10(context)),
              itemBuilder: (context, index) =>
                  OrderDetailsItem(items: order.orderItems, index: index),
            ),
            SizedBox(height: AppConstants.height20(context)),
          ],

          _Section(
            title: "totals".tr(),
            child: Column(
              children: [
                PaymentAmountItem(
                  title: "subtotal".tr(),
                  amount: "${order.subtotal ?? 0}",
                  padding: 0,
                ),
                if (order.discountAmount != null && order.discountAmount != 0)
                  PaymentAmountItem(
                    title: "discount".tr(),
                    amount: "-${order.discountAmount}",
                    padding: 0,
                  ),
                PaymentAmountItem(
                  title: "shipping".tr(),
                  amount: "${order.shippingAmount ?? 0}",
                  padding: 0,
                ),
                Divider(color: DsColor.border),
                PaymentAmountItem(
                  title: "total".tr(),
                  amount: "${order.totalAmount ?? 0}",
                  isTotal: true,
                  padding: 0,
                ),
              ],
            ),
          ),
          SizedBox(height: AppConstants.height20(context)),

          if ((order.pointsRedeemed ?? 0) != 0 || (order.pointsEarned ?? 0) != 0) ...[
            _Section(
              title: "loyalty_points".tr(),
              child: Column(
                children: [
                  if ((order.pointsRedeemed ?? 0) != 0)
                    RowItem(
                      title: "points_redeemed".tr(),
                      value: "${order.pointsRedeemed}",
                    ),
                  if ((order.pointsDiscountAmount ?? 0) != 0)
                    RowItem(
                      title: "points_discount_amount".tr(),
                      value: "${order.pointsDiscountAmount}",
                    ),
                  if ((order.pointsEarned ?? 0) != 0)
                    RowItem(
                      title: "points_earned".tr(),
                      value: "${order.pointsEarned}",
                    ),
                ],
              ),
            ),
            SizedBox(height: AppConstants.height20(context)),
          ],

          _Section(
            title: "payment_data".tr(),
            child: Column(
              children: [
                RowItem(
                  title: "payment_method".tr(),
                  value: paymentMethodLabel(order.paymentMethod),
                ),
                RowItem(
                  title: "payment_status".tr(),
                  value: paymentStatusLabel(order.paymentStatus),
                ),
              ],
            ),
          ),

          SizedBox(height: AppConstants.height30(context)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.sp15(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        border: Border.all(color: DsColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Styles.inter16500black(context)),
          SizedBox(height: AppConstants.height10(context)),
          child,
        ],
      ),
    );
  }
}

/// Phone row with a "call now" button — mirrors the same green
/// call-button pattern already used in the customer-facing order details
/// screen (`order_details_view_body.dart`), just built on `tel:` via
/// `url_launcher` instead of duplicating that widget.
class _PhoneRow extends StatelessWidget {
  const _PhoneRow({required this.label, required this.phone});

  final String label;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    if (phone == null || phone!.isEmpty) {
      return RowItem(title: label, value: '-');
    }
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppConstants.height5(context) / 2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Styles.inter14500black(
                    context,
                  ).copyWith(color: DsColor.textMuted),
                ),
                Text(phone!, style: Styles.inter14600black(context)),
              ],
            ),
          ),
          InkWell(
            onTap: () => launchUrlString("tel:$phone"),
            borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.width10(context),
                vertical: AppConstants.height5(context),
              ),
              decoration: BoxDecoration(
                color: DsColor.success,
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.call,
                    color: Colors.white,
                    size: AppConstants.sp15(context),
                  ),
                  SizedBox(width: AppConstants.width5(context)),
                  Text(
                    "call_now".tr(),
                    style: Styles.inter14500black(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
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

/// Opens the customer's location in Google Maps instead of printing the
/// raw latitude/longitude on screen.
class _ViewOnMapButton extends StatelessWidget {
  const _ViewOnMapButton({required this.latitude, required this.longitude});

  final String latitude;
  final String longitude;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrlString(
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude",
      ),
      borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: AppConstants.height10(context)),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(.08),
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          border: Border.all(color: AppColors.primaryColor.withOpacity(.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              color: AppColors.primaryColor,
              size: AppConstants.sp20(context),
            ),
            SizedBox(width: AppConstants.width5(context)),
            Text(
              "view_on_map".tr(),
              style: Styles.inter14500black(context).copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Order notes, shown prominently in red right above the products list so
/// they can't be missed while preparing/delivering the order.
class _NotesBanner extends StatelessWidget {
  const _NotesBanner({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.sp15(context)),
      decoration: BoxDecoration(
        color: DsColor.dangerBg,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        border: Border.all(color: DsColor.danger),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            color: DsColor.danger,
            size: AppConstants.sp20(context),
          ),
          SizedBox(width: AppConstants.width10(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "notes".tr(),
                  style: Styles.inter14600black(context).copyWith(
                    color: DsColor.danger,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppConstants.height5(context) / 2),
                Text(
                  notes,
                  style: Styles.inter14600black(context).copyWith(
                    color: DsColor.danger,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The photo the courier uploads as proof of delivery — tap to view full
/// screen via the same viewer used for product images.
class _DeliveryProofImage extends StatelessWidget {
  const _DeliveryProofImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => FullScreenImageViewer.show(context, imageUrl),
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
            child: DefaultCachedNetworkImage(
              imageUrl: imageUrl,
              imageWidth: double.infinity,
              imageHeight: MediaQuery.of(context).size.height * .22,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: AppConstants.height5(context)),
        Text(
          "delivery_proof_note".tr(),
          style: Styles.inter12500Black(context).copyWith(color: DsColor.textMuted),
        ),
      ],
    );
  }
}

class _DeliveryTimeline extends StatelessWidget {
  const _DeliveryTimeline({required this.currentStage});

  final String? currentStage;

  @override
  Widget build(BuildContext context) {
    if (currentStage == null) {
      return Text(
        "delivery_stage_none".tr(),
        style: Styles.inter14500black(
          context,
        ).copyWith(color: DsColor.textMuted),
      );
    }

    final currentIndex = _deliveryStagesOrder.indexOf(currentStage!);

    return Column(
      children: List.generate(_deliveryStagesOrder.length, (index) {
        final stage = _deliveryStagesOrder[index];
        final isDone = currentIndex >= 0 && index <= currentIndex;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(
                  isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isDone ? AppColors.primaryColor : DsColor.textSubtle,
                  size: AppConstants.sp20(context),
                ),
                if (index != _deliveryStagesOrder.length - 1)
                  Container(
                    width: 2,
                    height: AppConstants.height20(context),
                    color: isDone
                        ? AppColors.primaryColor
                        : DsColor.border,
                  ),
              ],
            ),
            SizedBox(width: AppConstants.width10(context)),
            Padding(
              padding: EdgeInsets.only(bottom: AppConstants.height10(context)),
              child: Text(
                deliveryStageLabel(stage),
                style: Styles.inter14500black(context).copyWith(
                  color: isDone ? Colors.black : DsColor.textMuted,
                  fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
