import 'package:alrayan_admin/features/coupons/data/models/coupons_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/shared_widgets/default_cached_network_image.dart';
import '../../../../../core/shared_widgets/toast.dart';
import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/navigation_utility.dart';
import '../../../../../core/utils/text_styles/styles.dart';
import '../create_coupon_view.dart';
import '../view_model/delete_coupon/delete_coupon_cubit.dart';

const List<String> _arabicMonths = [
  "يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو",
  "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر",
];

class CouponItem extends StatefulWidget {
  const CouponItem({super.key, required this.couponData, required this.index});

  final Items couponData;
  final int index;

  @override
  State<CouponItem> createState() => _CouponItemState();
}

class _CouponItemState extends State<CouponItem> {
  final Map<String, String> typeIcons = {
    'free_shipping': AssetData.shipping,
    'product_specific': AssetData.product,
    'category_specific': AssetData.department,
    'fixed_amount': AssetData.fixed,
    'percentage': AssetData.percentage,
  };

  final Map<String, String> typeLabels = {
    'free_shipping': 'شحن مجاني',
    'product_specific': 'خصم منتج',
    'category_specific': 'خصم قسم',
    'fixed_amount': 'نسبة ثابتة',
    'percentage': 'نسبة مئوية',
  };

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "تأكيد الحذف",
            style: Styles.inter24600black(context),
          ),
          content: Text(
            "هل أنت متأكد أنك تريد حذف الكوبون؟",
            style: Styles.font18500Grey900(context),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.sp10(dialogContext),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(
                "إلغاء",
                style: Styles.inter18500Black(context),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redColor,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(
                "حذف",
                style: Styles.inter16400white(context),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      context.read<DeleteCouponCubit>().selectedIndex = widget.index;
      context.read<DeleteCouponCubit>().deleteCoupon(
        couponId: widget.couponData.id!,
      );
    }
  }

  void _copyCode() {
    final code = widget.couponData.code ?? '';
    if (code.isEmpty) return;
    Clipboard.setData(ClipboardData(text: code));
    toast(text: "تم نسخ كود الكوبون", color: Colors.green);
  }

  bool get _isExpired {
    final validTo = DateTime.tryParse(widget.couponData.validTo ?? "");
    if (validTo == null) return false;
    return validTo.isBefore(DateTime.now());
  }

  String _formatDate(String? iso) {
    final date = DateTime.tryParse(iso ?? "");
    if (date == null) return '-';
    return "${date.day} ${_arabicMonths[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final String type = widget.couponData.discountType ?? '';
    final isExpired = _isExpired;

    final String iconAsset = typeIcons[type] ?? AssetData.edit;
    final String label = typeLabels[type] ?? AssetData.edit;

    String valueText = '';
    if (type == 'percentage') {
      final val = widget.couponData.discountValue;
      valueText = val != null ? '${val.toString()}%' : '-';
    } else if (type == 'fixed_amount') {
      final val = widget.couponData.discountValue;
      valueText = val != null ? '${val.toString()} جنية' : '-';
    } else if (type == 'product_specific' || type == 'category_specific') {
      final val = widget.couponData.discountValue;
      valueText = val != null ? '${val.toString()}%' : '-';
    } else if (type == 'free_shipping') {
      valueText = 'خصم قيمة الشحن';
    } else {
      final val = widget.couponData.discountValue;
      valueText = val != null ? val.toString() : '';
    }

    final title = widget.couponData.name?.ar ?? widget.couponData.name?.en ?? label;
    final description = widget.couponData.description?.ar ?? widget.couponData.description?.en ?? '';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
      child: Container(
        padding: EdgeInsets.all(AppConstants.sp15(context)),
        decoration: BoxDecoration(
          color: isExpired ? Colors.red.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          border: isExpired ? Border.all(color: Colors.red.shade200) : null,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1a000000),
              blurRadius: 6,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status pills + code chip + actions menu.
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: AppConstants.width10(context) - 2,
                            vertical: AppConstants.height10(context) - 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gray.withOpacity(.15),
                            borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  widget.couponData.code ?? "",
                                  overflow: TextOverflow.ellipsis,
                                  style: Styles.inter14500black(context).copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              SizedBox(width: AppConstants.width5(context)),
                              InkWell(
                                onTap: _copyCode,
                                child: Icon(Icons.copy_rounded, size: 14, color: AppColors.gray),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: AppConstants.width10(context)),
                      if (isExpired)
                        _StatusPill(
                          label: "منتهي",
                          icon: Icons.event_busy,
                          color: Colors.red.shade800,
                        )
                      else
                        _StatusPill(
                          label: "نشط",
                          icon: Icons.check_circle_outline,
                          color: const Color(0xFF1C9A6C),
                        ),
                      if (widget.couponData.isHidden == true) ...[
                        SizedBox(width: AppConstants.width5(context)),
                        _StatusPill(
                          label: "مخفي",
                          iconAsset: AssetData.viewOff,
                          color: Colors.orange.shade800,
                        ),
                      ],

                    ],
                  ),
                ),
                SizedBox(width: AppConstants.width10(context)),
                BlocBuilder<DeleteCouponCubit, DeleteCouponState>(
                  builder: (context, state) {
                    final isDeleting =
                        state is DeleteCouponLoadingState &&
                            context.read<DeleteCouponCubit>().selectedIndex == widget.index;

                    if (isDeleting) {
                      return Padding(
                        padding: EdgeInsets.all(AppConstants.sp10(context)),
                        child: SizedBox(
                          width: AppConstants.width15(context),
                          height: AppConstants.width15(context),
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    return PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.black87),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          NavigationUtils.navigateTo(
                            context: context,
                            destinationScreen: CreateCouponView(editingCoupon: widget.couponData),
                          );
                        } else if (value == 'delete') {
                          await _showDeleteConfirmationDialog(context);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              SvgPicture.asset(AssetData.edit, width: AppConstants.width15(context)),
                              SizedBox(width: AppConstants.width10(context)),
                              Text("تعديل", style: Styles.inter14500black(context)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              SvgPicture.asset(AssetData.delete, width: AppConstants.width15(context)),
                              SizedBox(width: AppConstants.width10(context)),
                              Text("حذف", style: Styles.inter14500black(context).copyWith(color: AppColors.redColor)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: AppConstants.height10(context)),
            Text(
              title,
              style: Styles.inter16500black(context).copyWith(fontWeight: FontWeight.w700),
            ),
            if (description.isNotEmpty) ...[
              SizedBox(height: AppConstants.height5(context) / 2),
              Text(description, style: Styles.inter14600gray(context)),
            ],
            SizedBox(height: AppConstants.height15(context)),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: AppConstants.width10(context) - 2,
                      vertical: AppConstants.height10(context) - 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray.withOpacity(.2),
                      borderRadius: BorderRadius.circular(
                        AppConstants.sp5(context),
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          widget.couponData.isSplitCoupon!
                              ? AssetData.split
                              : iconAsset,
                          width: MediaQuery.of(context).size.width * .06,
                        ),
                        SizedBox(width: AppConstants.width10(context)),
                        Flexible(
                          child: Text(
                            widget.couponData.isSplitCoupon!
                                ? "كوبون مجزئ"
                                : label,
                            overflow: TextOverflow.ellipsis,
                            style: Styles.inter14500black(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: AppConstants.width20(context)),
                Expanded(
                  child: Container(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: AppConstants.width10(context) - 2,
                      vertical: AppConstants.height10(context) - 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray.withOpacity(.2),
                      borderRadius: BorderRadius.circular(
                        AppConstants.sp5(context),
                      ),
                    ),
                    child: Text(
                      valueText,
                      style: Styles.inter14500black(context),
                    ),
                  ),
                ),
              ],
            ),
            if (widget.couponData.isSplitCoupon!) ...[
              SizedBox(height: AppConstants.height10(context)),
              Text(
                widget.couponData.discountType == "fixed_amount"
                    ? "خصم ${widget.couponData.splitValue} جنية للمرة الواحدة"
                    : "خصم ${widget.couponData.splitValue}% للمرة الواحدة",
                style: Styles.inter14500black(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: AppConstants.height5(context)),
              Text(
                "هذا الكود يتم استخدامة علي ${widget.couponData.totalSplits} مرات",
                style: Styles.inter16500black(context).copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray,
                ),
              ),
            ],
            if (widget.couponData.discountType == "category_specific") ...[
              SizedBox(height: AppConstants.height10(context)),
              Container(
                padding: EdgeInsets.all(AppConstants.sp10(context)),
                decoration: BoxDecoration(
                  color: AppColors.gray.withOpacity(.2),
                  borderRadius: BorderRadius.circular(
                    AppConstants.sp5(context),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppConstants.height5(context)),
                    Row(
                      children: [
                        Text(
                          "يطبق على الفئات الاتية",
                          style: Styles.inter14500black(context),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.height10(context)),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .05,
                      child: ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => Container(
                          padding: EdgeInsets.all(AppConstants.sp10(context)),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              AppConstants.sp5(context),
                            ),
                          ),
                          child: Text(
                            widget.couponData.categories![index].name ?? "",
                            style: Styles.inter14500black(context),
                          ),
                        ),
                        separatorBuilder: (context, index) =>
                            SizedBox(width: AppConstants.width10(context)),
                        itemCount: widget.couponData.categories?.length ?? 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (widget.couponData.discountType == "product_specific") ...[
              SizedBox(height: AppConstants.height10(context)),
              Container(
                padding: EdgeInsets.all(AppConstants.sp10(context)),
                decoration: BoxDecoration(
                  color: AppColors.gray.withOpacity(.2),
                  borderRadius: BorderRadius.circular(
                    AppConstants.sp5(context),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppConstants.height5(context)),
                    Row(
                      children: [
                        Text(
                          "يطبق على المنتجات الاتية",
                          style: Styles.inter14500black(context),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.height10(context)),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .13,
                      child: ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => Container(
                          padding: EdgeInsets.all(AppConstants.sp10(context)),
                          decoration: BoxDecoration(
                            color: AppColors.gray.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(
                              AppConstants.sp5(context),
                            ),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.sp10(context),
                                ),
                                child: DefaultCachedNetworkImage(
                                  imageUrl:
                                  widget.couponData.products![index].images!.first.attach ?? "",
                                  imageHeight:
                                  MediaQuery.of(context).size.height * .05,
                                  imageWidth:
                                  MediaQuery.of(context).size.height * .05,
                                ),
                              ),
                              Text(
                                widget.couponData.products![index].name ?? "",
                                style: Styles.inter14500black(context),
                              ),
                              Text(
                                widget.couponData.products![index].price.toString(),
                                style: Styles.inter16500black(
                                  context,
                                ).copyWith(color: AppColors.primaryColor),
                              ),
                            ],
                          ),
                        ),
                        separatorBuilder: (context, index) =>
                            SizedBox(width: AppConstants.width10(context)),
                        itemCount: widget.couponData.products?.length ?? 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: AppConstants.height15(context)),
            Divider(color: AppColors.gray.withOpacity(.2), height: 1),
            SizedBox(height: AppConstants.height10(context)),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("تم الاستخدام", style: Styles.inter10400grey(context)),
                      SizedBox(height: AppConstants.height5(context) / 2),
                      Text(
                        "${widget.couponData.usedCount ?? 0} مرة",
                        style: Styles.inter14500black(context).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("تاريخ انتهاء الكوبون", style: Styles.inter10400grey(context)),
                      SizedBox(height: AppConstants.height5(context) / 2),
                      Text(
                        _formatDate(widget.couponData.validTo),
                        style: Styles.inter14500black(context).copyWith(
                          color: isExpired ? Colors.red.shade800 : null,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color, this.icon, this.iconAsset});

  final String label;
  final Color color;
  final IconData? icon;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: AppConstants.width10(context) - 2,
        vertical: AppConstants.height10(context) - 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: AppConstants.width15(context), color: color),
          if (iconAsset != null)
            SvgPicture.asset(
              iconAsset!,
              width: AppConstants.width15(context),
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          SizedBox(width: AppConstants.width5(context)),
          Text(
            label,
            style: Styles.inter12500Black(context).copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
