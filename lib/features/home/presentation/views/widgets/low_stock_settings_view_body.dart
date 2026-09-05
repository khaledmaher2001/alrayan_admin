import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/widgets/custom_coupon_field.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_low_stock_config/get_low_stock_config_cubit.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_low_stock_config/get_low_stock_config_state.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/update_low_stock_config/update_low_stock_config_cubit.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/update_low_stock_config/update_low_stock_config_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LowStockSettingsViewBody extends StatefulWidget {
  const LowStockSettingsViewBody({super.key});

  @override
  State<LowStockSettingsViewBody> createState() =>
      _LowStockSettingsViewBodyState();
}

class _LowStockSettingsViewBodyState extends State<LowStockSettingsViewBody> {
  final _formKey = GlobalKey<FormState>();
  final thresholdController = TextEditingController();

  bool _initialized = false;

  String? _nonNegativeIntegerValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "هذا الحقل مطلوب";
    }
    final number = int.tryParse(value.trim());
    if (number == null || number < 0) {
      return "يجب إدخال رقم صحيح موجب";
    }
    return null;
  }

  @override
  void dispose() {
    thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppConstants.height20(context)),
          const CustomAppBar(
            title: "اعدادات المخزون المنخفض",
            textColor: Colors.black,
            hasBack: true,
            withNotifications: false,
          ),
          SizedBox(height: AppConstants.height20(context)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.width20(context),
            ),
            child: Text(
              "تحديد الحد الأدنى للمخزون الذي يعتبر عنده المنتج منخفض المخزون وتنبيه الأدمن",
              style: Styles.inter14600gray(context),
            ),
          ),
          SizedBox(height: AppConstants.height20(context)),
          Expanded(
            child: BlocBuilder<GetLowStockConfigCubit, GetLowStockConfigState>(
              builder: (context, state) {
                if (state is GetLowStockConfigSuccess) {
                  if (!_initialized) {
                    thresholdController.text =
                        state.config.threshold?.toString() ?? "";
                    _initialized = true;
                  }

                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.width20(context),
                      ),
                      child: Form(
                        key: _formKey,
                        child: CustomCouponField(
                          title: "حد المخزون المنخفض",
                          hint: "مثال: 10",
                          controller: thresholdController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validationText: "هذا الحقل مطلوب",
                          validator: _nonNegativeIntegerValidator,
                        ),
                      ),
                    ),
                  );
                } else if (state is GetLowStockConfigError) {
                  return Center(
                    child: Text(
                      state.error,
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
                BlocConsumer<UpdateLowStockConfigCubit, UpdateLowStockConfigState>(
              builder: (context, state) {
                final isLoading = state is UpdateLowStockConfigLoading;
                return DefaultButton(
                  onPress: isLoading
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() != true) {
                            return;
                          }
                          context
                              .read<UpdateLowStockConfigCubit>()
                              .updateLowStockConfig(
                                threshold: int.parse(
                                  thresholdController.text.trim(),
                                ),
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
                if (state is UpdateLowStockConfigSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("تم تحديث اعدادات المخزون المنخفض بنجاح"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.read<GetLowStockConfigCubit>().getLowStockConfig();
                } else if (state is UpdateLowStockConfigError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
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
