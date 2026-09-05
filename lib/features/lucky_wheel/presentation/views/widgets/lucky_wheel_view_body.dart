import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/shared_widgets/shimmer_helpers.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/delete_lucky_item/delete_lucky_item_cubit.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/edit_lucky_item/edit_lucky_item_cubit.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/get_lucky_wheel_items/get_lucky_wheel_items_cubit.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/views/create_edit_lucky_item_view.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/views/widgets/lucky_wheel_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const int _kMaxItems = 6;
const int _kMinItems = 2;

class LuckyWheelViewBody extends StatelessWidget {
  const LuckyWheelViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GetLuckyWheelItemsCubit, GetLuckyWheelItemsState>(
      listener: (context, state) {
        if (state is GetLuckyWheelToggleErrorState) {
          cherryToast(context: context, text: state.error, isSuccess: false);
        }
      },
      builder: (context, state) {
        final cubit = context.read<GetLuckyWheelItemsCubit>();
        final rewards = cubit.luckyWheelList;
        final isWheelActive = cubit.luckyWheelModel?.data?.isActive ?? false;
        final probPercent = (cubit.totalProbability * 100).clamp(0.0, 100.0);
        final isTogglingWheel = state is GetLuckyWheelToggleLoadingState;
        final hasExpiredItems = rewards.any((r) {
          final date = r.expiresAt == null || r.expiresAt!.isEmpty
              ? null
              : DateTime.tryParse(r.expiresAt!);
          return date != null && date.isBefore(DateTime.now());
        });

        return MultiBlocListener(
          listeners: [
            BlocListener<EditLuckyItemCubit, EditLuckyItemState>(
              listener: (ctx, editState) {
                if (editState is EditLuckyItemSuccessState) {
                  ctx.read<GetLuckyWheelItemsCubit>().getLuckyWheelItems(withLoading: false);
                } else if (editState is EditLuckyItemErrorState) {
                  cherryToast(context: ctx, text: editState.error, isSuccess: false);
                }
              },
            ),
            BlocListener<DeleteLuckyItemCubit, DeleteLuckyItemState>(
              listener: (ctx, deleteState) {
                if (deleteState is DeleteLuckyItemSuccessState) {
                  cherryToast(context: ctx, text: deleteState.message);
                  ctx.read<GetLuckyWheelItemsCubit>().getLuckyWheelItems(withLoading: false);
                } else if (deleteState is DeleteLuckyItemErrorState) {
                  cherryToast(context: ctx, text: deleteState.error, isSuccess: false);
                }
              },
            ),
          ],
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: AppConstants.height20(context)),
                CustomAppBar(
                  title: 'عجلة الحظ',
                  hasBack: true,
                  textColor: Colors.black,
                  withNotifications: false,
                ),
                SizedBox(height: AppConstants.height15(context)),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.width20(context)),
                  child: _WheelStatusBar(
                    isActive: isWheelActive,
                    isToggling: isTogglingWheel,
                    itemCount: rewards.length,
                    activeItemCount: rewards.where((r) => r.isActive == true).length,
                    probPercent: probPercent,
                    hasExpiredItems: hasExpiredItems,
                    onToggle: cubit.toggleSpinWheel,
                  ),
                ),
                SizedBox(height: AppConstants.height20(context)),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.width20(context)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'عناصر العجلة',
                          style: Styles.inter16500black(context).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      _buildAddButton(context, cubit),
                    ],
                  ),
                ),
                SizedBox(height: AppConstants.height10(context)),
                Expanded(child: _buildBody(context, state, cubit)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    GetLuckyWheelItemsState state,
    GetLuckyWheelItemsCubit cubit,
  ) {
    if (state is GetLuckyWheelItemsLoadingState) {
      return const _WheelItemsShimmer();
    }

    if (state is GetLuckyWheelItemsErrorState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            SizedBox(height: AppConstants.height10(context)),
            Text('حدث خطأ في التحميل', style: Styles.inter16500black(context)),
            SizedBox(height: AppConstants.height10(context)),
            ElevatedButton.icon(
              onPressed: cubit.getLuckyWheelItems,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    // success / toggle loading / toggle error — كلهم يعرضوا القائمة
    final rewards = cubit.luckyWheelList;

    if (rewards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.casino_outlined, size: 64, color: Colors.grey.shade400),
            SizedBox(height: AppConstants.height10(context)),
            Text(
              'لا توجد جوائز حتى الآن',
              style: Styles.inter16500black(context).copyWith(color: Colors.grey),
            ),
            SizedBox(height: AppConstants.height5(context)),
            Text(
              'أضف $_kMinItems جوائز على الأقل لتفعيل العجلة',
              style: Styles.inter14500black(context).copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: cubit.getLuckyWheelItems,
      child: ListView.separated(
        padding: EdgeInsets.only(
          top: AppConstants.height5(context),
          bottom: AppConstants.height20(context),
        ),
        itemCount: rewards.length,
        separatorBuilder: (context, i) =>
            SizedBox(height: AppConstants.height15(context)),
        itemBuilder: (context, index) {
          final item = rewards[index];
          final usedWithoutThis = cubit.luckyWheelList
              .where((e) => e.id != item.id)
              .fold(0.0, (sum, e) {
            final p = (e.probability is num)
                ? (e.probability as num).toDouble()
                : 0.0;
            return sum + p;
          });
          return LuckyWheelItem(
            instance: item,
            index: index,
            itemCount: rewards.length,
            usedProbabilityWithoutThis: usedWithoutThis,
          );
        },
      ),
    );
  }

  Widget _buildAddButton(
      BuildContext context, GetLuckyWheelItemsCubit cubit) {
    final count = cubit.luckyWheelList.length;
    final probFull = cubit.totalProbability >= 0.9999;
    final canAdd = count < _kMaxItems && !probFull;
    final isLastSlot = count == _kMaxItems - 1;

    String label;
    if (count >= _kMaxItems) {
      label = 'وصلت للحد الأقصى';
    } else if (probFull) {
      label = 'الاحتمالية مكتملة';
    } else {
      label = 'إضافة عنصر';
    }

    return InkWell(
      onTap: canAdd
          ? () => NavigationUtils.navigateTo(
                context: context,
                destinationScreen: CreateEditLuckyItemView(
                  usedProbability: cubit.totalProbability,
                  autoFillProbability: isLastSlot,
                ),
              )
          : null,
      borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.width15(context),
          vertical: AppConstants.height10(context) - 2,
        ),
        decoration: BoxDecoration(
          color: canAdd ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
          border: Border.all(
            color: canAdd ? AppColors.secondaryColor : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              canAdd ? Icons.add : Icons.lock_outline,
              size: 16,
              color: canAdd ? AppColors.secondaryColor : Colors.grey.shade500,
            ),
            SizedBox(width: AppConstants.width5(context)),
            Text(
              label,
              style: Styles.inter14500black(context).copyWith(
                color: canAdd ? AppColors.secondaryColor : Colors.grey.shade500,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WheelStatusBar extends StatelessWidget {
  const _WheelStatusBar({
    required this.isActive,
    required this.isToggling,
    required this.itemCount,
    required this.activeItemCount,
    required this.probPercent,
    required this.hasExpiredItems,
    required this.onToggle,
  });

  final bool isActive;
  final bool isToggling;
  final int itemCount;
  final int activeItemCount;
  final double probPercent;
  final bool hasExpiredItems;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isExact = (probPercent - 100).abs() < 0.5;
    final probColor = isExact
        ? const Color(0xFF1C9A6C)
        : probPercent > 100
            ? Colors.red
            : Colors.orange;
    final canToggleOn = isExact && !hasExpiredItems;
    final canToggle = isActive ? true : canToggleOn;

    return Container(
      padding: EdgeInsets.all(AppConstants.sp15(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 3),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isToggling
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Switch(
                      value: isActive,
                      onChanged: canToggle ? (_) => onToggle() : null,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.primaryColor,
                    ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('حالة العجلة', style: Styles.inter16500black(context).copyWith(fontWeight: FontWeight.w700)),
                  SizedBox(height: AppConstants.height5(context)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.width10(context),
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: (isActive ? const Color(0xFF1C9A6C) : Colors.grey).withOpacity(.12),
                      borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
                    ),
                    child: Text(
                      isActive ? 'نشطة' : 'متوقفة',
                      style: Styles.inter12500Black(context).copyWith(
                        color: isActive ? const Color(0xFF1C9A6C) : Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (hasExpiredItems || !isExact) ...[
            SizedBox(height: AppConstants.height5(context)),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                hasExpiredItems ? 'يوجد جوائز منتهية الصلاحية' : 'يجب أن تكتمل الاحتمالية 100%',
                style: Styles.inter10400grey(context).copyWith(
                  color: hasExpiredItems ? AppColors.primaryColor : Colors.orange.shade700,
                ),
              ),
            ),
          ],
          SizedBox(height: AppConstants.height15(context)),
          Divider(color: Colors.grey.shade200, height: 1),
          SizedBox(height: AppConstants.height15(context)),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('مجموع الاحتمالات', style: Styles.inter10400grey(context)),
                    SizedBox(height: AppConstants.height5(context) / 2),
                    Text(
                      '${probPercent.toStringAsFixed(0)}%',
                      style: Styles.inter16500black(context).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: AppConstants.height20(context) * 1.5,
                child: VerticalDivider(color: Colors.grey.shade200, width: 1),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('الجوائز المفعلة', style: Styles.inter10400grey(context)),
                    SizedBox(height: AppConstants.height5(context) / 2),
                    Text(
                      '$activeItemCount من $itemCount',
                      style: Styles.inter16500black(context).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height10(context)),
          Row(
            children: [
              Text(
                '${probPercent.toStringAsFixed(0)}%',
                style: Styles.inter12500Black(context).copyWith(color: probColor, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: AppConstants.width10(context)),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
                  child: LinearProgressIndicator(
                    value: (probPercent / 100).clamp(0.0, 1.0),
                    minHeight: AppConstants.height10(context) - 3,
                    color: probColor,
                    backgroundColor: probColor.withOpacity(.1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WheelItemsShimmer extends StatelessWidget {
  const _WheelItemsShimmer();

  @override
  Widget build(BuildContext context) {
    return appShimmer(
      child: ListView.separated(
        padding: EdgeInsets.only(
          top: AppConstants.height5(context),
          bottom: AppConstants.height20(context),
        ),
        itemCount: 4,
        separatorBuilder: (context, i) => SizedBox(height: AppConstants.height15(context)),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
            child: Container(
              padding: EdgeInsets.all(AppConstants.sp15(context)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  shimmerCircle(size: AppConstants.width20(context) * 1.4),
                  SizedBox(width: AppConstants.width10(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        shimmerBox(context, width: MediaQuery.of(context).size.width * .4, height: AppConstants.height15(context)),
                        SizedBox(height: AppConstants.height10(context)),
                        shimmerBox(context, width: MediaQuery.of(context).size.width * .25, height: AppConstants.height10(context)),
                        SizedBox(height: AppConstants.height10(context)),
                        shimmerBox(context, width: MediaQuery.of(context).size.width * .3, height: AppConstants.height10(context)),
                      ],
                    ),
                  ),
                  SizedBox(width: AppConstants.width10(context)),
                  shimmerCircle(size: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
