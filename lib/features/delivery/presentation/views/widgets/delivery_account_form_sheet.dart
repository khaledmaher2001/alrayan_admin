import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/shared_widgets/default_text_form_field.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/helpers/arabic_to_english_number_formatter.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/delivery/data/models/delivery_account_model.dart';
import 'package:alrayan_admin/features/delivery/data/repo/delivery_repo_impl.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/create_delivery_account/create_delivery_account_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/create_delivery_account/create_delivery_account_states.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/update_delivery_profile/update_delivery_profile_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/update_delivery_profile/update_delivery_profile_states.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bottom sheet used both to create a new courier account
/// (`POST /delivery/accounts`) and to edit an existing one
/// (`PATCH /delivery/accounts/{userId}/profile`). Pass [account] to switch
/// to edit mode — only the 4 fields the update endpoint actually accepts
/// are shown then.
Future<bool?> showDeliveryAccountFormSheet({
  required BuildContext context,
  DeliveryAccount? account,
  required VoidCallback onSuccess,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        DeliveryAccountFormSheet(account: account, onSuccess: onSuccess),
  );
}

class DeliveryAccountFormSheet extends StatefulWidget {
  const DeliveryAccountFormSheet({
    super.key,
    this.account,
    required this.onSuccess,
  });

  final DeliveryAccount? account;
  final VoidCallback onSuccess;

  bool get isEdit => account != null;

  @override
  State<DeliveryAccountFormSheet> createState() =>
      _DeliveryAccountFormSheetState();
}

