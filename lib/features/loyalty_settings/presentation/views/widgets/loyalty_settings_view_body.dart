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
      return "هذا الحقل مطلوب";
    }
    final number = int.tryParse(value.trim());
    if (number == null || number <= 0) {
      return "يجب إدخال رقم صحيح موجب";
    }
    return null;
  }

  // يسمح بأرقام موجبة صحيحة أو عشرية (بدون إشارة سالبة)
  String? _positiveNumberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "هذا الحقل مطلوب";
    }
    final number = double.tryParse(value.trim());
    if (number == null || number <= 0) {
      return "يجب إدخال رقم موجب";
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
          SizedBox(height: AppConstants.height20(context)),
          CustomAppBar(
            title: "اعدادات نقاط الولاء",
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
                                  ? Colors.green.shade50
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(
                                AppConstants.sp10(context),
                              ),
                              border: Border.all(
                                color: enabled ? Colors.green : Colors.grey,
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
                                        "تفعيل نظام نقاط الولاء",
                                        style: Styles.inter14500black(
                                          context,
                                        ),
                                      ),
                                      Text(
                                        enabled ? "مفعل" : "غير مفعل",
                                        style: Styles.inter12500Black(context)
                                            .copyWith(
                                              color: enabled
                                                  ? Colors.green
                                                  : Colors.grey.shade600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: enabled,
                                  activeThumbColor: Colors.green,
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
                            title: "نسبة اكتساب النقاط",
                            hint: "مثال: 5",
                            controller: pointsEarnRatioController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validationText: "هذا الحقل مطلوب",
                            validator: _positiveIntegerValidator,
                          ),
                          SizedBox(height: AppConstants.height20(context)),
                          CustomCouponField(
                            title: "قيمة استبدال النقطة",
                            hint: "مثال: 0.5",
                            controller: pointsRedeemValueController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            validationText: "هذا الحقل مطلوب",
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
                  text: isLoading ? "" : "تحديث البيانات",
                  borderRadius: AppConstants.sp10(context),
                );
              },
              listener: (context, state) {
                if (state is UpdateLoyaltyConfigSuccessState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("تم تحديث بيانات نقاط الولاء بنجاح"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.read<GetLoyaltyConfigCubit>().getLoyaltyConfig();
                } else if (state is UpdateLoyaltyConfigErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                      backgroundColor: Colors.red,
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
