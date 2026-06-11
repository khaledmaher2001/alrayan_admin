import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
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
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: AppConstants.height20(context)),
                    CustomAppBar(
                      title: 'عجلة الحظ',
                      hasBack: true,
                      textColor: Colors.black,
                    ),
                    SizedBox(height: AppConstants.height10(context)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.width20(context)),
                      child: _WheelStatusBar(
                        isActive: isWheelActive,
                        isToggling: isTogglingWheel,
                        itemCount: rewards.length,
                        probPercent: probPercent,
                        onToggle: cubit.toggleSpinWheel,
                      ),
                    ),
                    SizedBox(height: AppConstants.height10(context)),
                    Expanded(child: _buildBody(context, state, cubit)),
                  ],
                ),
                Positioned(
                  bottom: AppConstants.height20(context),
                  left: AppConstants.width20(context),
                  right: AppConstants.width20(context),
                  child: _buildAddButton(context, cubit),
                ),
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
      return const Center(child: CircularProgressIndicator());
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
            SizedBox(height: AppConstants.height20(context) * 4),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: cubit.getLuckyWheelItems,
      child: ListView.separated(
        padding: EdgeInsets.only(
          top: AppConstants.height10(context),
          bottom: AppConstants.height20(context) * 4,
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
    IconData icon;
    if (count >= _kMaxItems) {
      label = 'وصلت للحد الأقصى ($_kMaxItems جوائز)';
      icon = Icons.lock_outline;
    } else if (probFull) {
      label = 'الاحتمالية مكتملة 100%';
      icon = Icons.lock_outline;
    } else {
      label = 'إضافة جائزة جديدة ($count/$_kMaxItems)';
      icon = Icons.add;
    }

    return ElevatedButton.icon(
      onPressed: canAdd
          ? () => NavigationUtils.navigateTo(
                context: context,
                destinationScreen: CreateEditLuckyItemView(
                  usedProbability: cubit.totalProbability,
                  autoFillProbability: isLastSlot,
                ),
              )
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        disabledBackgroundColor: Colors.grey.shade300,
        foregroundColor: Colors.white,
        minimumSize:
            Size(double.infinity, AppConstants.height20(context) * 2.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        ),
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _WheelStatusBar extends StatelessWidget {
  const _WheelStatusBar({
    required this.isActive,
    required this.isToggling,
    required this.itemCount,
    required this.probPercent,
    required this.onToggle,
  });

  final bool isActive;
  final bool isToggling;
  final int itemCount;
  final double probPercent;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isExact = (probPercent - 100).abs() < 0.5;
    final probColor = isExact
        ? Colors.green
        : probPercent > 100
            ? Colors.red
            : Colors.orange;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.width15(context),
        vertical: AppConstants.height10(context),
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تفعيل العجلة',
                      style: Styles.inter16500black(context)),
                  Text(
                    isActive ? 'نشطة' : 'متوقفة',
                    style: Styles.inter14500black(context)
                        .copyWith(color: isActive ? Colors.green : Colors.grey),
                  ),
                ],
              ),
              isToggling
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Switch(
                          value: isActive,
                          onChanged: isExact ? (_) => onToggle() : null,
                          activeThumbColor: Colors.white,
                          activeTrackColor: AppColors.primaryColor,
                        ),
                        if (!isExact)
                          Text(
                            'يجب أن تكتمل 100%',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange.shade700,
                            ),
                          ),
                      ],
                    ),
            ],
          ),
          SizedBox(height: AppConstants.height10(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الجوائز: $itemCount/$_kMaxItems',
                style: Styles.inter14500black(context)
                    .copyWith(color: Colors.grey),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: probColor),
                  ),
                  SizedBox(width: AppConstants.width5(context)),
                  Text(
                    'الاحتمالية: ${probPercent.toStringAsFixed(1)}%',
                    style: Styles.inter14500black(context)
                        .copyWith(color: probColor),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
