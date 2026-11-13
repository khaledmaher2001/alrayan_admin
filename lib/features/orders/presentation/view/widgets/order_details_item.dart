
import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OrderDetailsItem extends StatelessWidget {
  final List<OrderItems>? items;
  final int index;
  const OrderDetailsItem({super.key, required this.items, required this.index});


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        border: Border.all(color: const Color(0xffE3E7EC))
      ),
      child:IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch, // <- stretch children to the computed intrinsic height
          children: [
            ClipRRect(
              borderRadius: BorderRadiusDirectional.horizontal(
                start: Radius.circular(AppConstants.sp10(context)),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width*.28,
                height: double.infinity, // <- opt-in to take full IntrinsicHeight
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: AppConstants.width10(context),
                  vertical: AppConstants.width10(context),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusDirectional.horizontal(
                    start: Radius.circular(AppConstants.sp10(context)),
                  ),
                  color: const Color(0xffF5F6FA),
                ),
                alignment: Alignment.center,
                child: DefaultCachedNetworkImage(
                  imageWidth: MediaQuery.of(context).size.width*.28,
                  imageHeight: MediaQuery.of(context).size.width*.3,
                  imageUrl: items![index].productImages!.firstOrNull ??
                      "https://purepng.com/public/uploads/large/purepng.com-headphoneelectronicsheadset-headphone-941524670894v2zxb.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(width: AppConstants.width10(context)),
            // Right side can be any height; IntrinsicHeight takes the max of children
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.sp10(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // <- let content define its height
                  children: [
                    RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${items![index].quantity} ",
                            style: Styles.inter18500Black(context).copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                              fontSize: MediaQuery.of(context).size.height*.026
                            ),
                          ),
                          TextSpan(
                            text: items![index].productName ?? "",
                            style: Styles.inter14600black(context).copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppConstants.height10(context)),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                          "s_total_2".tr(),
                            style: Styles.inter14600black(context).copyWith(
                              color: AppColors.gray
                            ),
                          ),
                        ),
                        Text(
                          "${(items![index].unitPrice!*items![index].quantity!).toString()} ${"lE!".tr()}",
                          style: Styles.inter16400white(context).copyWith(color: Colors.black),
                        ),

                      ],
                    ),
                    SizedBox(height: AppConstants.height10(context)),
                    Container(
                      padding: EdgeInsets.all(AppConstants.sp10(context)),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.shade100,
                        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                            "s_unit".tr(),
                              style: Styles.inter14600black(context).copyWith(
                                color: AppColors.primaryColor
                              ),
                            ),
                          ),
                          Text(
                            items![index].unit??"",
                            style: Styles.inter16400white(context).copyWith(color: AppColors.primarySwatchColor),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
