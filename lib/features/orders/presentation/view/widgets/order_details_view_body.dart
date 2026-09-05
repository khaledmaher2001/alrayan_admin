import 'package:alrayan_admin/core/shared_cubit/file_picker_cubit/full_screen_image_viewer.dart';
import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/delivery_order_item.dart' show deliveryStageLabel;
import 'package:alrayan_admin/features/delivery_settings/presentation/view_model/get_app_settings/get_app_settings_cubit.dart';
import 'package:alrayan_admin/features/orders/data/repo/orders_repo_impl.dart';
import 'package:alrayan_admin/features/orders/presentation/utils/order_payment_labels.dart';
import 'package:alrayan_admin/features/orders/presentation/utils/order_status_ui.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/order_product_row.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/row_item.dart';
import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/cancel_order/cancel_order_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/cancel_order/cancel_order_states.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/change_order_status/change_order_status_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/change_order_status/change_order_status_states.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_order_details/get_order_details_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderDetailsViewBody extends StatefulWidget {
  const OrderDetailsViewBody({
    super.key,
    required this.orderData,
    this.onStatusChanged,
  });

  final Items orderData;
  final void Function(int id, String newStatus)? onStatusChanged;

  @override
  State<OrderDetailsViewBody> createState() => _OrderDetailsViewBodyState();
}

