import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OrderProductRow extends StatelessWidget {
  const OrderProductRow({super.key, required this.item});

  final OrderItems item;

  @override
  Widget build(BuildContext context) {
    final total = (item.unitPrice ?? 0) * (item.quantity ?? 1);

    return Container(
      padding: EdgeInsets.all(AppConstants.sp10(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        border: Border.all(color: const Color(0xffE3E7EC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
            child: Container(
              color: const Color(0xffF5F6FA),
              child: DefaultCachedNetworkImage(
                imageUrl: item.productImages?.firstOrNull,
                imageWidth: AppConstants.width50(context),
                imageHeight: AppConstants.width50(context),
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: AppConstants.width10(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.inter16500black(context),
                ),
                SizedBox(height: AppConstants.height5(context)),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.width10(context),
                        vertical: AppConstants.height5(context) / 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffF5F6FA),
                        borderRadius: BorderRadius.circular(AppConstants.sp5(context)),
                      ),
                      child: Text(
                        "${item.quantity ?? 1}",
                        style: Styles.inter18500Black(context).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(width: AppConstants.width10(context)),
                    Expanded(
                      child: Text(
                        "i_unit".tr(namedArgs: {"a": item.unit ?? ""}),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Styles.inter14500black(context).copyWith(color: const Color(0xff9CA4AB)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppConstants.height5(context)),
                Text(
                  "${total.toString()} ${"lE!".tr()}",
                  style: Styles.inter16500black(context).copyWith(color: AppColors.primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
