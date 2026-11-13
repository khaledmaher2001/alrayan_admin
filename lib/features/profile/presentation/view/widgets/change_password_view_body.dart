import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/features/profile/data/repo/profile_repo/profile_repo_impl.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/change_password/change_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/shared_widgets/custom_button.dart';
import '../../../../../../core/shared_widgets/default_text_form_field.dart';
import '../../../../../../core/utils/text_styles/styles.dart';
import '../../../../../core/shared_widgets/success_popup.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/services/remote_services/service_locator.dart';
import '../../view_model/change_password/change_password_cubit.dart';

class ChangePasswordViewBody extends StatefulWidget {
  const ChangePasswordViewBody({super.key});

  @override
  State<ChangePasswordViewBody> createState() => _ChangePasswordViewBodyState();
}

class _ChangePasswordViewBodyState extends State<ChangePasswordViewBody> {
  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmNewPassword = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool get _hasMinLength => newPassword.text.length >= 8;
  bool get _hasUpperAndDigit =>
      RegExp(r'[A-Z]').hasMatch(newPassword.text) && RegExp(r'[0-9]').hasMatch(newPassword.text);
  bool get _hasSpecialChar => RegExp(r'[!@#\$&*~%^()_\-+=\[\]{}|;:,.<>?/]').hasMatch(newPassword.text);

  int get _strengthScore {
    var score = 0;
    if (_hasMinLength) score++;
    if (_hasUpperAndDigit) score++;
    if (_hasSpecialChar) score++;
    if (newPassword.text.length >= 12) score++;
    return score;
  }

  @override
  void dispose() {
    oldPassword.dispose();
    newPassword.dispose();
    confirmNewPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: AppConstants.width15(context),
                vertical: AppConstants.height15(context),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SecurityBanner(),
                    SizedBox(height: AppConstants.height20(context)),
                    _buildFormCard(context),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: AppConstants.width15(context),
              vertical: AppConstants.height10(context),
            ),
            child: _buildSubmitSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DsTopBar(title: "s_change_password".tr(), subtitle: "s_make_sure_you_use_a_strong_password".tr());
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.sp15(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
        border: Border.all(color: const Color(0xffE3E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _passwordField(
            context,
            label: "s_current_password".tr(),
            controller: oldPassword,
            validation: (value) {
              if (value == null || value.isEmpty) {
                return "s_please_enter_your_current_password".tr();
              }
              if (value.length < 8) {
                return "s_the_password_must_be_at_least_8_char".tr();
              }
              return null;
            },
          ),
          SizedBox(height: AppConstants.height20(context)),
          _passwordField(
            context,
            label: "s_new_password".tr(),
            controller: newPassword,
            onChange: (_) => setState(() {}),
            validation: (value) {
              if (value == null || value.isEmpty) {
                return "s_please_enter_the_password".tr();
              }
              if (value.length < 8) {
                return "s_the_password_must_be_at_least_8_char".tr();
              }
              return null;
            },
          ),
          if (newPassword.text.isNotEmpty) ...[
            SizedBox(height: AppConstants.height10(context)),
            _StrengthMeter(score: _strengthScore),
          ],
          SizedBox(height: AppConstants.height20(context)),
          _passwordField(
            context,
            label: "s_confirm_password".tr(),
            controller: confirmNewPassword,
            validation: (value) {
              if (value == null || value.isEmpty) {
                return "s_please_enter_the_password".tr();
              }
              if (value != newPassword.text) {
                return "s_the_passwords_don_t_match_2".tr();
              }
              return null;
            },
          ),
          SizedBox(height: AppConstants.height20(context)),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
              border: Border.all(color: const Color(0xffE3E7EC)),
            ),
            child: Column(
              children: [
                _RequirementRow(label: "s_at_least_8_characters".tr(), satisfied: _hasMinLength),
                Divider(height: 1, color: DsColor.fill),
                _RequirementRow(label: "s_an_uppercase_letter_and_a_number".tr(), satisfied: _hasUpperAndDigit),
                Divider(height: 1, color: DsColor.fill),
                _RequirementRow(label: "s_one_special_character".tr(), satisfied: _hasSpecialChar),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validation,
    void Function(String)? onChange,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Styles.inter14500black(context)),
        SizedBox(height: AppConstants.height10(context)),
        DefaultTextFormField(
          validation: validation,
          hintText: '**********',
          isPassword: true,
          hasBorder: true,
          borderSideEnabledColor: const Color(0xffE3E7EC),
          maxLines: 1,
          textInputType: TextInputType.visiblePassword,
          controller: controller,
          onChange: onChange,
          prefixIcon: const Icon(Icons.lock_outline_rounded),
        ),
      ],
    );
  }