class _OrderDetailsViewBodyState extends State<OrderDetailsViewBody> {
  late String currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.orderData.status ?? "pending";
  }

  String getNextStatus() {
    if (currentStatus == "pending") return "confirmed";
    if (currentStatus == "confirmed") return "shipped";
    if (currentStatus == "shipped") return "delivered";
    return "";
  }

  String getButtonText() {
    if (currentStatus == "pending") return "تأكيد الطلب";
    if (currentStatus == "confirmed") return "بدأ التوصيل";
    if (currentStatus == "shipped") return "تم التوصيل";
    return "";
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return "0 دقيقة";
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    if (days > 0) {
      return "$days يوم${hours > 0 ? ' و $hours ساعة' : ''}";
    } else if (hours > 0) {
      return "$hours ساعة${minutes > 0 ? ' و $minutes دقيقة' : ''}";
    }
    return "$minutes دقيقة";
  }

  IconData _timingIcon(String label) {
    if (label.contains("التجهيز")) return Icons.timer_outlined;
    if (label.contains("الشحن")) return Icons.local_shipping_outlined;
    if (label.contains("الإلغاء")) return Icons.cancel_outlined;
    return Icons.access_time_rounded;
  }

  /// Builds the (label, value) pairs shown in the dark status card's timing
  /// row — e.g. "مدة التجهيز" + "الوقت المنقضي" while pending, or just
  /// "الوقت حتى الإلغاء" once cancelled/refunded.
  List<MapEntry<String, String>> _timingRows() {
    final createdAt = _parseDate(widget.orderData.createdAt);
    if (createdAt == null) return const [];

    final shippedAt = _parseDate(widget.orderData.shippedAt);
    final deliveredAt = _parseDate(widget.orderData.deliveredAt);
    final updatedAt = _parseDate(widget.orderData.updatedAt);

    final rows = <MapEntry<String, String>>[];

    if (currentStatus == "cancelled" || currentStatus == "refunded") {
      final cancelledAt = updatedAt ?? DateTime.now();
      rows.add(
        MapEntry(
          "الوقت حتى الإلغاء",
          _formatDuration(cancelledAt.difference(createdAt)),
        ),
      );
    } else {
      final processingEnd =
          shippedAt ??
          (currentStatus == "pending" || currentStatus == "confirmed"
              ? DateTime.now()
              : null);
      if (processingEnd != null) {
        rows.add(
          MapEntry(
            "مدة التجهيز",
            _formatDuration(processingEnd.difference(createdAt)),
          ),
        );
      }

      if (shippedAt != null) {
        final shippingEnd = deliveredAt ??
            (currentStatus == "shipped" ? DateTime.now() : null);
        if (shippingEnd != null) {
          rows.add(
            MapEntry(
              "مدة الشحن",
              _formatDuration(shippingEnd.difference(shippedAt)),
            ),
          );
        }
      }

      final totalEnd = deliveredAt ?? DateTime.now();
      rows.add(
        MapEntry(
          currentStatus == "delivered"
              ? "إجمالي الوقت حتى التوصيل"
              : "الوقت المنقضي",
          _formatDuration(totalEnd.difference(createdAt)),
        ),
      );
    }

    return rows;
  }

  Widget _infoCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.sp15(context)),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffE3E7EC)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
      ),
      child: child,
    );
  }

  /// Icon-then-label header used at the top of every card, matching the
  /// design's "بيانات العميل 👤" style (icon sits at the trailing/right
  /// edge in RTL). Pass [trailing] for a chip pinned to the opposite side.
  Widget _sectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
    final header = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppConstants.sp20(context), color: AppColors.secondaryColor),
        SizedBox(width: AppConstants.width10(context)),
        Text(title, style: Styles.inter16500black(context)),
      ],
    );

    if (trailing == null) return header;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [header, trailing],
    );
  }

  String _initials(String? name) {
    final trimmed = (name ?? '').trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
  }

  Widget _callButton(BuildContext context, String phone, {String? label}) {
    return InkWell(
      onTap: () => launchUrlString("tel:$phone"),
      borderRadius: BorderRadius.circular(AppConstants.sp30(context) * 3),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.width15(context),
          vertical: AppConstants.height10(context),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.sp30(context) * 3),
          border: Border.all(color: AppColors.secondaryColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label ?? "اتصال",
              style: Styles.inter14500black(context).copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(width: AppConstants.width5(context)),
            Icon(Icons.call_rounded, size: AppConstants.sp15(context), color: AppColors.secondaryColor),
          ],
        ),
      ),
    );
  }

  /// "بيانات العميل" card: contact + address + notes.
  Widget _buildCustomerCard(BuildContext context) {
    final address = widget.orderData.shippingAddress;
    final user = address?.user;
    final lat = double.tryParse(address?.latitude ?? '');
    final lng = double.tryParse(address?.longitude ?? '');
    final hasNotes = (widget.orderData.notes ?? '').isNotEmpty;

    return _infoCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(context, icon: Icons.person_rounded, title: "بيانات العميل"),
          SizedBox(height: AppConstants.height15(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: AppConstants.width20(context),
                    backgroundColor: AppColors.primaryColor.shade50,
                    child: Text(
                      _initials(user?.fullName),
                      style: Styles.inter16500black(context).copyWith(color: AppColors.primaryColor),
                    ),
                  ),
                  SizedBox(width: AppConstants.width10(context)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.fullName ?? '-', style: Styles.inter16500black(context)),
                      if ((address?.phone1 ?? '').isNotEmpty) ...[
                        SizedBox(height: AppConstants.height5(context) / 2),
                        Row(
                          children: [
                            Text(
                              address!.phone1!,
                              style: Styles.inter14500black(context).copyWith(color: const Color(0xff9CA4AB)),
                            ),
                            SizedBox(width: AppConstants.width5(context)),
                            Icon(Icons.phone_rounded, size: 14, color: const Color(0xff9CA4AB)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              if ((address?.phone1 ?? '').isNotEmpty) _callButton(context, address!.phone1!),
            ],
          ),
          if ((address?.phone2 ?? '').isNotEmpty) ...[
            SizedBox(height: AppConstants.height10(context)),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: _callButton(context, address!.phone2!, label: "اتصال (2)"),
            ),
          ],
          SizedBox(height: AppConstants.height15(context)),
          Divider(height: 1, color: Colors.grey.shade200),
          SizedBox(height: AppConstants.height15(context)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_rounded, size: AppConstants.sp20(context), color: AppColors.primaryColor),
                    SizedBox(width: AppConstants.width10(context)),
                    Expanded(
                      child: Text(
                        "${address?.title ?? ''} - ${address?.description ?? ''}",
                        style: Styles.inter14500black(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (lat != null && lng != null)
                Padding(
                  padding: EdgeInsetsDirectional.only(start: AppConstants.width10(context)),
                  child: InkWell(
                    onTap: () => launchUrlString("https://www.google.com/maps/search/?api=1&query=$lat,$lng"),
                    borderRadius: BorderRadius.circular(AppConstants.sp30(context) * 3),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.width15(context),
                        vertical: AppConstants.height10(context),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppConstants.sp30(context) * 3),
                        border: Border.all(color: AppColors.secondaryColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "فتح الخريطة",
                            style: Styles.inter14500black(context).copyWith(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: AppConstants.width5(context)),
                          Icon(Icons.map_rounded, size: AppConstants.sp15(context), color: AppColors.secondaryColor),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (hasNotes) ...[
            SizedBox(height: AppConstants.height15(context)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppConstants.sp10(context)),
              decoration: BoxDecoration(
                color: const Color(0xffF5F6FA),
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.sticky_note_2_outlined, size: AppConstants.sp20(context), color: AppColors.primaryColor),
                  SizedBox(width: AppConstants.width10(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ملاحظات مهمه",
                          style: Styles.inter14500black(context).copyWith(color: AppColors.primaryColor),
                        ),
                        SizedBox(height: AppConstants.height5(context)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppConstants.width10(context),
                            vertical: AppConstants.height5(context) / 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(.1),
                            borderRadius: BorderRadius.circular(AppConstants.sp5(context)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(widget.orderData.notes!, style: Styles.inter14500black(context).copyWith(
                                    color: AppColors.primaryColor
                                )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Compact "بيانات الدفع | طريقة التوصيل" two-column summary card.
  Widget _buildPaymentDeliveryCard(BuildContext context, Items details) {
    final hasCourier = details.deliveryUser != null;

    return _infoCard(
      context,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(context, icon: Icons.credit_card_rounded, title: "payment_data".tr()),
                  SizedBox(height: AppConstants.height10(context)),
                  Text(
                    paymentMethodLabel(details.paymentMethod),
                    style: Styles.inter14500black(context),
                  ),
                  SizedBox(height: AppConstants.height10(context)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.width10(context),
                      vertical: AppConstants.height5(context) / 2,
                    ),
                    decoration: BoxDecoration(
                      color: paymentStatusColor(details.paymentStatus),
                      borderRadius: BorderRadius.circular(AppConstants.sp30(context) * 3),
                    ),
                    child: Text(
                      paymentStatusLabel(details.paymentStatus),
                      style: Styles.inter14500black(context).copyWith(color: paymentStatusTextColor(details.paymentStatus)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.width15(context)),
              child: VerticalDivider(width: 1, color: Colors.grey.shade200),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(context, icon: Icons.local_shipping_rounded, title: "delivery_method".tr()),
                  SizedBox(height: AppConstants.height10(context)),
                  Text(
                    hasCourier ? "delivered_by_courier".tr() : "delivered_by_admin".tr(),
                    style: Styles.inter14500black(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Extra card with courier name / call / stage / proof-of-delivery photo —
  /// only shown when the order actually has a courier assigned.
  Widget _buildCourierSection(BuildContext context, Items details) {
    final hasProof = (details.deliveryProofImage ?? '').isNotEmpty;

    return _infoCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(context, icon: Icons.delivery_dining_rounded, title: "بيانات المندوب"),
          SizedBox(height: AppConstants.height10(context)),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "courier_name".tr(),
                      style: Styles.inter14500black(context).copyWith(color: Colors.grey.shade600),
                    ),
                    Text(
                      details.deliveryUser!.fullName ?? '-',
                      style: Styles.inter14600black(context),
                    ),
                  ],
                ),
              ),
              if ((details.deliveryUser!.phoneNumber ?? '').isNotEmpty)
                _callButton(context, details.deliveryUser!.phoneNumber!),
            ],
          ),
          SizedBox(height: AppConstants.height10(context)),
          RowItem(
            title: "delivery_stage".tr(),
            value: deliveryStageLabel(details.deliveryStage),
          ),
          if (hasProof) ...[
            SizedBox(height: AppConstants.height10(context)),
            Text("delivery_proof".tr(), style: Styles.inter14500black(context).copyWith(color: Colors.grey.shade600)),
            SizedBox(height: AppConstants.height5(context)),
            InkWell(
              onTap: () => FullScreenImageViewer.show(context, details.deliveryProofImage!),
              borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                child: DefaultCachedNetworkImage(
                  imageUrl: details.deliveryProofImage,
                  imageWidth: double.infinity,
                  imageHeight: MediaQuery.of(context).size.height * .2,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoyaltyPointsSection(BuildContext context, Items details) {
    return _infoCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(context, icon: Icons.loyalty_rounded, title: "loyalty_points".tr()),
          SizedBox(height: AppConstants.height10(context)),
          if ((details.pointsRedeemed ?? 0) != 0)
            RowItem(title: "points_redeemed".tr(), value: "${details.pointsRedeemed}"),
          if ((details.pointsDiscountAmount ?? 0) != 0) ...[
            SizedBox(height: AppConstants.height10(context)),
            RowItem(title: "points_discount_amount".tr(), value: "${details.pointsDiscountAmount}"),
          ],
          if ((details.pointsEarned ?? 0) != 0) ...[
            SizedBox(height: AppConstants.height10(context)),
            RowItem(title: "points_earned".tr(), value: "${details.pointsEarned}"),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.height10(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Styles.inter14500black(context).copyWith(color: color ?? const Color(0xff6A7282))),
          Text(value, style: Styles.inter14500black(context).copyWith(color: color ?? Colors.black, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// "ملخص الحساب" card — cost / delivery fee / discount + a highlighted
  /// total row.
  Widget _buildAccountSummaryCard(BuildContext context) {
    return _infoCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(context, icon: Icons.receipt_long_rounded, title: "ملخص الحساب"),
          SizedBox(height: AppConstants.height15(context)),
          _summaryRow(context, "تكلفة المنتجات", "${widget.orderData.subtotal} ج.م"),
          _summaryRow(context, "رسوم التوصيل", "${widget.orderData.shippingAmount} ج.م"),
          if ((widget.orderData.discountAmount ?? 0).toString() != "0")
            _summaryRow(context, "الخصم", "- ${widget.orderData.discountAmount} ج.م", color: AppColors.redColor),
          Divider(height: AppConstants.height20(context), color: Colors.grey.shade200),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.width15(context),
              vertical: AppConstants.height10(context),
            ),
            decoration: BoxDecoration(
              color: const Color(0xffF5F6FA),
              borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("الإجمالي", style: Styles.inter16500black(context)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${widget.orderData.totalAmount} ج.م",
                      style: Styles.inter18500Black(context).copyWith(color: AppColors.primaryColor),
                    ),
                    SizedBox(width: AppConstants.width10(context)),
                    Container(
                      width: 3,
                      height: AppConstants.height20(context),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(BuildContext context) {
    final items = widget.orderData.orderItems ?? [];
    final count = items.length;
    final countLabel = count == 1
        ? "منتج واحد"
        : count == 2
            ? "منتجان"
            : "$count منتجات";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          context,
          icon: Icons.inventory_2_rounded,
          title: "المنتجات",
          trailing: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.width10(context),
              vertical: AppConstants.height5(context) / 2,
            ),
            decoration: BoxDecoration(
              color: const Color(0xffF5F6FA),
              borderRadius: BorderRadius.circular(AppConstants.sp30(context) * 3),
            ),
            child: Text(countLabel, style: Styles.inter14500black(context)),
          ),
        ),
        SizedBox(height: AppConstants.height10(context)),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => OrderProductRow(item: items[index]),
          separatorBuilder: (context, index) => SizedBox(height: AppConstants.height10(context)),
          itemCount: items.length,
        ),
      ],
    );
  }

  void _confirmCancel(BuildContext context, CancelOrderCubit cubit) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.cancel_outlined, size: MediaQuery.of(context).size.width * .08, color: AppColors.redColor),
                ),
              ],
            ),
            SizedBox(height: AppConstants.height10(context)),
            Text(
              "إلغاء الطلب",
              textAlign: TextAlign.center,
              style: Styles.inter16500black(context),
            ),
            SizedBox(height: AppConstants.height10(context)),
            Text(
              "هل أنت متأكد من إلغاء الطلب رقم ${widget.orderData.orderNumber ?? ''}؟",
              style: Styles.inter14500black(
                context,
              ).copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 4),
            Text(
              "لا يمكن التراجع عن هذا الإجراء",
              style: Styles.inter14500black(
                context,
              ).copyWith(color: Colors.red.shade400),
            ),
            SizedBox(height: AppConstants.height20(context)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      cubit.cancelOrder(orderId: widget.orderData.id!);
                    },
                    child: Text(
                      "تأكيد الإلغاء",
                      style: Styles.inter16500black(
                        context,
                      ).copyWith(color: Colors.white),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    "تراجع",
                    style: Styles.inter16500black(
                      context,
                    ).copyWith(color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRefund(BuildContext context, ChangeOrderStatusCubit cubit) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    AssetData.refunded,
                    width: MediaQuery.of(context).size.width * .08,
                    color: AppColors.redColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.height10(context)),
            Text(
              "استرداد قيمة الطلب",
              textAlign: TextAlign.center,
              style: Styles.inter16500black(context),
            ),
            SizedBox(height: AppConstants.height10(context)),
            Text(
              "هل أنت متأكد من استرداد قيمة هذا الطلب بمبلغ ${widget.orderData.totalAmount} ${"lE!".tr()}؟",
              style: Styles.inter14500black(
                context,
              ).copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 4),
            Text(
              "لا يمكن التراجع عن هذا الإجراء",
              style: Styles.inter14500black(
                context,
              ).copyWith(color: Colors.red.shade400),
            ),
            SizedBox(height: AppConstants.height20(context)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      cubit.changeOrderStatus(
                        orderId: widget.orderData.id!,
                        data: {"status": "refunded"},
                      );
                    },
                    child: Text(
                      "تأكيد الاسترداد",
                      style: Styles.inter16500black(
                        context,
                      ).copyWith(color: Colors.white),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    "إلغاء",
                    style: Styles.inter16500black(
                      context,
                    ).copyWith(color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Text("تفاصيل الطلب",textAlign: TextAlign.center, style: Styles.inter18500Black(context))),
              ],
            ),
            SizedBox(height: AppConstants.height5(context) / 2),
            Text(
              widget.orderData.orderNumber ?? '',
              style: Styles.inter14500black(context).copyWith(color: const Color(0xff9CA4AB), letterSpacing: 0.5),
            ),
          ],
        ),
        PositionedDirectional(
          start: 0,
          child: InkWell(
            onTap: () => NavigationUtils.navigateBack(context: context),
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: AppConstants.width20(context) * 2.2,
              height: AppConstants.width20(context) * 2.2,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.gray.withValues(alpha: .15)),
              child: Icon(Icons.arrow_back_rounded, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final statusColor = AppConstants.getTextColor(currentStatus);
    final timingRows = _timingRows();

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.secondaryColor,
            padding: EdgeInsets.all(AppConstants.sp15(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "حالة الطلب",
                            style: Styles.inter14500black(context).copyWith(color: Colors.white70),
                          ),
                          SizedBox(height: AppConstants.height5(context)),
                          Row(
                            children: [
                              Text(
                                AppConstants.getStatusText(currentStatus),
                                style: Styles.inter18500Black(context).copyWith(color: Colors.white),
                              ),
                              SizedBox(width: AppConstants.width10(context)),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(AppConstants.sp10(context)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                      ),
                      child: Icon(OrderStatusUi.icon(currentStatus), color: AppColors.secondaryColor, size: 28),
                    ),
                  ],
                ),
                if (timingRows.isNotEmpty) ...[
                  SizedBox(height: AppConstants.height15(context)),
                  Divider(height: 1, color: Colors.white.withValues(alpha: .12)),
                  SizedBox(height: AppConstants.height15(context)),
                  Row(
                    children: [
                      for (var i = 0; i < timingRows.length; i++) ...[
                        if (i != 0)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: AppConstants.width10(context)),
                            child: Container(width: 1, height: 18, color: Colors.white.withValues(alpha: .2)),
                          ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${timingRows[i].key}  ",
                              style: Styles.inter14500black(context).copyWith(color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              timingRows[i].value,
                              style: Styles.inter14500black(context).copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(width: AppConstants.width5(context)),
                            Icon(_timingIcon(timingRows[i].key), size: 14, color: Colors.white70),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(height: 4, color: statusColor),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // When delivery is enabled app-wide, a courier's own app is expected to
    // move the order through "shipped"/"delivered" — the admin can only
    // confirm it here. With delivery disabled there's no courier flow, so
    // the admin keeps full manual control over every status.
    final appSettingsState = context.watch<GetAppSettingsCubit>().state;
    final isDeliveryEnabled = appSettingsState is GetAppSettingsSuccessState
        ? appSettingsState.settingsModel.delivery ?? false
        : false;

    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: AppConstants.height10(context)),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: AppConstants.width15(context)),
            child: _buildHeader(context),
          ),
          SizedBox(height: AppConstants.height15(context)),
          Divider(height: 1, color: Colors.grey.shade200),

          Expanded(
            child: ListView(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: AppConstants.width15(context),
                vertical: AppConstants.height15(context),
              ),
              children: [
                _buildStatusCard(context),
                SizedBox(height: AppConstants.height15(context)),
                _buildCustomerCard(context),
                SizedBox(height: AppConstants.height15(context)),
                BlocBuilder<GetOrderDetailsCubit, GetOrderDetailsState>(
                  builder: (context, detailsState) {
                    final details = detailsState is GetOrderDetailsSuccessState
                        ? detailsState.orderDetailsModel
                        : widget.orderData;
                    final hasCourier = details.deliveryUser != null;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPaymentDeliveryCard(context, details),
                        if (hasCourier) ...[
                          SizedBox(height: AppConstants.height15(context)),
                          _buildCourierSection(context, details),
                        ],
                        if ((details.pointsRedeemed ?? 0) != 0 || (details.pointsEarned ?? 0) != 0) ...[
                          SizedBox(height: AppConstants.height15(context)),
                          _buildLoyaltyPointsSection(context, details),
                        ],
                      ],
                    );
                  },
                ),
                SizedBox(height: AppConstants.height15(context)),
                _buildAccountSummaryCard(context),
                SizedBox(height: AppConstants.height15(context)),
                _buildProductsSection(context),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: AppConstants.width15(context),
              vertical: AppConstants.height10(context),
            ),
            child: Row(
              children: [
                if (currentStatus == "pending") ...[
                  Expanded(
                    child: BlocProvider(
                      create: (context) =>
                          CancelOrderCubit(getIt.get<OrdersRepoImpl>()),
                      child: BlocConsumer<CancelOrderCubit, CancelOrderStates>(
                        listener: (context, state) {
                          if (state is CancelOrderSuccessState) {
                            cherryToast(text: state.message, context: context);
                            setState(() {
                              currentStatus = "cancelled";
                              widget.orderData.status = "cancelled";
                            });
                            widget.onStatusChanged?.call(widget.orderData.id!, "cancelled");
                          } else if (state is CancelOrderErrorState) {
                            cherryToast(
                              text: state.error,
                              isSuccess: false,
                              context: context,
                            );
                          }
                        },
                        builder: (context, state) {
                          return state is CancelOrderLoadingState
                              ? const CustomLoadingItem()
                              : DefaultButton(
                                  onPress: () => _confirmCancel(
                                    context,
                                    context.read<CancelOrderCubit>(),
                                  ),
                                  text: "إلغاء الطلب",
                                  borderRadius: AppConstants.sp30(context) * 3,
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

                if (currentStatus == "pending" ||
                    (!isDeliveryEnabled &&
                        (currentStatus == "confirmed" ||
                            currentStatus == "shipped")))
                  Expanded(
                    child: BlocProvider(
                      create: (context) =>
                          ChangeOrderStatusCubit(getIt.get<OrdersRepoImpl>()),
                      child:
                          BlocConsumer<
                            ChangeOrderStatusCubit,
                            ChangeOrderStatusStates
                          >(
                            listener: (context, state) {
                              if (state is ChangeOrderStatusSuccessState) {
                                cherryToast(
                                  text: state.message,
                                  context: context,
                                );
                                final next = getNextStatus();
                                setState(() {
                                  currentStatus = next;
                                  widget.orderData.status = next;
                                });
                                widget.onStatusChanged?.call(widget.orderData.id!, next);
                              } else if (state is ChangeOrderStatusErrorState) {
                                cherryToast(
                                  text: state.error,
                                  isSuccess: false,
                                  context: context,
                                );
                              }
                            },
                            builder: (context, state) {
                              return state is ChangeOrderStatusLoadingState
                                  ? const CustomLoadingItem()
                                  : DefaultButton(
                                      onPress: () {
                                        context
                                            .read<ChangeOrderStatusCubit>()
                                            .changeOrderStatus(
                                              orderId: widget.orderData.id!,
                                              data: {"status": getNextStatus()},
                                            );
                                      },
                                      text: getButtonText(),
                                      borderRadius: AppConstants.sp30(context) * 3,
                                      height: AppConstants.height15(context),
                                      backgroundColor: AppColors.primaryColor,
                                    );
                            },
                          ),
                    ),
                  ),

                if (isDeliveryEnabled &&
                    (currentStatus == "confirmed" || currentStatus == "shipped"))
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.width10(context),
                        vertical: AppConstants.height15(context),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(AppConstants.sp30(context) * 3),
                      ),
                      child: Text(
                        "awaiting_courier_update".tr(),
                        textAlign: TextAlign.center,
                        style: Styles.inter14500black(context).copyWith(color: Colors.grey.shade700),
                      ),
                    ),
                  ),

                if (currentStatus == "delivered")
                  Expanded(
                    child: BlocProvider(
                      create: (context) =>
                          ChangeOrderStatusCubit(getIt.get<OrdersRepoImpl>()),
                      child:
                          BlocConsumer<
                            ChangeOrderStatusCubit,
                            ChangeOrderStatusStates
                          >(
                            listener: (context, state) {
                              if (state is ChangeOrderStatusSuccessState) {
                                cherryToast(
                                  text: state.message,
                                  context: context,
                                );
                                setState(() {
                                  currentStatus = "refunded";
                                  widget.orderData.status = "refunded";
                                });
                                widget.onStatusChanged?.call(widget.orderData.id!, "refunded");
                              } else if (state is ChangeOrderStatusErrorState) {
                                cherryToast(
                                  text: state.error,
                                  isSuccess: false,
                                  context: context,
                                );
                              }
                            },
                            builder: (context, state) {
                              return state is ChangeOrderStatusLoadingState
                                  ? const CustomLoadingItem()
                                  : DefaultButton(
                                      onPress: () => _confirmRefund(
                                        context,
                                        context.read<ChangeOrderStatusCubit>(),
                                      ),
                                      text: "استرداد قيمة الطلب",
                                      borderRadius: AppConstants.sp30(context) * 3,
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
              ],
            ),
          ),

          if (currentStatus == "delivered" ||
              currentStatus == "cancelled" ||
              currentStatus == "refunded")
            Padding(
              padding: EdgeInsetsDirectional.only(bottom: AppConstants.height15(context)),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.width15(context),
                  vertical: AppConstants.height15(context),
                ),
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(
                  horizontal: AppConstants.width15(context),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                  color: currentStatus == "delivered"
                      ? AppColors.primaryColor
                      : AppColors.redColor,
                ),
                child: Text(
                  AppConstants.getStatusText(currentStatus),
                  textAlign: TextAlign.center,
                  style: Styles.inter16500black(
                    context,
                  ).copyWith(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
