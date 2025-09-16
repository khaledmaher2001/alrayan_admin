import 'package:alrayan_admin/core/shared_widgets/custom_snackbar.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_helper.dart';
import 'package:alrayan_admin/features/auth/presentation/view/forget_password_view.dart';
import 'package:alrayan_admin/features/main_layout/view_model/change_nav_bar_status/change_nav_bar_status_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
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
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0), // here the desired height
        child: AppBar(
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: AppColors.primarySwatchColor,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Colors.white,
            statusBarBrightness: Brightness.dark,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppConstants.height20(context)),
            Align(
                alignment: AlignmentDirectional.center,
                child: Image.asset(AssetData.logo,width: MediaQuery.of(context).size.width*0.4,height:MediaQuery.of(context).size.width*0.4,color: Colors.white,)),
             WelcomeMessage(
              title: "helloAgain".tr(),
              supTitle:
                  "fillYouDetailsOrContinue".tr(),
            ),
            SizedBox(
              height: AppConstants.height30(context),
            ),
          Expanded(
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
                    SizedBox(height: AppConstants.height20(context),),
                    Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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

                                  await CacheHelper.saveData(key: "token", value: state.loginModel.data!.accessToken);
                                  // context.read<ProfileCubit>().fetchProfile();
                                  context.read<ChangeNavBarStatusCubit>().changeNavBarIndex(0);
                                  customSnackBar(message: state.loginModel.message!, color: Colors.green, context: context);
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

                                        BlocProvider.of<LoginCubit>(context)
                                            .userlogin(
                                            email: emailController.text.trim(),
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
                      padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context),vertical: AppConstants.height20(context)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () async {
                              // await launchUrlString("http://dgytos.com/");
                            },
                            child: Text("FIVE",style: Styles.DIN18500(context).copyWith(
                                color:Colors.black,
                                fontWeight: FontWeight.w600
                            ),),
                          ),
                          SizedBox(width: AppConstants.width5(context),),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
                            child: Image.asset(AssetData.five,width: MediaQuery.of(context).size.width*.08,height: MediaQuery.of(context).size.width*.08,),
                          ),
                          SizedBox(width: AppConstants.width5(context),),

                          Text("Made with love by",style: Styles.DIN18500(context).copyWith(
                              color:Colors.black,
                              fontWeight: FontWeight.w500
                          ),),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          ],
        ),
      ),
    );
  }
}
