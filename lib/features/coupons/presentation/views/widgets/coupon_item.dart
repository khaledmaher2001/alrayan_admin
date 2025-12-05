import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/features/coupons/data/models/coupons_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';
import '../view_model/delete_coupon/delete_coupon_cubit.dart';

class CouponItem extends StatefulWidget {
  const CouponItem({super.key, required this.couponData, required this.index});

  final Items couponData;
  final int index;

  @override
  State<CouponItem> createState() => _CouponItemState();
}

class _CouponItemState extends State<CouponItem> {
  final Map<String, Color> typeColors = {
    'free_shipping': const Color(0xFF22C55E), // green
    'product_specific': const Color(0xFFEF4444), // red
    'category_specific': const Color(0xFF6366F1), // indigo
    'fixed_amount': const Color(0xFF3B82F6), // blue
    'percentage': const Color(0xFFF97316), // orange
  };

  final Map<String, String> typeIcons = {
    'free_shipping': AssetData.shipping , // تأكد أن AssetData.truck موجود
    'product_specific': AssetData.product ,
    'category_specific': AssetData.department ,
    'fixed_amount': AssetData.fixed ,
    'percentage': AssetData.percentage ,
  };

  final Map<String, String> typeLabels = {
    'free_shipping': 'شحن مجاني',
    'product_specific': 'خصم منتج',
    'category_specific': 'خصم قسم',
    'fixed_amount': 'جنية',
    'percentage': 'نسبة خصم',
  };

  @override
  Widget build(BuildContext context) {
    final String type = widget.couponData.discountType ?? '';

    final Color leftBgColor = typeColors[type] ?? AppColors.primaryColor;
    final String iconAsset = typeIcons[type] ??AssetData.edit;
    final String label = typeLabels[type] ??AssetData.edit;

    String valueText = '';
    if (type == 'percentage') {
      final val = widget.couponData.discountValue;
      valueText = val != null ? '${val.toString()}%' : '-';
    } else if (type == 'fixed_amount') {
      final val = widget.couponData.discountValue;
      valueText = val != null ? '${val.toString()}' : '-';
    } else if (type == 'product_specific' || type == 'category_specific') {
      final val = widget.couponData.discountValue;
      valueText = val != null ? '${val.toString()}' : '-';
    } else if (type == 'free_shipping') {
      valueText = '';
    } else {
      final val = widget.couponData.discountValue;
      valueText = val != null ? val.toString() : '';
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1A000000),
              blurRadius: 4,
              spreadRadius: -2,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: const Color(0x1A000000),
              blurRadius: 6,
              spreadRadius: -1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: leftBgColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(AppConstants.sp10(context)),
                      bottomRight: Radius.circular(AppConstants.sp10(context)),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.sp20(context)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (iconAsset.isNotEmpty)
                          SvgPicture.asset(
                            iconAsset,
                            color: Colors.white,
                            width: MediaQuery.of(context).size.width * .12,
                          ),
                        if (valueText.isNotEmpty) ...[
                          SizedBox(height: AppConstants.height5(context)),
                          Text(
                            valueText,
                            style: Styles.inter24600black(context).copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                        SizedBox(height: AppConstants.height5(context)),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: Styles.inter14500black(context).copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.sp10(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.couponData.name != null
                            ? widget.couponData.name!.ar ?? "بدون اسم"
                            : "بدون اسم",
                        style: Styles.inter16500black(context),
                      ),
                      SizedBox(height: AppConstants.height5(context)),
                      Text(
                        widget.couponData.description != null
                            ? widget.couponData.description!.ar ?? "بدون وصف"
                            : "بدون وصف",
                        style: Styles.inter14500black(
                          context,
                        ).copyWith(color: const Color(0xff656565)),
                      ),
                      SizedBox(height: AppConstants.height10(context)),
                      Container(
                        padding: EdgeInsetsDirectional.symmetric(
                          horizontal: AppConstants.width10(context) - 2,
                          vertical: AppConstants.height10(context) - 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffF3F4F6),
                          borderRadius: BorderRadius.circular(
                            AppConstants.sp5(context),
                          ),
                          border: Border.all(color: const Color(0xffD1D5DC)),
                        ),
                        child: Text(
                          widget.couponData.code ?? "",
                          style: Styles.inter16500black(
                            context,
                          ).copyWith(color: AppColors.primaryColor),
                        ),
                      ),
                      SizedBox(height: AppConstants.height5(context)),
                      Text(
                        "${"متاح حتي".tr()} : ${widget.couponData.validTo != null && widget.couponData.validTo!.isNotEmpty ? DateFormat("yyyy-MM-dd").format(DateTime.parse(widget.couponData.validTo!)) : '-'}",
                        style: Styles.inter16500black(context),
                      ),
                      if (widget.couponData.discountType == "percentage") ...[
                        SizedBox(height: AppConstants.height5(context)),
                        Text(
                          "${widget.couponData.discountValue ?? ""}${"% خصم حتي ".tr()} ${widget.couponData.maxDiscountAmount ?? ""} ${"جنية".tr()}",
                          style: Styles.inter16500black(context),
                        ),

                      ],
                      SizedBox(height: AppConstants.height10(context),),
                      Text(
                        "${"الحد الأدني للطلب".tr()} : ${widget.couponData.minOrderAmount ?? '-'}",
                        style: Styles.inter16500black(context),
                      ),
                      SizedBox(height: AppConstants.height10(context)),
                      Row(
                        children: [
                          Expanded(
                            child:
                            BlocBuilder<DeleteCouponCubit, DeleteCouponState>(
                              builder: (context, state) {
                                return state is DeleteCouponLoadingState &&
                                    context
                                        .read<DeleteCouponCubit>()
                                        .selectedIndex ==
                                        widget.index
                                    ? Center(
                                  child: SizedBox(
                                    width: AppConstants.width20(
                                      context,
                                    ),
                                    height: AppConstants.width20(
                                      context,
                                    ),
                                    child:
                                    const CircularProgressIndicator(),
                                  ),
                                )
                                    : DefaultButton(
                                  height: AppConstants.height10(
                                    context,
                                  ),
                                  icon: SvgPicture.asset(
                                    AssetData.delete,
                                    color: Colors.white,
                                  ),
                                  borderRadius: AppConstants.sp10(
                                    context,
                                  ),
                                  onPress: () {
                                    setState(() {
                                      context
                                          .read<DeleteCouponCubit>()
                                          .selectedIndex = widget.index;
                                    });
                                    context
                                        .read<DeleteCouponCubit>()
                                        .deleteCoupon(
                                      couponId: widget.couponData.id!,
                                    );
                                  },
                                  text: 'حذف',
                                );
                              },
                            ),
                          ),
                          SizedBox(width: AppConstants.width20(context)),
                          Expanded(
                            child:
                            DefaultButton(
                              height: AppConstants.height10(
                                context,
                              ),
                              backgroundColor: const Color(0xff1976D2),
                              icon: SvgPicture.asset(
                                AssetData.edit,
                                color: Colors.white,
                              ),
                              borderRadius: AppConstants.sp10(
                                context,
                              ),
                              onPress: () {

                              },
                              text: 'تعديل',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