  Widget _buildSubmitSection(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => ChangePasswordCubit(getIt.get<ProfileRepoImpl>()),
      child: BlocConsumer<ChangePasswordCubit, ChangePasswordStates>(
        listener: (context, state) {
          if (state is ChangePasswordSuccessState) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return SuccessPopup(
                  withWidget: true,
                  message: "s_keep_shopping_to_earn_more_lucky_whe".tr(),
                  title: "s_password_changed_please_sign_in_agai".tr(),
                  widget: DefaultButton(
                    onPress: () {
                      GoRouter.of(context).go("/loginView");
                    },
                    text: "s_go_to_sign_in".tr(),
                    borderRadius: AppConstants.sp10(context),
                  ),
                );
              },
            );
          } else if (state is ChangePasswordErrorState) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return SuccessPopup(
                  withWidget: true,
                  message: state.error,
                  title: "s_there_s_a_problem".tr(),
                  widget: DefaultButton(
                    onPress: () {
                      GoRouter.of(context).pop();
                    },
                    text: "s_try_again_2".tr(),
                    borderRadius: AppConstants.sp10(context),
                    height: AppConstants.height15(context),
                  ),
                );
              },
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              state is ChangePasswordLoadingState
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : DefaultButton(
                      onPress: () {
                        if (formKey.currentState!.validate()) {
                          context.read<ChangePasswordCubit>().changePassword(
                            data: {
                              "currentPassword": oldPassword.text,
                              "newPassword": newPassword.text,
                              "confirmNewPassword": confirmNewPassword.text,
                            },
                          );
                        }
                      },
                      height: AppConstants.height15(context),
                      borderRadius: AppConstants.sp30(context),
                      text: "s_update_password".tr(),
                      icon: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
                    ),
              SizedBox(height: AppConstants.height10(context)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: DsColor.textMuted),
                  SizedBox(width: AppConstants.width5(context)),
                  Flexible(
                    child: Text(
                      "s_you_ll_be_signed_out_on_other_device".tr(),
                      textAlign: TextAlign.center,
                      style: Styles.inter12500Black(context).copyWith(color: DsColor.textMuted),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// "تأمين حسابك" banner at the top of the form.
class _SecurityBanner extends StatelessWidget {
  const _SecurityBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.sp15(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
        border: Border.all(color: const Color(0xffE3E7EC)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text("s_secure_your_account".tr(), style: Styles.inter16500black(context))),
                  ],
                ),
                SizedBox(height: AppConstants.height5(context) / 2),
                Text(
                  "s_use_a_strong_password".tr(),
                  style: Styles.inter12500Black(context).copyWith(color: const Color(0xff9CA4AB)),
                ),
                Text(
                  "s_don_t_use_it_for_any_other_account".tr(),
                  style: Styles.inter12500Black(context).copyWith(color: const Color(0xff9CA4AB)),
                ),
              ],
            ),
          ),
          SizedBox(width: AppConstants.width10(context)),
          Icon(Icons.gpp_good_rounded, color: AppColors.primaryColor, size: 40),
        ],
      ),
    );
  }
}

class _StrengthMeter extends StatelessWidget {
  const _StrengthMeter({required this.score});

  final int score;

  String get _label {
    if (score <= 1) return "s_weak".tr();
    if (score == 2) return "s_medium".tr();
    return "s_strong".tr();
  }

  Color get _color {
    if (score <= 1) return DsColor.danger;
    if (score == 2) return DsColor.warning;
    return DsColor.success;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "s_password_strength".tr(),
          style: Styles.inter12500Black(context).copyWith(color: const Color(0xff9CA4AB)),
        ),
        SizedBox(width: AppConstants.width10(context)),
        Expanded(
          child: Row(
            children: List.generate(4, (i) {
              final filled = i < score;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsetsDirectional.only(end: i == 3 ? 0 : AppConstants.width5(context)),
                  decoration: BoxDecoration(
                    color: filled ? _color : DsColor.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(width: AppConstants.width10(context)),
        Text(_label, style: Styles.inter14600black(context).copyWith(color: _color, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.label, required this.satisfied});

  final String label;
  final bool satisfied;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.width15(context),
        vertical: AppConstants.height10(context),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Styles.inter14500black(context)),
          ),
          Icon(
            satisfied ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: satisfied ? DsColor.success : DsColor.border,
            size: 20,
          ),
        ],
      ),
    );
  }
}
