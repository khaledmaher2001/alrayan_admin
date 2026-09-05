import 'package:alrayan_admin/core/shared_widgets/custom_snackbar.dart';
import 'package:alrayan_admin/core/utils/helpers/arabic_to_english_number_formatter.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/auth/presentation/view/forget_password_view.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_categories/get_categories_cubit.dart';
import 'package:alrayan_admin/features/main_layout/view_model/change_nav_bar_status/change_nav_bar_status_cubit.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/get_profile/get_profile_cubit.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/shared_widgets/default_text_form_field.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/features/auth/presentation/view/widgets/divided_row.dart';
import 'package:alrayan_admin/features/auth/presentation/view/widgets/wellcome_message.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/user_login/login_cubit.dart';
import '../../../../core/utils/assets/assets.dart';
import '../../../../core/utils/colors/colors.dart';
import '../../../../core/utils/text_styles/styles.dart';
import '../view_model/user_login/login_state.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // Egyptian mobile prefixes (010/011/012/015 without the leading trunk 0).
  static const _egyptianMobilePrefixes = ["0", "1", "2", "5"];

  bool isPhoneLogin = true;

  String? _phoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "يجب ادخال هذا الحقل";
    }
    if (value.length < 10 ||
        value[0] != "1" ||
        !_egyptianMobilePrefixes.contains(value[1])) {
      return "يجب ادخال رقم هاتف مصري صحيح";
    }
    return null;
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark, // Android
        statusBarBrightness: Brightness.light, // iOS
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(AppConstants.sp20(context)),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.sp30(context))),
                color: Colors.white
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: AppConstants.height20(context)),
                  Align(
                      alignment: AlignmentDirectional.center,
                      child: Image.asset(AssetData.logoWhite,width: MediaQuery.of(context).size.width*0.4,)),
                  SizedBox(
                    height: AppConstants.height20(context),
                  ),
                  WelcomeMessage(
                    title: "helloAgain".tr(),
                    supTitle:
                    "fillYouDetailsOrContinue".tr(),
                  ),
                  SizedBox(
                    height: AppConstants.height30(context),
                  ),
                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LoginMethodTabBar(
                          isPhoneSelected: isPhoneLogin,
                          onChanged: (isPhone) {
                            setState(() => isPhoneLogin = isPhone);
                          },
                        ),
                        SizedBox(
                          height: AppConstants.height20(context),
                        ),
                        if (isPhoneLogin) ...[
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
                              validation: _phoneValidator,
                              formatter: [
                                ArabicToEnglishNumberFormatter(),
                                FilteringTextInputFormatter.digitsOnly,
                                NoLeadingZeroFormatter(),
                              ],
                              style: Styles.inter14600black(context),
                              fillColor: const Color(0xffF7F7F8),
                              contentPaddingHorizontal:
                              AppConstants.width15(context),
                              hintText: "1012345678",
                              maxLength: 10,
                              prefixIcon: Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: AppConstants.width15(context),
                                ),
                                child: Center(
                                  widthFactor: 1,
                                  child: Text(
                                    "+20  |",
                                    style: Styles.inter14600black(context)
                                        .copyWith(color: Colors.grey),
                                  ),
                                ),
                              ),
                              textInputType: TextInputType.phone,
                              controller: phoneController,
                              contentPaddingVertical:
                              AppConstants.height15(context),
                            ),
                          ),
                        ] else ...[
                          Text(
                            "email".tr(),
                            style: Styles.inter14600black(context),
                          ),
                          SizedBox(
                            height: AppConstants.height5(context),
                          ),
                          DefaultTextFormField(
                            validation: (String? value) {
                              if (value!.isEmpty) {
                                return "pleaseEnterEmail".tr();
                              }
                              return null;
                            },
                            style: Styles.inter14600black(context),
                            fillColor: const Color(0xffF7F7F8),
                            contentPaddingHorizontal:
                            AppConstants.width15(context),
                            hintText: "user@example.com",
                            textInputType: TextInputType.emailAddress,
                            controller: emailController,
                            contentPaddingVertical:
                            AppConstants.height15(context),
                          ),
                        ],
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
                            style: Styles.inter14600black(context),

                            fillColor: const Color(0xffF7F7F8),
                            contentPaddingHorizontal:
                            AppConstants.width15(context),
                            hintText: "************ ",
                            textInputType: TextInputType.text,
                            maxLines: 1,
                            controller: passwordController),
                        SizedBox(
                          height: AppConstants.height10(context),
                        ),
                        GestureDetector(
                          onTap: () {
                            NavigationUtils.navigateTo(context: context, destinationScreen: ForgetPasswordView());
                          },
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "recoveryPassword".tr(),
                                style: Styles.inter14600gray(context)
                                    .copyWith(color: AppColors.gray),
                              )),
                        ),
                        SizedBox(
                          height: AppConstants.height20(context),
                        ),
                        BlocConsumer<LoginCubit,LoginStates>(
                            listener: (context, state) async {
                              if (state is LoginSuccessState) {
                                context.read<ChangeNavBarStatusCubit>().changeNavBarIndex(0);
                                GoRouter.of(context).pushReplacement('/mainLayoutView');
                              }
                              if (state is LoginErrorState) {
                                customSnackBar(message: state.errorMessage, color: Colors.red, context: context);
                              }
                            },
                            builder: (context,state) {
                              return state is LoginLoadingState
                                  ? const Center(child: CircularProgressIndicator())
                                  : DefaultButton(
                                  height: AppConstants.height15(context),
                                  borderRadius: AppConstants.width15(context),
                                  onPress: () {
                                    if (formKey.currentState!.validate()) {
                                      final identifier = isPhoneLogin
                                          ? "+20${phoneController.text.trim()}"
                                          : emailController.text.trim();

                                      BlocProvider.of<LoginCubit>(context)
                                          .userlogin(
                                          identifier: identifier,
                                          password:
                                          passwordController.text);
                                    }
                                  },
                                  fontSize:
                                  MediaQuery.of(context).size.height * .020,
                                  text: "signIn".tr());
                            }
                        ),
                      ],
                    ),
                  ),


                  SizedBox(
                    height: AppConstants.height55(context),
                  ),
                  const DividedRow(),
                  SizedBox(
                    height: AppConstants.height20(context),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {},
                          child: Text(
                            "أكواد ACWAD",
                            style: Styles.DIN16500(
                              context,
                            ).copyWith(color: Colors.black, fontFamily: "Inter", fontWeight: FontWeight.w600),
                          ),
                        ),
                        SizedBox(width: AppConstants.width5(context)),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
                          child: Image.asset(
                            AssetData.acwad,
                            width: MediaQuery.of(context).size.width * .11,
                            height: MediaQuery.of(context).size.width * .11,
                          ),
                        ),
                        SizedBox(width: AppConstants.width5(context)),
                        Text(
                          "Made with love by",
                          style: Styles.DIN16500(
                            context,
                          ).copyWith(color: Colors.black, fontWeight: FontWeight.w600, fontFamily: "Inter"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppConstants.height20(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill-style toggle between phone and email sign-in, defaulting to phone.
class _LoginMethodTabBar extends StatelessWidget {
  const _LoginMethodTabBar({
    required this.isPhoneSelected,
    required this.onChanged,
  });

  final bool isPhoneSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp5(context)),
      decoration: BoxDecoration(
        color: const Color(0xffF6F8FE),
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tab(
              context: context,
              title: "phone".tr(),
              selected: isPhoneSelected,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _tab(
              context: context,
              title: "email".tr(),
              selected: !isPhoneSelected,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab({
    required BuildContext context,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: AppConstants.height10(context),
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: Styles.inter14600black(context).copyWith(
            color: selected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
