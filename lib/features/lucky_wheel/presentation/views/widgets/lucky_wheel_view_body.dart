import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/utils/helpers/staff_permissions.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/shared_widgets/shimmer_helpers.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/lucky_wheel/data/models/spin_wheel_config_model.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/delete_lucky_item/delete_lucky_item_cubit.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/edit_lucky_item/edit_lucky_item_cubit.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/get_lucky_wheel_items/get_lucky_wheel_items_cubit.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/views/create_edit_lucky_item_view.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/views/customer_spins_view.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/views/spin_rules_view.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/views/widgets/lucky_wheel_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const int _kMaxItems = 6;
const int _kMinItems = 2;

class LuckyWheelViewBody extends StatelessWidget {
  const LuckyWheelViewBody({super.key});

  Future<void> _confirmLuckyTime(BuildContext context, bool isOn) async {
    final turningOn = !isOn;
    final ok = await dsConfirm(
      context,
      title: turningOn ? "lw_turn_on_title".tr() : "lw_turn_off_title".tr(),
      message: turningOn ? "lw_turn_on_body".tr() : "lw_turn_off_body".tr(),
      confirmLabel: turningOn ? "lw_turn_on".tr() : "lw_turn_off".tr(),
      destructive: !turningOn,
    );
    if (ok && context.mounted) {
      context.read<GetLuckyWheelItemsCubit>().setLuckyTime(turningOn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GetLuckyWheelItemsCubit, GetLuckyWheelItemsState>(
      listener: (context, state) {
        if (state is GetLuckyWheelToggleErrorState) {
          cherryToast(context: context, text: state.error, isSuccess: false);
        } else if (state is GetLuckyWheelLuckyTimeChangedState) {
          cherryToast(context: context, text: state.earningOpen ? "lw_toggled_on".tr() : "lw_toggled_off".tr());
        }
      },
      builder: (context, state) {
        final cubit = context.read<GetLuckyWheelItemsCubit>();
        final rewards = cubit.luckyWheelList;
        final isWheelActive = cubit.luckyWheelModel?.data?.isActive ?? false;
        final orderRules = cubit.luckyWheelModel?.data?.orderRules ?? const <SpinOrderRule>[];
        final probPercent = (cubit.totalProbability * 100).clamp(0.0, 100.0);
        final isTogglingWheel = state is GetLuckyWheelToggleLoadingState;
        final hasExpiredItems = rewards.any((r) {
          final date = r.expiresAt == null || r.expiresAt!.isEmpty
              ? null
              : DateTime.tryParse(r.expiresAt!);
          return date != null && date.isBefore(DateTime.now());
        });
        final hPad = EdgeInsets.symmetric(horizontal: AppConstants.width20(context));

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
                CustomAppBar(
                  title: "s_lucky_wheel".tr(),
                  hasBack: true,
                  textColor: Colors.black,
                  withNotifications: false,
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: cubit.getLuckyWheelItems,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        top: AppConstants.height15(context),
                        bottom: AppConstants.height20(context),
                      ),
                      children: [
                        Padding(
                          padding: hPad,
                          child: _WheelStatusBar(
                            isActive: isWheelActive,
                            isToggling: isTogglingWheel,
                            canEdit: staffCan(context, 'spin_wheel.edit'),
                            itemCount: rewards.length,
                            activeItemCount: rewards.where((r) => r.isActive == true).length,
                            probPercent: probPercent,
                            hasExpiredItems: hasExpiredItems,
                            onToggle: () => _confirmLuckyTime(context, isWheelActive),
                          ),
                        ),
                        SizedBox(height: AppConstants.height15(context)),
                        Padding(
                          padding: hPad,
                          child: DsGroup(children: [
                            DsRow(
                              icon: Icons.rule_rounded,
                              title: "lw_rules_title".tr(),
                              subtitle: orderRules.isEmpty
                                  ? "lw_rules_summary_none".tr()
                                  : "lw_rules_summary".tr(namedArgs: {"n": DsFormat.count(orderRules.length)}),
                              onTap: () => NavigationUtils.navigateToWithCallback(
                                context: context,
                                destinationScreen: const SpinRulesView(),
                                callback: () => cubit.getLuckyWheelItems(withLoading: false),
                              ),
                            ),
                            DsRow(
                              icon: Icons.people_alt_outlined,
                              title: "lw_spins_title".tr(),
                              subtitle: "lw_spins_row_hint".tr(),
                              onTap: () => NavigationUtils.navigateTo(
                                context: context,
                                destinationScreen: const CustomerSpinsView(),
                              ),
                            ),
                          ]),
                        ),
                        SizedBox(height: AppConstants.height20(context)),
                        Padding(
                          padding: hPad,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "s_wheel_items".tr(),
                                  style: Styles.inter16500black(context).copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              _buildAddButton(context, cubit),
                            ],
                          ),
                        ),
                        SizedBox(height: AppConstants.height10(context)),
                        ..._buildBody(context, state, cubit),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildBody(
    BuildContext context,
    GetLuckyWheelItemsState state,
    GetLuckyWheelItemsCubit cubit,
  ) {
    if (state is GetLuckyWheelItemsLoadingState) {
      return const [_WheelItemsShimmer()];
    }

    if (state is GetLuckyWheelItemsErrorState) {
      return [
        SizedBox(height: AppConstants.height20(context)),
        const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
        SizedBox(height: AppConstants.height10(context)),
        Text("s_couldn_t_load".tr(), textAlign: TextAlign.center, style: Styles.inter16500black(context)),
        SizedBox(height: AppConstants.height10(context)),
        Center(
          child: ElevatedButton.icon(
            onPressed: cubit.getLuckyWheelItems,
            icon: const Icon(Icons.refresh),
            label: Text("s_retry".tr()),
          ),
        ),
      ];
    }

    // success / toggle loading / toggle error — كلهم يعرضوا القائمة
    final rewards = cubit.luckyWheelList;

    if (rewards.isEmpty) {
      return [
        SizedBox(height: AppConstants.height20(context)),
        Icon(Icons.casino_outlined, size: 64, color: Colors.grey.shade400),
        SizedBox(height: AppConstants.height10(context)),
        Text(
          "s_no_prizes_yet".tr(),
          textAlign: TextAlign.center,
          style: Styles.inter16500black(context).copyWith(color: Colors.grey),
        ),
        SizedBox(height: AppConstants.height5(context)),
        Text(
          "i_add_at_least_x_prizes_to_enable_th_63".tr(namedArgs: {"a": "$_kMinItems"}),
          style: Styles.inter14500black(context).copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ];
    }

    return [
      for (var index = 0; index < rewards.length; index++) ...[
        if (index > 0) SizedBox(height: AppConstants.height15(context)),
        Builder(builder: (context) {
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
        }),
      ],
    ];
  }

  Widget _buildAddButton(
      BuildContext context, GetLuckyWheelItemsCubit cubit) {
    final count = cubit.luckyWheelList.length;
    final probFull = cubit.totalProbability >= 0.9999;
    final canAdd = count < _kMaxItems && !probFull;
    final isLastSlot = count == _kMaxItems - 1;

    String label;
    if (count >= _kMaxItems) {
      label = "s_limit_reached".tr();
    } else if (probFull) {
      label = "s_chances_complete".tr();
    } else {
      label = "s_add_item".tr();
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

/// "Lucky time" card: the on/off switch only decides whether orders placed now
/// earn spins; customers with saved spins can spin any time. Below it, the
/// prize chances summary.
class _WheelStatusBar extends StatelessWidget {
  const _WheelStatusBar({
    required this.isActive,
    required this.isToggling,
    required this.canEdit,
    required this.itemCount,
    required this.activeItemCount,
    required this.probPercent,
    required this.hasExpiredItems,
    required this.onToggle,
  });

  final bool isActive;
  final bool isToggling;
  final bool canEdit;
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
    final canToggle = canEdit && (isActive ? true : canToggleOn);

    return Container(
      padding: EdgeInsets.all(AppConstants.sp15(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        border: Border.all(color: DsColor.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("lw_lucky_title".tr(), style: DsText.label.copyWith(color: DsColor.text2)),
                    const SizedBox(height: DsSpace.xs),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: isActive ? DsColor.success : DsColor.textSubtle,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: DsSpace.sm),
                        Expanded(
                          child: Text(
                            isActive ? "lw_lucky_on".tr() : "lw_lucky_off".tr(),
                            style: DsText.subheading.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DsSpace.xs),
                    Text("lw_lucky_hint".tr(), style: DsText.caption),
                  ],
                ),
              ),
              const SizedBox(width: DsSpace.sm),
              isToggling
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Semantics(
                      label: "lw_lucky_title".tr(),
                      child: Switch(
                        value: isActive,
                        onChanged: canToggle ? (_) => onToggle() : null,
                        activeThumbColor: Colors.white,
                        activeTrackColor: AppColors.primaryColor,
                      ),
                    ),
            ],
          ),
          if (!isActive && (hasExpiredItems || !isExact)) ...[
            SizedBox(height: AppConstants.height5(context)),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                hasExpiredItems ? "s_some_prizes_have_expired".tr() : "s_chances_must_add_up_to_100".tr(),
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
                    Text("s_total_chances".tr(), style: Styles.inter10400grey(context)),
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
                    Text("s_active_prizes".tr(), style: Styles.inter10400grey(context)),
                    SizedBox(height: AppConstants.height5(context) / 2),
                    Text(
                      "i_x_of_x_64".tr(namedArgs: {"a": "$activeItemCount", "b": "$itemCount"}),
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
                    backgroundColor: probColor.withValues(alpha: .1),
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
      child: Column(
        children: [
          for (var index = 0; index < 4; index++) ...[
            if (index > 0) SizedBox(height: AppConstants.height15(context)),
            Padding(
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
            ),
          ],
        ],
      ),
    );
  }
}
