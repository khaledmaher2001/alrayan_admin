import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../../../core/shared_widgets/auth_logo_widget.dart';
import '../../../../../core/shared_widgets/custom_button.dart';
import '../../../../../core/shared_widgets/custom_snackbar.dart';
import '../../../../../core/shared_widgets/default_text_form_field.dart';
import '../../../../../core/shared_widgets/main_structure_widget.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/services/remote_services/service_locator.dart';
import '../../../../../core/utils/text_styles/styles.dart';
import '../../../data/repo/auth_repo_impl.dart';
import '../../view_model/forget_password/forget_password_cubit.dart';
import '../otp_view.dart';

class ForgetPasswordViewBody extends StatefulWidget {
  const ForgetPasswordViewBody({super.key});

  @override
  State<ForgetPasswordViewBody> createState() => _ForgetPasswordViewBodyState();
}

class _ForgetPasswordViewBodyState extends State<ForgetPasswordViewBody> {
  late TextEditingController emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

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
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AuthLogoWidget(
                                title: "هل نسيت كلمة المرور",
                                description:
                                "أدخل بريدك الالكترونى لإعادة تعيين كلمة المرور الخاصة بك",
                              ),
                              SizedBox(height: AppConstants.height20(context)),
                              Text(
                                "البريد الاكتروني",
                                style: Styles.inter14600black(context),
                              ),
                              SizedBox(height: AppConstants.height5(context)),
                              DefaultTextFormField(
                                validation: (value) {
                                  if (value.isNotEmpty) {
                                    if (!EmailValidator.validate(value)) {
                                      return "يجب ادخال بريد الكتروني صحيح";
                                    }
                                  } else if (value == null || value.isEmpty) {
                                    return "يجب ادخال هذا الحقل";
                                  }
                                },
                                hintText: "email@gmail.com",
                                borderRadius: AppConstants.sp10(context),
                                hasBorder: true,
                                borderSideWidth: 2,
                                contentPaddingHorizontal: AppConstants.width20(
                                  context,
                                ),
                                contentPaddingVertical: AppConstants.height20(
                                  context,
                                ),
                                textInputType: TextInputType.emailAddress,
                                controller: emailController,
                              ),
                              SizedBox(height: AppConstants.height30(context)),
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
              padding: EdgeInsets.symmetric(horizontal: AppConstants.width10(context)),
              child: BlocProvider(
                create: (BuildContext context) => ForgetPasswordCubit(getIt<AuthRepoImpl>()),
                child: BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(listener: (context, state) {
                  if (state is ForgetPasswordSuccessState) {
                    customSnackBar(message: state.message, color: Colors.green, context: context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OTPView(email: emailController.text,fromForget: true,),
                      ),
                    );
                  } else if (state is ForgetPasswordErrorState) {
                    customSnackBar(message: state.error, color: Colors.red, context: context);
                  }
                }, builder: (context, state) {
                  return state is ForgetPasswordLoadingState
                      ? const Center(child: CircularProgressIndicator())
                      : DefaultButton(
                    onPress: () {
                      if (formKey.currentState!.validate()) {
                        context.read<ForgetPasswordCubit>().forgetPassword(email: emailController.text);
                      }
                    },
                    text: "اعادة تعيين كلمة المرور",
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
