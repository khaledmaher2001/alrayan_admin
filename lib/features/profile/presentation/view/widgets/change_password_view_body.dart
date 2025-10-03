import 'package:alrayan_admin/features/profile/data/repo/profile_repo/profile_repo_impl.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/change_password/change_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/shared_widgets/custom_button.dart';
import '../../../../../../core/shared_widgets/default_text_form_field.dart';
import '../../../../../../core/utils/assets/assets.dart';
import '../../../../../../core/utils/text_styles/styles.dart';
import '../../../../../core/shared_widgets/auth_logo_widget.dart';
import '../../../../../core/shared_widgets/main_structure_widget.dart';
import '../../../../../core/shared_widgets/success_popup.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/services/remote_services/service_locator.dart';
import '../../view_model/change_password/change_password_cubit.dart';

class ChangePasswordViewBody extends StatefulWidget {
  const ChangePasswordViewBody({super.key});

  @override
  State<ChangePasswordViewBody> createState() => _ChangePasswordViewBodyState();
}

class _ChangePasswordViewBodyState extends State<ChangePasswordViewBody> {
  var oldPassword = TextEditingController();
  var newPassword = TextEditingController();
  var confirmNewPassword = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MainStructureWidget(
        title: "تغيير كلمة المرور",
        widget: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      AuthLogoWidget(
                        title: "تغيير كلمة المرور",
                        description: "يمكنك تغيير كلمة المرور بأدخال الكلمة القديمة",
                      ),
                      SizedBox(height: AppConstants.height20(context)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("كلمة المرور القديمة", style: Styles.inter14500black(context)),
                          SizedBox(height: AppConstants.height10(context)),
                          DefaultTextFormField(
                            validation: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال كلمة المرور القديمة';
                              }
                              if (value.length < 8) {
                                return 'يجب أن تكون كلمة المرور مكونة من 8 أحرف على الأقل';
                              }
                              return null;
                            },
                            hintText: '**********',
                            isPassword: true,
                            hasBorder: true,
                            maxLines: 1,
                            textInputType: TextInputType.visiblePassword,
                            controller: oldPassword,
                          ),
                        ],
                      ),
                      SizedBox(height: AppConstants.height20(context)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("كلمة المرور الجديدة", style: Styles.inter14500black(context)),
                          SizedBox(height: AppConstants.height10(context)),
                          DefaultTextFormField(
                            validation: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال كلمة المرور';
                              }
                              if (value.length < 8) {
                                return 'يجب أن تكون كلمة المرور مكونة من 8 أحرف على الأقل';
                              }
                              return null;
                            },
                            hintText: '**********',
                            isPassword: true,
                            hasBorder: true,
                            maxLines: 1,
                            textInputType: TextInputType.visiblePassword,
                            controller: newPassword,
                          ),
                        ],
                      ),
                      SizedBox(height: AppConstants.height20(context)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("تأكيد كلمة المرور", style: Styles.inter14500black(context)),
                          SizedBox(height: AppConstants.height10(context)),
                          DefaultTextFormField(
                            validation: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال كلمة المرور';
                              }
                              if (value != newPassword.text) {
                                return 'كلمة المرور غير متطابقة';
                              }
                              return null;
                            },
                            hintText: '**********',
                            isPassword: true,
                            hasBorder: true,
                            maxLines: 1,
                            textInputType: TextInputType.visiblePassword,
                            controller: confirmNewPassword,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: AppConstants.height20(context)),
            BlocProvider(
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
                          // isError: true,
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
                  return state is ChangePasswordLoadingState
                      ? const Center(child: CircularProgressIndicator())
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
                          borderRadius: AppConstants.sp10(context),
                          text: "تغيير كلمة المرور",
                        );
                },
              ),
            ),
            SizedBox(height: AppConstants.height20(context)),
          ],
        ),
      ),
    );
  }
}
