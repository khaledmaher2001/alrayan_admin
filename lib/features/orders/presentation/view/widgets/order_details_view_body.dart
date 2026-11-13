import 'package:alrayan_admin/core/shared_cubit/file_picker_cubit/full_screen_image_viewer.dart';
import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/delivery_order_item.dart' show deliveryStageLabel;
import 'package:alrayan_admin/features/delivery_settings/presentation/view_model/get_app_settings/get_app_settings_cubit.dart';
import 'package:alrayan_admin/features/orders/data/repo/orders_repo_impl.dart';
import 'package:alrayan_admin/features/orders/presentation/utils/order_payment_labels.dart';
import 'package:alrayan_admin/features/orders/presentation/utils/order_status_ui.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/order_product_row.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/cancel_order_dialog.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/order_money_section.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/row_item.dart';
import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/cancel_order/cancel_order_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/cancel_order/cancel_order_states.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/change_order_status/change_order_status_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/change_order_status/change_order_status_states.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_order_details/get_order_details_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:alrayan_admin/core/design/ds.dart';
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
    if (currentStatus == "pending") return "s_confirm_order".tr();
    if (currentStatus == "confirmed") return "s_delivery_started".tr();
    if (currentStatus == "shipped") return "s_delivered".tr();
    return "";
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return "s_0_min".tr();
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    if (days > 0) {
      return "${"i_dur_days".tr(namedArgs: {"a": "$days"})}${hours > 0 ? "${"i_dur_and".tr()}${"i_dur_hours".tr(namedArgs: {"a": "$hours"})}" : ""}";
    } else if (hours > 0) {
      return "${"i_dur_hours".tr(namedArgs: {"a": "$hours"})}${minutes > 0 ? "${"i_dur_and".tr()}${"i_dur_minutes".tr(namedArgs: {"a": "$minutes"})}" : ""}";
    }
    return "i_x_min_68".tr(namedArgs: {"a": "${minutes}"});
  }

  IconData _timingIcon(String label) {
    if (label.contains("s_preparation".tr())) return Icons.timer_outlined;
    if (label.contains("s_shipping".tr())) return Icons.local_shipping_outlined;
    if (label.contains("s_cancellation".tr())) return Icons.cancel_outlined;
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
          "s_time_until_cancellation".tr(),
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
            "s_preparation_time".tr(),
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
              "s_shipping_time".tr(),
              _formatDuration(shippingEnd.difference(shippedAt)),
            ),
          );
        }
      }

      final totalEnd = deliveredAt ?? DateTime.now();
      rows.add(
        MapEntry(
          currentStatus == "delivered"
              ? "s_total_time_to_delivery".tr()
              : "s_time_elapsed".tr(),
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
        Icon(icon, size: AppConstants.sp20(context), color: AppColors.primaryColor),
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
          border: Border.all(color: AppColors.primaryColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label ?? "s_call".tr(),
              style: Styles.inter14500black(context).copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(width: AppConstants.width5(context)),
            Icon(Icons.call_rounded, size: AppConstants.sp15(context), color: AppColors.primaryColor),
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
          _sectionHeader(context, icon: Icons.person_rounded, title: "s_customer_details".tr()),
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
              child: _callButton(context, address!.phone2!, label: "s_call_2".tr()),
            ),
          ],
          SizedBox(height: AppConstants.height15(context)),
          Divider(height: 1, color: DsColor.border),
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
                        border: Border.all(color: AppColors.primaryColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "s_open_map".tr(),
                            style: Styles.inter14500black(context).copyWith(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: AppConstants.width5(context)),
                          Icon(Icons.map_rounded, size: AppConstants.sp15(context), color: AppColors.primaryColor),
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
                          "s_important_notes".tr(),
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
          if ((widget.orderData.cancellationReason ?? '').isNotEmpty) ...[
            SizedBox(height: AppConstants.height15(context)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppConstants.sp10(context)),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(.08),
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("s_cancellation_reason".tr(), style: Styles.inter14500black(context).copyWith(color: Colors.red)),
                  SizedBox(height: AppConstants.height5(context)),
                  Text(widget.orderData.cancellationReason!, style: Styles.inter14500black(context)),
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
              child: VerticalDivider(width: 1, color: DsColor.border),
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
          _sectionHeader(context, icon: Icons.delivery_dining_rounded, title: "s_courier_details".tr()),
          SizedBox(height: AppConstants.height10(context)),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "courier_name".tr(),
                      style: Styles.inter14500black(context).copyWith(color: DsColor.textMuted),
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
            Text("delivery_proof".tr(), style: Styles.inter14500black(context).copyWith(color: DsColor.textMuted)),
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
          _sectionHeader(context, icon: Icons.receipt_long_rounded, title: "s_bill_summary".tr()),
          SizedBox(height: AppConstants.height15(context)),
          _summaryRow(context, "s_products_cost".tr(), "${widget.orderData.subtotal} ${"s_egp".tr()}"),
          _summaryRow(context, "s_delivery_fees".tr(), "${widget.orderData.shippingAmount} ${"s_egp".tr()}"),
          if ((widget.orderData.discountAmount ?? 0).toString() != "0")
            _summaryRow(context, "s_discount".tr(), "- ${widget.orderData.discountAmount} ${"s_egp".tr()}", color: AppColors.redColor),
          Divider(height: AppConstants.height20(context), color: DsColor.border),
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
                Text("s_total".tr(), style: Styles.inter16500black(context)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${widget.orderData.totalAmount} ${"s_egp".tr()}",
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
        ? "s_one_product".tr()
        : count == 2
            ? "s_two_products".tr()
            : "i_x_products_73".tr(namedArgs: {"a": "${count}"});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          context,
          icon: Icons.inventory_2_rounded,
          title: "s_products".tr(),
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
        for (final group in _groupByShelf(context, items)) ...[
          _shelfHeader(context, group),
          SizedBox(height: AppConstants.height10(context)),
          for (final item in group.items) ...[
            OrderProductRow(item: item),
            SizedBox(height: AppConstants.height10(context)),
          ],
        ],
      ],
    );
  }

  /// Consecutive items of the same main + subcategory form one shelf group; the
  /// server already sorts items by the catalog's category order.
  List<_ShelfGroup> _groupByShelf(BuildContext context, List<OrderItems> items) {
    final lang = context.locale.languageCode;
    final groups = <_ShelfGroup>[];
    for (final item in items) {
      final key = '${item.mainCategory?.id ?? '-'}:${item.subCategory?.id ?? '-'}';
      if (groups.isNotEmpty && groups.last.key == key) {
        groups.last.items.add(item);
        continue;
      }
      final main = item.mainCategory?.label(lang) ?? '';
      groups.add(_ShelfGroup(
        key: key,
        main: main.isNotEmpty ? main : "s_no_category".tr(),
        sub: item.subCategory?.label(lang) ?? '',
        items: [item],
      ));
    }
    return groups;
  }

  Widget _shelfHeader(BuildContext context, _ShelfGroup group) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.width10(context),
        vertical: AppConstants.height5(context),
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF5F6FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: group.main,
                style: Styles.inter14600black(context),
                children: [
                  if (group.sub.isNotEmpty)
                    TextSpan(text: '  ›  ${group.sub}', style: Styles.inter14600gray(context)),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('${group.items.length}', style: Styles.inter14600gray(context)),
        ],
      ),
    );
  }

  // Same reason dialog as the awaiting-customer card, so both cancel paths send {"reason": ...}.
  void _confirmCancel(BuildContext context, CancelOrderCubit cubit) {
    showCancelOrderDialog(
      context: context,
      onConfirm: (reason) => cubit.cancelOrder(
        orderId: widget.orderData.id!,
        data: {"reason": reason},
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
                    color: DsColor.dangerBg,
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
              "s_full_order_return".tr(),
              textAlign: TextAlign.center,
              style: Styles.inter16500black(context),
            ),
            SizedBox(height: AppConstants.height10(context)),
            Text(
              "s_all_products_are_recorded_as_returne".tr(),
              style: Styles.inter14500black(
                context,
              ).copyWith(color: DsColor.text2),
            ),
            const SizedBox(height: 4),
            Text(
              "s_this_action_can_t_be_undone".tr(),
              style: Styles.inter14500black(
                context,
              ).copyWith(color: DsColor.danger),
            ),
            SizedBox(height: AppConstants.height20(context)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DsColor.danger,
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
                      "s_confirm_full_return".tr(),
                      style: Styles.inter16500black(
                        context,
                      ).copyWith(color: Colors.white),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    "s_cancel".tr(),
                    style: Styles.inter16500black(
                      context,
                    ).copyWith(color: DsColor.textMuted),
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
    return DsTopBar(title: "s_order_details".tr(), subtitle: DsFormat.orderNo(widget.orderData.orderNumber));
  }

  /// Status header in the status's own colour (light tint + dark text, readable),
  /// with the order timings underneath.
  Widget _buildStatusCard(BuildContext context) {
    final fg = AppConstants.getTextColor(currentStatus);
    final timingRows = _timingRows();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DsSpace.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DsRadius.lg),
        border: Border.all(color: fg.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: AppConstants.getStatusColor(currentStatus), borderRadius: BorderRadius.circular(DsRadius.md)),
                child: Icon(OrderStatusUi.icon(currentStatus), color: fg, size: 26),
              ),
              const SizedBox(width: DsSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("s_order_status_2".tr(), style: DsText.caption),
                    const SizedBox(height: 2),
                    Text(AppConstants.getStatusText(currentStatus), style: DsText.heading.copyWith(color: fg)),
                  ],
                ),
              ),
            ],
          ),
          if (timingRows.isNotEmpty) ...[
            const SizedBox(height: DsSpace.md),
            const Divider(height: 1, color: DsColor.divider),
            const SizedBox(height: DsSpace.md),
            Wrap(
              spacing: DsSpace.xl,
              runSpacing: DsSpace.sm,
              children: [
                for (final row in timingRows)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_timingIcon(row.key), size: 16, color: DsColor.textMuted),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(row.key, style: DsText.caption),
                          Text(row.value, style: DsText.bodyStrong),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ],
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
          _buildHeader(context),
          const SizedBox(height: DsSpace.sm),
          Divider(height: 1, color: DsColor.border),

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
                        SizedBox(height: AppConstants.height15(context)),
                        OrderMoneySection(
                          order: details,
                          onChanged: () => context.read<GetOrderDetailsCubit>().getOrderDetails(orderId: details.id!),
                        ),
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
                                  text: "s_cancel_order".tr(),
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
                                      // Moving an order forward is consequential: ask first.
                                      onPress: () async {
                                        final next = getNextStatus();
                                        final ok = await dsConfirm(
                                          context,
                                          title: getButtonText(),
                                          message: "ord_move_confirm".tr(namedArgs: {"s": AppConstants.getStatusText(next)}),
                                          confirmLabel: getButtonText(),
                                        );
                                        if (!ok || !context.mounted) return;
                                        context
                                            .read<ChangeOrderStatusCubit>()
                                            .changeOrderStatus(
                                              orderId: widget.orderData.id!,
                                              data: {"status": next},
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
                        color: DsColor.fill,
                        borderRadius: BorderRadius.circular(AppConstants.sp30(context) * 3),
                      ),
                      child: Text(
                        "awaiting_courier_update".tr(),
                        textAlign: TextAlign.center,
                        style: Styles.inter14500black(context).copyWith(color: DsColor.text2),
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
                                      text: "s_refund_the_order".tr(),
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

class _ShelfGroup {
  _ShelfGroup({required this.key, required this.main, required this.sub, required this.items});

  final String key;
  final String main;
  final String sub;
  final List<OrderItems> items;
}
