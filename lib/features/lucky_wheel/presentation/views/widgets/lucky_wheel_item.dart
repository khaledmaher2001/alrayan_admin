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

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.width20(context),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                  color: AppColors.gray.withAlpha(25),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppConstants.sp10(context)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadiusDirectional.horizontal(
                            start: Radius.circular(AppConstants.sp10(context)),
                          ),
                          color: AppColors.primaryColor,
                        ),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: Styles.DIN24500(context),
                          ),
                        ),
                      ),
                      SizedBox(width: AppConstants.width10(context)),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.sp15(context)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(AppConstants.sp5(context)),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(AppConstants.sp5(context)),
                                        color: AppColors.primaryColor.withAlpha(25),
                                      ),
                                      child: Text(
                                        _rewardTypeAr[instance.type] ?? instance.type ?? '',
                                        style: Styles.inter14500black(context),
                                      ),
                                    ),
                                    if (instance.discountType != null) ...[
                                      SizedBox(height: AppConstants.height5(context)),
                                      Text(
                                        _discountTypeAr[instance.discountType] ??
                                            instance.discountType!,
                                        style: Styles.inter14600gray(context)
                                            .copyWith(color: Colors.black),
                                      ),
                                    ],
                                    if (instance.couponCode != null &&
                                        instance.couponCode!.isNotEmpty) ...[
                                      SizedBox(height: AppConstants.height5(context)),
                                      Text(
                                        instance.couponCode!,
                                        style: Styles.inter14600gray(context),
                                      ),
                                    ],
                                    SizedBox(height: AppConstants.height5(context)),
                                    Text(
                                      instance.displayText ?? '',
                                      style: Styles.inter14600gray(context),
                                    ),
                                    SizedBox(height: AppConstants.height10(context)),
                                    Row(
                                      children: [
                                        _ActionButton(
                                          icon: AssetData.edit,
                                          onTap: () => NavigationUtils.navigateTo(
                                            context: context,
                                            destinationScreen: CreateEditLuckyItemView(
                                              existingItem: instance,
                                              usedProbability: usedProbabilityWithoutThis,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: AppConstants.width10(context)),
                                        isDeletingThis
                                            ? const SizedBox(
                                                width: 32,
                                                height: 32,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              )
                                            : Opacity(
                                                opacity: canDelete ? 1.0 : 0.35,
                                                child: _ActionButton(
                                                  icon: AssetData.delete,
                                                  onTap: canDelete
                                                      ? () => _confirmDelete(context)
                                                      : null,
                                                ),
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'نسبة ظهوره',
                                    style: Styles.inter14600gray(context)
                                        .copyWith(color: Colors.black),
                                  ),
                                  SizedBox(height: AppConstants.height5(context)),
                                  Text(
                                    '%${((instance.probability is num ? (instance.probability as num).toDouble() : 0.0) * 100).toStringAsFixed(0)}',
                                    style: Styles.DIN20500(context)
                                        .copyWith(color: AppColors.primaryColor),
                                  ),
                                  SizedBox(height: AppConstants.height10(context)),
                                  Text(
                                    'تفعيل العنصر',
                                    style: Styles.inter14600gray(context)
                                        .copyWith(color: Colors.black),
                                  ),
                                  SizedBox(height: AppConstants.height5(context)),
                                  isTogglingThis
                                      ? const SizedBox(
                                          width: 32,
                                          height: 32,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : SmallSwitch(
                                          value: instance.isActive ?? false,
                                          onChanged: (v) {
                                            context
                                                .read<EditLuckyItemCubit>()
                                                .editLuckyItem(
                                              itemId: instance.id!,
                                              data: {'isActive': v},
                                            );
                                          },
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
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الجائزة'),
        content: Text('هل تريد حذف "${instance.displayText ?? ''}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<DeleteLuckyItemCubit>().deleteLuckyItem(
            itemId: instance.id!,
          );
    }
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, this.onTap});
  final String icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: EdgeInsets.all(AppConstants.sp5(context)),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          icon,
          width: MediaQuery.of(context).size.width * .06,
        ),
      ),
    );
  }
}
