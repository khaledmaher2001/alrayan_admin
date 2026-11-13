import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/widgets/custom_coupon_field.dart';
import 'package:alrayan_admin/features/delivery_settings/presentation/view_model/get_app_settings/get_app_settings_cubit.dart';
import 'package:alrayan_admin/features/delivery_settings/presentation/view_model/update_app_settings/update_app_settings_cubit.dart';
import 'package:alrayan_admin/features/delivery_settings/presentation/view_model/update_app_settings/update_app_settings_state.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeliverySettingsViewBody extends StatefulWidget {
  const DeliverySettingsViewBody({super.key});

  @override
  State<DeliverySettingsViewBody> createState() =>
      _DeliverySettingsViewBodyState();
}

class _DeliverySettingsViewBodyState extends State<DeliverySettingsViewBody> {
  final _formKey = GlobalKey<FormState>();
  final maxActiveDeliveriesController = TextEditingController();

  bool deliveryEnabled = true;
  bool _initialized = false;

  String? _positiveIntegerValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "field_required".tr();
    }
    final number = int.tryParse(value.trim());
    if (number == null || number <= 0) {
      return "positive_integer_required".tr();
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    context.read<GetAppSettingsCubit>().getAppSettings();
  }

  @override
  void dispose() {
    maxActiveDeliveriesController.dispose();
    super.dispose();
  }

  Future<void> _handleDeliveryToggle(bool value) async {
    if (value) {
      setState(() => deliveryEnabled = true);
      return;
    }
    final confirmed = await _confirmDisableDelivery();
    if (confirmed == true) {
      setState(() => deliveryEnabled = false);
    }
  }

  Future<bool?> _confirmDisableDelivery() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DsColor.warningBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: DsColor.warning,
                    size: MediaQuery.of(context).size.width * .08,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.height10(context)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "disable_delivery_title".tr(),
                    textAlign: TextAlign.center,
                    style: Styles.inter16500black(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.height5(context)),
            Text(
              "disable_delivery_message".tr(),
              style: Styles.inter14500black(
                context,
              ).copyWith(color: DsColor.text2),
            ),
            SizedBox(height: AppConstants.height20(context)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DsColor.warning,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: Text(
                      "disable_delivery_confirm".tr(),
                      style: Styles.inter16500black(
                        context,
                      ).copyWith(color: Colors.white),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(
                    "cancel".tr(),
                    style: Styles.inter16500black(
                      context,
                    ).copyWith(color: DsColor.textMuted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          CustomAppBar(
            title: "delivery_settings".tr(),
            textColor: Colors.black,
            hasBack: true,
            withNotifications: false,
          ),
          SizedBox(height: AppConstants.height20(context)),
          Expanded(
            child: BlocBuilder<GetAppSettingsCubit, GetAppSettingsState>(
              builder: (context, state) {
                if (state is GetAppSettingsSuccessState) {
                  if (!_initialized) {
                    final settings = state.settingsModel;
                    deliveryEnabled = settings.delivery ?? true;
                    maxActiveDeliveriesController.text =
                        settings.maxActiveDeliveriesPerCourier?.toString() ??
                        "";
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
                                color: deliveryEnabled
                                    ? DsColor.successBg
                                    : DsColor.fill,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.sp10(context),
                                ),
                                border: Border.all(
                                  color: deliveryEnabled
                                      ? DsColor.success
                                      : DsColor.textMuted,
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
                                          "enable_delivery".tr(),
                                          style: Styles.inter14500black(
                                            context,
                                          ),
                                        ),
                                        Text(
                                          deliveryEnabled
                                              ? "enabled".tr()
                                              : "disabled".tr(),
                                          style: Styles.inter12500Black(context)
                                              .copyWith(
                                                color: deliveryEnabled
                                                    ? DsColor.success
                                                    : DsColor.textMuted,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: deliveryEnabled,
                                    activeThumbColor: DsColor.success,
                                    onChanged: _handleDeliveryToggle,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: AppConstants.height20(context)),
                            CustomCouponField(
                              title: "max_active_deliveries_per_courier".tr(),
                              hint: "1",
                              controller: maxActiveDeliveriesController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validationText: "field_required".tr(),
                              validator: _positiveIntegerValidator,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (state is GetAppSettingsErrorState) {
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
            child: BlocConsumer<UpdateAppSettingsCubit, UpdateAppSettingsState>(
              builder: (context, state) {
                final isLoading = state is UpdateAppSettingsLoadingState;
                return DefaultButton(
                  onPress: isLoading
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() != true) {
                            return;
                          }
                          context.read<UpdateAppSettingsCubit>().updateAppSettings(
                            data: {
                              "delivery": deliveryEnabled,
                              "maxActiveDeliveriesPerCourier": int.parse(
                                maxActiveDeliveriesController.text.trim(),
                              ),
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
                  text: isLoading ? "" : "update_data".tr(),
                  borderRadius: AppConstants.sp10(context),
                );
              },
              listener: (context, state) {
                if (state is UpdateAppSettingsSuccessState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("update_delivery_settings_success".tr()),
                      backgroundColor: DsColor.success,
                    ),
                  );
                  context.read<GetAppSettingsCubit>().getAppSettings();
                } else if (state is UpdateAppSettingsErrorState) {
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