class _DeliveryAccountFormSheetState extends State<DeliveryAccountFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final fullNameController = TextEditingController(
    text: widget.account?.fullName,
  );
  late final emailController = TextEditingController(
    text: widget.account?.email,
  );
  late final phoneController = TextEditingController(
    text: widget.account?.phoneNumber,
  );
  final passwordController = TextEditingController();
  late final vehicleNameController = TextEditingController(
    text: widget.account?.vehicleName,
  );
  late final vehiclePlateController = TextEditingController(
    text: widget.account?.vehiclePlateNumber,
  );
  late final earningController = TextEditingController(
    text: widget.account?.earningPercentage?.toString(),
  );
  late final maxActiveOrdersController = TextEditingController(
    text: widget.account?.maxActiveOrdersOverride?.toString(),
  );

  bool get _isDirty {
    if (!widget.isEdit) {
      return fullNameController.text.isNotEmpty ||
          emailController.text.isNotEmpty ||
          phoneController.text.isNotEmpty ||
          passwordController.text.isNotEmpty ||
          vehicleNameController.text.isNotEmpty ||
          vehiclePlateController.text.isNotEmpty ||
          earningController.text.isNotEmpty ||
          maxActiveOrdersController.text.isNotEmpty;
    }
    final a = widget.account!;
    return vehicleNameController.text != (a.vehicleName ?? '') ||
        vehiclePlateController.text != (a.vehiclePlateNumber ?? '') ||
        earningController.text != (a.earningPercentage?.toString() ?? '') ||
        maxActiveOrdersController.text !=
            (a.maxActiveOrdersOverride?.toString() ?? '');
  }

  Future<bool> _confirmDiscard(BuildContext context) async {
    if (!_isDirty) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "discard_changes_title".tr(),
          style: Styles.inter16500black(context),
        ),
        content: Text(
          "discard_changes_message".tr(),
          style: Styles.inter14500black(
            context,
          ).copyWith(color: DsColor.text2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text("cancel".tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              "discard".tr(),
              style: const TextStyle(color: DsColor.danger),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    vehicleNameController.dispose();
    vehiclePlateController.dispose();
    earningController.dispose();
    maxActiveOrdersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CreateDeliveryAccountCubit(getIt<DeliveryRepoImpl>()),
        ),
        BlocProvider(
          create: (_) => UpdateDeliveryProfileCubit(getIt<DeliveryRepoImpl>()),
        ),
      ],
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (await _confirmDiscard(context) && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: _buildSheet(context),
      ),
    );
  }

  Widget _buildSheet(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          SizedBox(height: AppConstants.height15(context)),
          Center(
            child: Container(
              height: AppConstants.height5(context),
              width: MediaQuery.of(context).size.width * 0.15,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                color: DsColor.border,
              ),
            ),
          ),
          SizedBox(height: AppConstants.height15(context)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.width20(context),
            ),
            child: Row(
              children: [
                Text(
                  widget.isEdit ? "edit_courier".tr() : "create_courier".tr(),
                  style: Styles.inter16500black(context),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    if (await _confirmDiscard(context) && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Divider(color: DsColor.fill),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.width20(context),
                vertical: AppConstants.height15(context),
              ),
              child: Form(key: _formKey, child: _buildFields(context)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppConstants.width20(context)),
            child: _buildSubmitButton(context),
          ),
        ],
      ),
    );
  }

  Widget _labeled(BuildContext context, String label, Widget field) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.height15(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Styles.inter14500black(context)),
          SizedBox(height: AppConstants.height5(context)),
          field,
        ],
      ),
    );
  }

  Widget _buildFields(BuildContext context) {
    if (widget.isEdit) {
      return Column(
        children: [
          _labeled(
            context,
            "vehicle_name".tr(),
            DefaultTextFormField(
              controller: vehicleNameController,
              textInputType: TextInputType.text,
              hintText: "vehicle_name".tr(),
            ),
          ),
          _labeled(
            context,
            "vehicle_plate_number".tr(),
            DefaultTextFormField(
              controller: vehiclePlateController,
              textInputType: TextInputType.text,
              hintText: "vehicle_plate_number".tr(),
            ),
          ),
          _labeled(
            context,
            "earning_percentage".tr(),
            DefaultTextFormField(
              controller: earningController,
              textInputType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              hintText: "earning_percentage_hint".tr(),
              required: false,
              validation: (value) => _validateEarningPercentage(value, false),
            ),
          ),
          _labeled(
            context,
            "max_active_orders".tr(),
            DefaultTextFormField(
              controller: maxActiveOrdersController,
              textInputType: TextInputType.number,
              hintText: "max_active_orders_hint".tr(),
              required: false,
              validation: (value) => _validateMaxActiveOrders(value, false),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _labeled(
          context,
          "fullName".tr(),
          DefaultTextFormField(
            controller: fullNameController,
            textInputType: TextInputType.text,
            hintText: "fullName".tr(),
            maxLength: 100,
            validationMsg: "field_required".tr(),
          ),
        ),
        _labeled(
          context,
          "email".tr(),
          DefaultTextFormField(
            controller: emailController,
            textInputType: TextInputType.emailAddress,
            hintText: "email".tr(),
            maxLength: 255,
            validation: (value) {
              if (value == null || value.trim().isEmpty) {
                return "field_required".tr();
              }
              if (!EmailValidator.validate(value.trim())) {
                return "invalid_email".tr();
              }
              return null;
            },
          ),
        ),
        _labeled(
          context,
          "phoneNumber".tr(),
          Directionality(
            textDirection: TextDirection.ltr,
            child: DefaultTextFormField(
              controller: phoneController,
              textInputType: TextInputType.phone,
              hintText: "phoneNumber".tr(),
              maxLength: 10,
              formatter: [
                ArabicToEnglishNumberFormatter(),
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9a-zA-Z\s]*$')),
                NoLeadingZeroFormatter(),
              ],
              validation: (String? value) {
                if (value == null || value.isEmpty) {
                  return "field_required".tr();
                }
                if (value.length < 10 ||
                    value[0] != "1" ||
                    !["0", "1", "2", "5"].contains(value[1])) {
                  return "invalid_phone_number".tr();
                }
                return null;
              },
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "+20",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _labeled(
          context,
          "password".tr(),
          DefaultTextFormField(
            controller: passwordController,
            textInputType: TextInputType.text,
            hintText: "password".tr(),
            isPassword: true,
            maxLength: 100,
            maxLines: 1,
            validation: (value) {
              if (value == null || value.isEmpty) {
                return "field_required".tr();
              }
              if (value.length < 6) return "password_min_length".tr();
              return null;
            },
          ),
        ),
        _labeled(
          context,
          "vehicle_name".tr(),
          DefaultTextFormField(
            controller: vehicleNameController,
            textInputType: TextInputType.text,
            hintText: "vehicle_name".tr(),
            validationMsg: "field_required".tr(),
          ),
        ),
        _labeled(
          context,
          "vehicle_plate_number".tr(),
          DefaultTextFormField(
            controller: vehiclePlateController,
            textInputType: TextInputType.text,
            hintText: "vehicle_plate_number".tr(),
            validationMsg: "field_required".tr(),
          ),
        ),
        _labeled(
          context,
          "earning_percentage".tr(),
          DefaultTextFormField(
            controller: earningController,
            textInputType: const TextInputType.numberWithOptions(decimal: true),
            hintText: "earning_percentage_hint".tr(),
            validation: (value) => _validateEarningPercentage(value, true),
          ),
        ),
        _labeled(
          context,
          "max_active_orders".tr(),
          DefaultTextFormField(
            controller: maxActiveOrdersController,
            textInputType: TextInputType.number,
            hintText: "max_active_orders_hint".tr(),
            validation: (value) => _validateMaxActiveOrders(value, true),
          ),
        ),
      ],
    );
  }

  String? _validateEarningPercentage(String? value, bool required) {
    if (value == null || value.trim().isEmpty) {
      return required ? "field_required".tr() : null;
    }
    final parsed = num.tryParse(value.trim());
    if (parsed == null) return "invalid_number".tr();
    if (parsed < 0 || parsed > 100) return "earning_percentage_range".tr();
    return null;
  }

  String? _validateMaxActiveOrders(String? value, bool required) {
    if (value == null || value.trim().isEmpty) {
      return required ? "field_required".tr() : null;
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return "invalid_number".tr();
    if (parsed < 1) return "max_active_orders_range".tr();
    return null;
  }

  Widget _buildSubmitButton(BuildContext context) {
    if (widget.isEdit) {
      return BlocConsumer<
        UpdateDeliveryProfileCubit,
        UpdateDeliveryProfileState
      >(
        listener: (context, state) {
          if (state is UpdateDeliveryProfileSuccess) {
            cherryToast(text: "courier_updated_success".tr(), context: context);
            widget.onSuccess();
            Navigator.of(context).pop(true);
          } else if (state is UpdateDeliveryProfileError) {
            cherryToast(
              text: state.message,
              context: context,
              isSuccess: false,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is UpdateDeliveryProfileLoading;
          return DefaultButton(
            borderRadius: AppConstants.sp10(context),
            onPress: isLoading ? null : () => _submitEdit(context),
            text: isLoading ? "" : "save".tr(),
            icon: isLoading
                ? SizedBox(
                    height: AppConstants.sp20(context),
                    width: AppConstants.sp20(context),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : null,
          );
        },
      );
    }

    return BlocConsumer<CreateDeliveryAccountCubit, CreateDeliveryAccountState>(
      listener: (context, state) {
        if (state is CreateDeliveryAccountSuccess) {
          cherryToast(text: "courier_created_success".tr(), context: context);
          widget.onSuccess();
          Navigator.of(context).pop(true);
        } else if (state is CreateDeliveryAccountError) {
          cherryToast(text: state.message, context: context, isSuccess: false);
        }
      },
      builder: (context, state) {
        final isLoading = state is CreateDeliveryAccountLoading;
        return DefaultButton(
          borderRadius: AppConstants.sp10(context),
          onPress: isLoading ? null : () => _submitCreate(context),
          text: isLoading ? "" : "create".tr(),
          icon: isLoading
              ? SizedBox(
                  height: AppConstants.sp20(context),
                  width: AppConstants.sp20(context),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : null,
        );
      },
    );
  }

  void _submitCreate(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<CreateDeliveryAccountCubit>().createDeliveryAccount({
      'fullName': fullNameController.text.trim(),
      'email': emailController.text.trim(),
      'phoneNumber': "+20${phoneController.text.trim()}",
      'password': passwordController.text,
      'vehicleName': vehicleNameController.text.trim(),
      'vehiclePlateNumber': vehiclePlateController.text.trim(),
      'earningPercentage': num.parse(earningController.text.trim()),
      'maxActiveOrders': int.parse(maxActiveOrdersController.text.trim()),
    });
  }

  void _submitEdit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final data = <String, dynamic>{
      'vehicleName': vehicleNameController.text.trim(),
      'vehiclePlateNumber': vehiclePlateController.text.trim(),
    };
    if (earningController.text.trim().isNotEmpty) {
      data['earningPercentage'] = num.parse(earningController.text.trim());
    }
    if (maxActiveOrdersController.text.trim().isNotEmpty) {
      data['maxActiveOrders'] = int.parse(
        maxActiveOrdersController.text.trim(),
      );
    } else {
      data['maxActiveOrders'] = null;
    }
    context.read<UpdateDeliveryProfileCubit>().updateProfile(
      userId: widget.account!.userId!,
      data: data,
    );
  }
}
