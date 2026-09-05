import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/lucky_wheel/data/models/lucky_wheel_model.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/delete_lucky_item/delete_lucky_item_cubit.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/edit_lucky_item/edit_lucky_item_cubit.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/views/create_edit_lucky_item_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';
import 'custom_switch.dart';

const int _kMinItems = 2;

const _rewardTypeAr = <String, String>{
  'no_reward': 'بدون جائزة',
  'free_shipping': 'شحن مجاني',
  'discount_coupon': 'كوبون خصم',
  'discount_product': 'خصم على منتج',
};

const _discountTypeAr = <String, String>{
  'percentage': 'نسبة مئوية',
  'fixed_amount': 'نسبة ثابتة',
  'product_specific': 'خصم على منتج',
  'category_specific': 'خصم على قسم',
};

class LuckyWheelItem extends StatelessWidget {
  const LuckyWheelItem({
    super.key,
    required this.instance,
    required this.index,
    required this.itemCount,
    required this.usedProbabilityWithoutThis,
  });

  final Rewards instance;
  final int index;
  final int itemCount;
  final double usedProbabilityWithoutThis;

  bool get isExpired {
    final expiresAt = instance.expiresAt;
    if (expiresAt == null || expiresAt.isEmpty) return false;
    final date = DateTime.tryParse(expiresAt);
    if (date == null) return false;
    return date.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditLuckyItemCubit, EditLuckyItemState>(
      builder: (context, editState) {
        return BlocBuilder<DeleteLuckyItemCubit, DeleteLuckyItemState>(
          builder: (context, deleteState) {
            final isTogglingThis = editState is EditLuckyItemLoadingState &&
                context.read<EditLuckyItemCubit>().editingItemId == instance.id;
            final isDeletingThis = deleteState is DeleteLuckyItemLoadingState &&
                context.read<DeleteLuckyItemCubit>().deletingItemId == instance.id;
            final canDelete = itemCount > _kMinItems;
            final probabilityPercent =
                ((instance.probability is num ? (instance.probability as num).toDouble() : 0.0) * 100)
                    .toStringAsFixed(0);

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.width20(context),
              ),
              child: Container(
                padding: EdgeInsets.all(AppConstants.sp15(context)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 3),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: AppConstants.width20(context) * 1.4,
                      height: AppConstants.width20(context) * 1.4,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryColor, width: 1.5),
                      ),
                      child: Text(
                        "${index + 1}",
                        style: Styles.inter14600gray(context).copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: AppConstants.width10(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            instance.displayText?.isNotEmpty == true
                                ? instance.displayText!
                                : (_rewardTypeAr[instance.type] ?? instance.type ?? ''),
                            style: Styles.inter16500black(context).copyWith(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: AppConstants.height5(context)),
                          Wrap(
                            spacing: AppConstants.width5(context),
                            runSpacing: AppConstants.height5(context) / 2,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppConstants.width10(context) - 2,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withAlpha(25),
                                  borderRadius: BorderRadius.circular(AppConstants.sp5(context)),
                                ),
                                child: Text(
                                  _rewardTypeAr[instance.type] ?? instance.type ?? '',
                                  style: Styles.inter10400grey(context).copyWith(color: Colors.black),
                                ),
                              ),
                              if (instance.discountType != null)
                                Text(
                                  _discountTypeAr[instance.discountType] ?? instance.discountType!,
                                  style: Styles.inter10400grey(context),
                                ),
                              if (instance.couponCode != null && instance.couponCode!.isNotEmpty)
                                Text(instance.couponCode!, style: Styles.inter10400grey(context)),
                            ],
                          ),
                          if (isExpired) ...[
                            SizedBox(height: AppConstants.height5(context)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppConstants.sp5(context),
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withAlpha(25),
                                borderRadius: BorderRadius.circular(AppConstants.sp5(context)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.error_outline, size: 14, color: Colors.red),
                                  SizedBox(width: AppConstants.width5(context)),
                                  Text(
                                    'انتهت صلاحية هذا العنصر',
                                    style: Styles.inter14600gray(context).copyWith(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          SizedBox(height: AppConstants.height5(context)),
                          Text(
                            'نسبة الظهور $probabilityPercent%',
                            style: Styles.inter12500Black(context).copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppConstants.width10(context)),
                    isTogglingThis
                        ? const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : SmallSwitch(
                      value: instance.isActive ?? false,
                      onChanged: (v) {
                        context.read<EditLuckyItemCubit>().editLuckyItem(
                          itemId: instance.id!,
                          data: {'isActive': v},
                        );
                      },
                    ),

                    isDeletingThis
                        ? Padding(
                            padding: EdgeInsets.all(AppConstants.sp10(context)),
                            child: SizedBox(
                              width: AppConstants.width15(context),
                              height: AppConstants.width15(context),
                              child: const CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.black87),
                            onSelected: (value) {
                              if (value == 'edit') {
                                NavigationUtils.navigateTo(
                                  context: context,
                                  destinationScreen: CreateEditLuckyItemView(
                                    existingItem: instance,
                                    usedProbability: usedProbabilityWithoutThis,
                                  ),
                                );
                              } else if (value == 'delete' && canDelete) {
                                _confirmDelete(context);
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
                                enabled: canDelete,
                                child: Row(
                                  children: [
                                    Opacity(
                                      opacity: canDelete ? 1 : .4,
                                      child: SvgPicture.asset(AssetData.delete, width: AppConstants.width15(context)),
                                    ),
                                    SizedBox(width: AppConstants.width10(context)),
                                    Text(
                                      canDelete ? "حذف" : "حذف (الحد الأدنى $_kMinItems جوائز)",
                                      style: Styles.inter14500black(context).copyWith(
                                        color: canDelete ? AppColors.redColor : Colors.grey,
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
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
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
            "هل أنت متأكد أنك تريد حذف الجائزة؟",
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
    if (shouldDelete == true && context.mounted) {
      context.read<DeleteLuckyItemCubit>().deleteLuckyItem(
            itemId: instance.id!,
          );
    }
  }
}
