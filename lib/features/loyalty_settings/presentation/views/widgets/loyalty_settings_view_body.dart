import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/widgets/custom_coupon_field.dart';
import 'package:alrayan_admin/features/loyalty_settings/presentation/view_model/get_loyalty_config/get_loyalty_config_cubit.dart';
import 'package:alrayan_admin/features/loyalty_settings/presentation/view_model/update_loyalty_config/update_loyalty_config_cubit.dart';
import 'package:alrayan_admin/features/loyalty_settings/presentation/view_model/update_loyalty_config/update_loyalty_config_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoyaltySettingsViewBody extends StatefulWidget {
  const LoyaltySettingsViewBody({super.key});

  @override
  State<LoyaltySettingsViewBody> createState() =>
      _LoyaltySettingsViewBodyState();
}

class _LoyaltySettingsViewBodyState extends State<LoyaltySettingsViewBody> {
  final _formKey = GlobalKey<FormState>();
  final pointsEarnRatioController = TextEditingController();
  final pointsRedeemValueController = TextEditingController();

  bool enabled = true;
  bool _initialized = false;

  // يسمح فقط بأرقام صحيحة موجبة (بدون فاصلة عشرية وبدون إشارة سالبة)
  String? _positiveIntegerValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "s_this_field_is_required_2".tr();
    }
    final number = int.tryParse(value.trim());
    if (number == null || number <= 0) {
      return "s_enter_a_valid_positive_number".tr();
    }
    return null;
  }

  // يسمح بأرقام موجبة صحيحة أو عشرية (بدون إشارة سالبة)
  String? _positiveNumberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "s_this_field_is_required_2".tr();
    }
    final number = double.tryParse(value.trim());
    if (number == null || number <= 0) {
      return "s_enter_a_positive_number".tr();
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    context.read<GetLoyaltyConfigCubit>().getLoyaltyConfig();
  }

  @override
  void dispose() {
    pointsEarnRatioController.dispose();
    pointsRedeemValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          CustomAppBar(
            title: "s_loyalty_points_settings".tr(),
            textColor: Colors.black,
            hasBack: true,
            withNotifications: false,
          ),
          SizedBox(height: AppConstants.height20(context)),
          Expanded(
            child: BlocBuilder<GetLoyaltyConfigCubit, GetLoyaltyConfigState>(
              builder: (context, state) {
                if (state is GetLoyaltyConfigSuccessState) {
                  if (!_initialized) {
                    final config = state.configModel;
                    pointsEarnRatioController.text =
                        config.pointsEarnRatio?.toString() ?? "";
                    pointsRedeemValueController.text =
                        config.pointsRedeemValue?.toString() ?? "";
                    enabled = config.enabled ?? false;
                    _initialized = true;
                  }

                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.width20(context),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppConstants.sp20(context),
                              vertical: AppConstants.sp10(context),
                            ),
                            decoration: BoxDecoration(
                              color: enabled
                                  ? DsColor.successBg
                                  : DsColor.fill,
                              borderRadius: BorderRadius.circular(
                                AppConstants.sp10(context),
                              ),
                              border: Border.all(
                                color: enabled ? DsColor.success : DsColor.textMuted,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "s_enable_loyalty_points".tr(),
                                        style: Styles.inter14500black(
                                          context,
                                        ),
                                      ),
                                      Text(
                                        enabled ? "s_enabled".tr() : "s_disabled".tr(),
                                        style: Styles.inter12500Black(context)
                                            .copyWith(
                                              color: enabled
                                                  ? DsColor.success
                                                  : DsColor.textMuted,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: enabled,
                                  activeThumbColor: DsColor.success,
                                  onChanged: (value) {
                                    setState(() {
                                      enabled = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppConstants.height20(context)),
                          CustomCouponField(
                            title: "s_points_earning_rate".tr(),
                            hint: "s_e_g_5".tr(),
                            controller: pointsEarnRatioController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validationText: "s_this_field_is_required_2".tr(),
                            validator: _positiveIntegerValidator,
                          ),
                          SizedBox(height: AppConstants.height20(context)),
                          CustomCouponField(
                            title: "s_point_redemption_value".tr(),
                            hint: "s_e_g_0_5".tr(),
                            controller: pointsRedeemValueController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            validationText: "s_this_field_is_required_2".tr(),
                            validator: _positiveNumberValidator,
                          ),
                        ],
                        ),
                      ),
                    ),
                  );
                } else if (state is GetLoyaltyConfigErrorState) {
                  return Center(
                    child: Text(
                      state.errorMessage,
                      style: Styles.inter14500black(context),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          SizedBox(height: AppConstants.height20(context)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.width20(context),
            ),
            child:
                BlocConsumer<UpdateLoyaltyConfigCubit, UpdateLoyaltyConfigState>(
              builder: (context, state) {
                final isLoading = state is UpdateLoyaltyConfigLoadingState;
                return DefaultButton(
                  onPress: isLoading
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() != true) {
                            return;
                          }
                          context
                              .read<UpdateLoyaltyConfigCubit>()
                              .updateLoyaltyConfig(
                            data: {
                              "pointsEarnRatio": int.parse(
                                pointsEarnRatioController.text.trim(),
                              ),
                              "pointsRedeemValue": double.parse(
                                pointsRedeemValueController.text.trim(),
                              ),
                              "enabled": enabled,
                            },
                          );
                        },
                  icon: isLoading
                      ? SizedBox(
                          width: AppConstants.sp20(context),
                          height: AppConstants.sp20(context),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : null,
                  backgroundColor: isLoading
                      ? AppColors.primaryColor.shade500
                      : AppColors.primaryColor,
                  text: isLoading ? "" : "s_update".tr(),
                  borderRadius: AppConstants.sp10(context),
                );
              },
              listener: (context, state) {
                if (state is UpdateLoyaltyConfigSuccessState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("s_loyalty_points_settings_updated".tr()),
                      backgroundColor: DsColor.success,
                    ),
                  );
                  context.read<GetLoyaltyConfigCubit>().getLoyaltyConfig();
                } else if (state is UpdateLoyaltyConfigErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                      backgroundColor: DsColor.danger,
                    ),
                  );
                }
              },
            ),
          ),
          SizedBox(height: AppConstants.height20(context)),
        ],
      ),
    );
  }
}
