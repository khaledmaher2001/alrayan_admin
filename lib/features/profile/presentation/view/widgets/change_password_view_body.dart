import 'package:alrayan_admin/features/profile/data/repo/profile_repo/profile_repo_impl.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/change_password/change_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/shared_widgets/custom_button.dart';
import '../../../../../../core/shared_widgets/default_text_form_field.dart';
import '../../../../../../core/utils/assets/assets.dart';
import '../../../../../../core/utils/text_styles/styles.dart';
import '../../../../../core/shared_widgets/success_popup.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/navigation_utility.dart';
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
          SizedBox(height: AppConstants.height10(context)),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: AppConstants.width15(context)),
            child: _buildHeader(context),
          ),
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
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            Row(
              children: [
                Expanded(child: Text("تغيير كلمة المرور",textAlign: TextAlign.center, style: Styles.inter18500Black(context))),
              ],
            ),
            SizedBox(height: AppConstants.height5(context) ),
            Text(
              "تأكد من استخدام كلمة مرور قوية",
              style: Styles.inter14500black(context).copyWith(color: const Color(0xff9CA4AB)),
            ),
          ],
        ),
        PositionedDirectional(
          start: 0,
          child: InkWell(
            onTap: () => NavigationUtils.navigateBack(context: context),
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: AppConstants.width20(context) * 2.2,
              height: AppConstants.width20(context) * 2.2,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.gray.withValues(alpha: .15)),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.black),
            ),
          ),
        ),
      ],
    );
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
            label: "كلمة المرور الحالية",
            controller: oldPassword,
            validation: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال كلمة المرور الحالية';
              }
              if (value.length < 8) {
                return 'يجب أن تكون كلمة المرور مكونة من 8 أحرف على الأقل';
              }
              return null;
            },
          ),
          SizedBox(height: AppConstants.height20(context)),
          _passwordField(
            context,
            label: "كلمة المرور الجديدة",
            controller: newPassword,
            onChange: (_) => setState(() {}),
            validation: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال كلمة المرور';
              }
              if (value.length < 8) {
                return 'يجب أن تكون كلمة المرور مكونة من 8 أحرف على الأقل';
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
            label: "تأكيد كلمة المرور",
            controller: confirmNewPassword,
            validation: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال كلمة المرور';
              }
              if (value != newPassword.text) {
                return 'كلمة المرور غير متطابقة';
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
                _RequirementRow(label: "8 أحرف على الأقل", satisfied: _hasMinLength),
                Divider(height: 1, color: Colors.grey.shade100),
                _RequirementRow(label: "حرف كبير ورقم", satisfied: _hasUpperAndDigit),
                Divider(height: 1, color: Colors.grey.shade100),
                _RequirementRow(label: "رمز خاص واحد", satisfied: _hasSpecialChar),
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
                  message: 'تابع عمليات الشراء واكسب المزيد من المحاولات في عجلة الحظ',
                  title: 'تم تغيير كلمة المرور بنجاح سجل مرة اخرى',
                  widget: DefaultButton(
                    onPress: () {
                      GoRouter.of(context).go("/loginView");
                    },
                    text: "الذهاب لتسجيل دخول",
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
                  title: 'هناك مشكلة',
                  widget: DefaultButton(
                    onPress: () {
                      GoRouter.of(context).pop();
                    },
                    text: "حاول مرة اخري",
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
                      text: "تحديث كلمة المرور",
                      icon: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
                    ),
              SizedBox(height: AppConstants.height10(context)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey.shade500),
                  SizedBox(width: AppConstants.width5(context)),
                  Flexible(
                    child: Text(
                      "سيتم تسجيل خروجك من الأجهزة الأخرى بعد التغيير",
                      textAlign: TextAlign.center,
                      style: Styles.inter12500Black(context).copyWith(color: Colors.grey.shade600),
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
                    Expanded(child: Text("تأمين حسابك", style: Styles.inter16500black(context))),
                  ],
                ),
                SizedBox(height: AppConstants.height5(context) / 2),
                Text(
                  "استخدم كلمة مرور قوية",
                  style: Styles.inter12500Black(context).copyWith(color: const Color(0xff9CA4AB)),
                ),
                Text(
                  "لا تستخدمها في أي حساب آخر",
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
    if (score <= 1) return "ضعيفة";
    if (score == 2) return "متوسطة";
    return "قوية";
  }

  Color get _color {
    if (score <= 1) return Colors.red;
    if (score == 2) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "قوة كلمة المرور",
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
                    color: filled ? _color : Colors.grey.shade200,
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
            color: satisfied ? Colors.green.shade600 : Colors.grey.shade300,
            size: 20,
          ),
        ],
      ),
    );
  }
}
