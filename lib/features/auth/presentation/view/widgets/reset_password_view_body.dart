import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/shared_widgets/auth_logo_widget.dart';
import '../../../../../core/shared_widgets/custom_button.dart';
import '../../../../../core/shared_widgets/custom_snackbar.dart';
import '../../../../../core/shared_widgets/default_text_form_field.dart';
import '../../../../../core/shared_widgets/main_structure_widget.dart';
import '../../../../../core/shared_widgets/success_popup.dart';
import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/navigation_utility.dart';
import '../../../../../core/utils/services/remote_services/service_locator.dart';
import '../../../../../core/utils/text_styles/styles.dart';
import '../../../data/repo/auth_repo_impl.dart';
import '../../view_model/reset_password/reset_password_cubit.dart';
import '../login_view.dart';

class ResetPasswordViewBody extends StatefulWidget {
  const ResetPasswordViewBody({super.key, required this.email, required this.otp});
  final String email, otp;

  @override
  State<ResetPasswordViewBody> createState() => _ResetPasswordViewBodyState();
}

class _ResetPasswordViewBodyState extends State<ResetPasswordViewBody> {
  final passwordController = TextEditingController();

  final passwordConfirmController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MainStructureWidget(
        title: "تأكيد كلمة المرور",
        widget: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.width10(context),
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AuthLogoWidget(
                                title: "إعادة تعيين كلمة المرور",
                                description: "أدخل كلمة المرور الجديدة",
                              ),
                              SizedBox(height: AppConstants.height20(context)),

                              Text(
                                "كلمة المرور الجديدة",
                                style: Styles.inter16500black(context),
                              ),
                              SizedBox(height: AppConstants.height5(context)),
                              DefaultTextFormField(
                                validation: (val) {
                                  if (val.isEmpty || val == null) {
                                    return 'من فضلك ادخل كلمة المرور الجديده';
                                  }
                                },
                                contentPaddingHorizontal: AppConstants.width15(
                                  context,
                                ),
                                hintText: "************",
                                textInputType: TextInputType.visiblePassword,
                                isPassword: true,
                                maxLines: 1,
                                controller: passwordController,
                              ),
                              SizedBox(height: AppConstants.height30(context)),
                              Text(
                                "تاكيد كلمة المرور",
                                style: Styles.inter14600black(context),
                              ),
                              SizedBox(height: AppConstants.height5(context)),
                              DefaultTextFormField(
                                validation: (val) {
                                  if (val.isEmpty || val == null) {
                                    return 'يجب تأكيد كلمة المرور';
                                  } else if (passwordConfirmController.text !=
                                      passwordController.text) {
                                    return 'كلمتا المرور غير متطابقتين';
                                  }
                                },
                                contentPaddingHorizontal: AppConstants.width15(
                                  context,
                                ),
                                hintText: "************ ",
                                textInputType: TextInputType.visiblePassword,
                                isPassword: true,
                                maxLines: 1,
                                controller: passwordConfirmController,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppConstants.sp20(context)),
              child: BlocProvider(
                create: (context) => ResetPasswordCubit(getIt<AuthRepoImpl>()),
                child: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(listener: (context, state) {
                  if (state is ResetPasswordSuccessState) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return SuccessPopup(
                          withWidget: true,
                          message:
                          'صوتك مسموع، واقتراحاتك مهمة… تواصل مع نائب دائرتك بسهولة',
                          title: 'تم تغيير كلمة المرور بنجاح سجل مرة اخرى',
                          widget: DefaultButton(onPress: () {
                            NavigationUtils.navigateReplacement(context: context, destinationScreen: LoginView());
                          }, text: "الذهاب لتسجيل دخول",borderRadius: AppConstants.sp10(context),),
                        );
                      },
                    );
                  } else if (state is ResetPasswordErrorState) {
                   customSnackBar(message: state.error, color: Colors.red, context: context);
                  }
                }, builder: (context, state) {
                  return state is ResetPasswordLoadingState
                      ? const Center(child: CircularProgressIndicator())
                      : DefaultButton(
                    onPress: () {
                      if (formKey.currentState!.validate()) {
                        context.read<ResetPasswordCubit>().resetPassword(data: {
                          "email": widget.email,
                          "newPassword": passwordController.text,
                        });
                      }
                    },
                    text: "تأكيد كلمة المرور",
                    height: AppConstants.height15(context),
                    borderRadius: AppConstants.sp10(context),
                  );
                }),
              ),
            ),
            SizedBox(height: AppConstants.height20(context)),
          ],
        ),
      ),
    );
  }
}
