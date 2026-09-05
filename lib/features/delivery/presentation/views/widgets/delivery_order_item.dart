import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/delivery_order_details_view.dart';
import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

/// المراحل الخمس المدعومة لتوصيل الطلب، بأسمائها العربية الرسمية المطلوبة.
String deliveryStageLabel(String? stage) {
  switch (stage) {
    case 'assigned':
      return 'delivery_stage_assigned'.tr();
    case 'arrived_at_store':
      return 'delivery_stage_arrived_at_store'.tr();
    case 'picked_up':
      return 'delivery_stage_picked_up'.tr();
    case 'on_the_way':
      return 'delivery_stage_on_the_way'.tr();
    case 'delivered':
      return 'delivery_stage_delivered'.tr();
    default:
      return 'delivery_stage_none'.tr();
  }
}

class DeliveryOrderItem extends StatelessWidget {
  const DeliveryOrderItem({super.key, required this.order});

  final Items order;

  @override
  Widget build(BuildContext context) {
    final courierName = order.deliveryUser?.fullName;
    return GestureDetector(
      onTap: () => NavigationUtils.navigateTo(
        context: context,
        destinationScreen: DeliveryOrderDetailsView(orderId: order.id!),
      ),
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppConstants.width15(context),
          vertical: AppConstants.height15(context),
        ),
        margin: EdgeInsetsDirectional.symmetric(
          horizontal: AppConstants.width15(context),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          color: Colors.grey.shade200,
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6),
          ],
        ),
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.orderNumber ?? '-',
                      style: Styles.inter16500black(context),
                    ),
                  ),
                  Text(
                    _formatDate(order.createdAt),
                    style: Styles.inter10400grey(context),
                  ),
                ],
              ),
              SizedBox(height: AppConstants.height5(context)),
              if ((order.shippingAddress?.user?.fullName ?? '')
                  .isNotEmpty)
                Text(
                  order.shippingAddress!.user!.fullName!,
                  style: Styles.inter14500black(context),
                ),
              if ((order.shippingAddress?.phone1 ?? '').isNotEmpty)
                Text(
                  order.shippingAddress!.phone1!,
                  style: Styles.inter10400grey(context),
                ),
              SizedBox(height: AppConstants.height5(context)),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _Badge(
                  text: AppConstants.getStatusText(order.status),
                  background: AppConstants.getStatusColor(order.status),
                  textColor: AppConstants.getTextColor(order.status),
                ),
              ),
              SizedBox(height: AppConstants.height10(context)),
              Divider(color: Colors.grey.shade100, height: 1),
              SizedBox(height: AppConstants.height10(context)),
              Row(
                children: [
                  Text(
                    "${order.totalAmount ?? '-'} ج.م",
                    style: Styles.inter16500black(
                      context,
                    ).copyWith(color: AppColors.primaryColor),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.person_outline,
                    size: AppConstants.sp15(context),
                    color: Colors.grey.shade500,
                  ),
                  SizedBox(width: AppConstants.width5(context) / 2),
                  Text(
                    courierName != null
                        ? "${"courier".tr()}: $courierName"
                        : "unassigned_order".tr(),
                    style: Styles.inter12500Black(
                      context,
                    ).copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return '';
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.background,
    required this.textColor,
  });

  final String text;
  final Color background;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.width10(context) / 1.5,
        vertical: AppConstants.height5(context) / 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
      ),
      child: Text(
        text,
        style: Styles.inter10400grey(context).copyWith(color: textColor),
      ),
    );
  }
}
