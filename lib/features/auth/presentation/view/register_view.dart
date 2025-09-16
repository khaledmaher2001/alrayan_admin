import 'package:alrayan_admin/core/shared_widgets/custom_back_button.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_snackbar.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/auth/data/repo/auth_repo_impl.dart';
import 'package:alrayan_admin/features/auth/presentation/view/otp_view.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:alrayan_admin/features/auth/presentation/view/widgets/double_text.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/user_register/register_cubit.dart';

import '../../../../core/shared_widgets/custom_button.dart';
import '../../../../core/shared_widgets/default_text_form_field.dart';
import '../../../../core/utils/colors/colors.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/helpers/arabic_to_english_number_formatter.dart';
import '../../../../core/utils/services/remote_services/service_locator.dart';
import '../../../../core/utils/text_styles/styles.dart';
import '../view_model/user_register/register_state.dart';

class RegisterView extends StatelessWidget {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();
  final phone = TextEditingController();
  final city = TextEditingController();
  final region = TextEditingController();
  final street = TextEditingController();

  RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(getIt.get<AuthRepoImpl>()),
      child: BlocConsumer<RegisterCubit, RegisterStates>(
        listener: (context, state) {
          if (state is RegisterSuccessState) {
            customSnackBar(
              message: state.registerModel.message!,
              color: Colors.green,
              context: context,
            );
            NavigationUtils.navigateReplacement(
              context: context,
              destinationScreen: OTPView(
                email: emailController.text,
                fromForget: false,
              ),
            );
          }
          if (state is RegisterErrorState) {
            customSnackBar(
              message: state.errorMessage,
              color: Colors.red,
              context: context,
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(0.0),
              child: AppBar(
                elevation: 0,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.white,
                  statusBarIconBrightness: Brightness.dark,
                  systemNavigationBarColor: Colors.white,
                  statusBarBrightness: Brightness.light,
                ),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.width20(context),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            CustomBackButton(),
                            SizedBox(height: AppConstants.height20(context)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Complet your account",
                                      style: Styles.inter28600black(context),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: AppConstants.height10(context),
                                ),
                                Text(
                                  "Lorem ipsum dolor sit amet",
                                  style: Styles.inter14600gray(context),
                                ),
                              ],
                            ),
                            SizedBox(height: AppConstants.height30(context)),
                            Form(
                              key: formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "yourName".tr(),
                                    style: Styles.inter14600black(context),
                                  ),
                                  SizedBox(
                                    height: AppConstants.height5(context),
                                  ),
                                  DefaultTextFormField(
                                    contentPaddingVertical:
                                        AppConstants.height15(context),
                                    validation: (String? value) {
                                      if (value!.isEmpty) {
                                        return "pleaseEnterYourName".tr();
                                      }
                                      return null;
                                    },
                                    style: Styles.inter14600black(context),
                                    contentPaddingHorizontal:
                                        AppConstants.width15(context),
                                    hintText: "userName".tr(),
                                    textInputType: TextInputType.name,
                                    controller: nameController,
                                  ),
                                  SizedBox(
                                    height: AppConstants.height30(context),
                                  ),
                                  Text(
                                    "email".tr(),
                                    style: Styles.inter14600black(context),
                                  ),
                                  SizedBox(
                                    height: AppConstants.height5(context),
                                  ),
                                  DefaultTextFormField(
                                    contentPaddingVertical:
                                        AppConstants.height15(context),
                                    validation: (String? value) {
                                      if (value!.isEmpty) {
                                        return "pleaseEnterEmail".tr();
                                      }
                                      return null;
                                    },
                                    style: Styles.inter14600black(context),
                                    contentPaddingHorizontal:
                                        AppConstants.width15(context),
                                    hintText: "user@mail.com",
                                    textInputType: TextInputType.emailAddress,
                                    controller: emailController,
                                  ),
                                  SizedBox(
                                    height: AppConstants.height30(context),
                                  ),
                                  Text(
                                    "phone".tr(),
                                    style: Styles.inter14600black(context),
                                  ),
                                  SizedBox(
                                    height: AppConstants.height5(context),
                                  ),
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: DefaultTextFormField(
                                      validation: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "يجب ادخال هذا الحقل";
                                        }
                                        if (value.length < 10 ||
                                            value[0].toString() != "1" ||
                                            ![
                                              "0",
                                              "1",
                                              "2",
                                              "5",
                                            ].contains(value[1].toString())) {
                                          return "يجب ادخال رقم هاتف صحيح";
                                        }
                                        return null;
                                      },
                                      formatter: [
                                        ArabicToEnglishNumberFormatter(),
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^[0-9a-zA-Z\s]*$'),
                                        ),
                                        NoLeadingZeroFormatter(),
                                      ],
                                      hintText: "رقم الهاتف",
                                      maxLength: 10,
                                      prefixIcon: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsetsDirectional.only(
                                              start: AppConstants.width10(
                                                context,
                                              ),
                                            ),
                                            child: Text(
                                              "+20  |",
                                              style: Styles.inter16400white(
                                                context,
                                              ).copyWith(color: Colors.grey),
                                            ),
                                          ),
                                        ],
                                      ),
                                      hasBorder: true,
                                      textInputType: TextInputType.phone,
                                      controller: phone,
                                    ),
                                  ),
                                  SizedBox(
                                    height: AppConstants.height30(context),
                                  ),
                                  Text(
                                    "password".tr(),
                                    style: Styles.inter14600black(context),
                                  ),
                                  SizedBox(
                                    height: AppConstants.height5(context),
                                  ),
                                  DefaultTextFormField(
                                    contentPaddingVertical:
                                        AppConstants.height15(context),
                                    validation: (String? value) {
                                      if (value!.isEmpty) {
                                        return "pleaseEnterPassword".tr();
                                      }
                                      return null;
                                    },
                                    isPassword: true,
                                    maxLines: 1,
                                    style: Styles.inter14600black(context),
                                    contentPaddingHorizontal:
                                        AppConstants.width15(context),
                                    hintText: "************ ",
                                    textInputType:
                                        TextInputType.visiblePassword,
                                    controller: passwordController,
                                  ),
                                  SizedBox(
                                    height: AppConstants.height30(context),
                                  ),
                                  Text(
                                    "pleaseConfirmPassword".tr(),
                                    style: Styles.inter14600black(context),
                                  ),
                                  SizedBox(
                                    height: AppConstants.height5(context),
                                  ),
                                  DefaultTextFormField(
                                    contentPaddingVertical:
                                        AppConstants.height15(context),
                                    validation: (String? value) {
                                      if (value!.isEmpty) {
                                        return "pleaseConfirmPassword".tr();
                                      } else if (passwordController.text !=
                                          confirmPasswordController.text) {
                                        return "notIdentical".tr();
                                      }
                                      return null;
                                    },
                                    style: Styles.inter14600black(context),
                                    contentPaddingHorizontal:
                                        AppConstants.width15(context),
                                    hintText: "************ ",
                                    isPassword: true,
                                    maxLines: 1,
                                    textInputType:
                                        TextInputType.visiblePassword,
                                    controller: confirmPasswordController,
                                  ),
                                  SizedBox(
                                    height: AppConstants.height30(context),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.width20(context),
                  ),
                  child: state is RegisterLoadingState
                      ? const Center(child: CircularProgressIndicator())
                      : DefaultButton(
                          height: AppConstants.height15(context),
                          borderRadius: AppConstants.width15(context),
                          onPress: () {
                            if (formKey.currentState!.validate()) {
                              context.read<RegisterCubit>().userRegister(
                                name: nameController.text,
                                email: emailController.text,
                                password: passwordController.text,
                                phone: phone.text,
                              );
                            }
                          },
                          fontSize: MediaQuery.of(context).size.height * .020,
                          text: "register".tr(),
                        ),
                ),
                SizedBox(height: AppConstants.height20(context)),
                Align(
                  alignment: AlignmentDirectional.center,
                  child: DoubleText(
                    firstText: "Already have an account? ".tr(),
                    secondText: "login".tr(),
                    onPress: TapGestureRecognizer()
                      ..onTap = () {
                        GoRouter.of(context).pushReplacement("/loginView");
                      },
                    secondTextStyle: Styles.inter16500black(
                      context,
                    ).copyWith(color: AppColors.primaryColor),
                  ),
                ),
                SizedBox(height: AppConstants.height20(context)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class NoLeadingZeroFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new text is not empty and starts with '0',
    // revert back to the old value (reject the change).
    if (newValue.text.isNotEmpty && newValue.text.startsWith('0')) {
      return oldValue;
    }
    return newValue;
  }
}
