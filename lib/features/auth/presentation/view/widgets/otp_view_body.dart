import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/shared_widgets/auth_logo_widget.dart';
import '../../../../../core/shared_widgets/custom_button.dart';
import '../../../../../core/shared_widgets/custom_snackbar.dart';
import '../../../../../core/shared_widgets/main_structure_widget.dart';
import '../../../../../core/shared_widgets/success_popup.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/navigation_utility.dart';
import '../../view_model/send_otp/send_otp_cubit.dart';
import '../../view_model/verify_otp/verify_otp_cubit.dart';
import '../login_view.dart';
import '../reset_password_view.dart';

class OTPViewBody extends StatefulWidget {
  const OTPViewBody({super.key, required this.email, this.fromForget});

  final String email;
  final bool? fromForget;

  @override
  State<OTPViewBody> createState() => _OTPViewBodyState();
}

class _OTPViewBodyState extends State<OTPViewBody> {
  TextEditingController otpCode = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  late StreamSubscription<InternetConnectionStatus> subscription;
  bool finished = false;

  @override
  initState() {
    super.initState();
  }

  // Be sure to cancel subscription after you are done
  @override
  dispose() {
    super.dispose();

    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MainStructureWidget(
        title: "التحقق من OTB",
        widget: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.width10(context),
                        ),
                        child: Column(
                          children: [
                            AuthLogoWidget(
                              title: "التحقق من OTP",
                              description:
                                  "يرجى التحقق من بريدك الإلكتروني لرؤية رمز التحقق",
                            ),
                            SizedBox(height: AppConstants.height20(context)),
                            Form(
                              key: _formKey,
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppConstants.width5(context),
                                  ),
                                  child: PinCodeTextField(
                                    length: 6,
                                    appContext: context,
                                    obscureText: false,
                                    cursorColor: Colors.black,
                                    cursorWidth:
                                        MediaQuery.of(context).size.width * .04,
                                    cursorHeight:
                                        MediaQuery.of(context).size.height *
                                        .003,
                                    animationType: AnimationType.fade,
                                    keyboardType: TextInputType.number,
                                    pinTheme: PinTheme(
                                      shape: PinCodeFieldShape.box,
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width * .02,
                                      ),
                                      borderWidth: 0,
                                      inactiveBorderWidth: 0,
                                      activeBorderWidth: 0,
                                      fieldHeight:
                                          MediaQuery.of(context).size.height *
                                          .06,
                                      fieldWidth:
                                          MediaQuery.of(context).size.height *
                                          .06,
                                      activeFillColor: AppColors.primaryColor,
                                      inactiveColor: Color(0xffDCDCDC),

                                      inactiveFillColor: Color(0x8ABAC1E0),
                                      activeColor: Colors.white,
                                      selectedFillColor: Colors.white,
                                      selectedColor: Colors.white,
                                    ),
                                    backgroundColor: Colors.transparent,
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    animationDuration: const Duration(
                                      milliseconds: 300,
                                    ),
                                    enableActiveFill: true,
                                    validator: (String? value) {
                                      if (value!.isEmpty) {
                                        return "من فضلك ادخل الرمز";
                                      } else if (value.length < 6) {
                                        return "لابد ان يكون الرمز مكون من 6 ارقام";
                                      }
                                      return null;
                                    },
                                    controller: otpCode,
                                    onCompleted: (v) {},
                                    onChanged: (value) {
                                      debugPrint(value);
                                    },
                                    beforeTextPaste: (text) {
                                      return true;
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: AppConstants.height10(context)),
                            finished
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "لم تستلم الرسالة؟",
                                        style: TextStyle(
                                          fontFamily: "Cairo",
                                          fontSize:
                                              MediaQuery.of(
                                                context,
                                              ).size.height *
                                              .019,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      BlocConsumer<SendOtpCubit, SendOtpState>(
                                        listener: (context, state) {
                                          if (state is SendOtpSuccessState) {
                                            customSnackBar(
                                              message: state.message,
                                              color: Colors.green,
                                              context: context,
                                            );
                                          } else if (state
                                              is SendOtpErrorState) {
                                            customSnackBar(
                                              message: state.error,
                                              color: Colors.red,
                                              context: context,
                                            );
                                          }
                                        },
                                        builder: (context, state) {
                                          return state is SendOtpLoadingState
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                )
                                              : GestureDetector(
                                                  onTap: () {
                                                    context
                                                        .read<SendOtpCubit>()
                                                        .sendOtp(
                                                          email: widget.email
                                                              .trim(),
                                                        );
                                                    setState(() {
                                                      finished = false;
                                                    });
                                                  },
                                                  child: Text(
                                                    " حاول مرة أخرى",
                                                    style: TextStyle(
                                                      fontFamily: "Cairo",
                                                      fontSize:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.height *
                                                          .019,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xff1E3A8A),
                                                    ),
                                                  ),
                                                );
                                        },
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Countdown(
                                        seconds: 120,
                                        build:
                                            (
                                              BuildContext context,
                                              double time,
                                            ) {
                                              final d = Duration(
                                                seconds: time.ceil(),
                                              ); // المتبقّي
                                              final mm = d.inMinutes
                                                  .remainder(60)
                                                  .toString()
                                                  .padLeft(2, '0');
                                              final ss = d.inSeconds
                                                  .remainder(60)
                                                  .toString()
                                                  .padLeft(2, '0');
                                              return Text(
                                                '$mm : $ss',
                                                textDirection:
                                                    TextDirection.ltr,
                                                // مثال: 01 : 22
                                                style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.height *
                                                      .019,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color(
                                                    0xff1A5632,
                                                  ),
                                                ),
                                              );
                                            },
                                        interval: const Duration(seconds: 1),
                                        onFinished: () {
                                          setState(() => finished = true);
                                        },
                                      ),
                                      SizedBox(
                                        height: AppConstants.height10(context),
                                      ),
                                      Text(
                                        "تم ارسال رمز التحقق",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontFamily: "Cairo",
                                          fontSize:
                                              MediaQuery.of(
                                                context,
                                              ).size.height *
                                              .019,
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.width20(context),
              ),
              child: BlocConsumer<VerifyOtpCubit, VerifyOtpState>(
                listener: (context, state) async {
                  if (state is VerifyOtpSuccessState) {
                    if (widget.fromForget!) {
                      NavigationUtils.navigateTo(
                        context: context,
                        destinationScreen: ResetPasswordView(
                          email: widget.email,
                          otp: otpCode.text,
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (b) {
                          return SuccessPopup(
                            message:
                                "صوتك مسموع، واقتراحاتك مهمة… تواصل مع نائب دائرتك بسهولة",
                            withWidget: true,
                            title: "تم انشاء حسابك بنجاح",
                            widget: DefaultButton(
                              onPress: () {
                                NavigationUtils.navigateAndClearStack(
                                  context: context,
                                  destinationScreen: LoginView(),
                                );
                              },
                              text: "تسجيل الدخول",
                            ),
                          );
                        },
                      );
                    }
                  }
                  else if(state is VerifyOtpErrorState)
                    {
                      customSnackBar(message: state.error, color: Colors.red, context: context);
                    }
                },
                builder: (context, state) {
                  return DefaultButton(
                    onPress: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<VerifyOtpCubit>().verifyOtp(
                          otp: otpCode.text,
                          email: widget.email,
                        );
                      }
                    },
                    text: state is VerifyOtpLoadingState
                        ? "جاري التحقق...."
                        : "تحقق",
                    elevation: 0,
                    borderRadius: AppConstants.sp10(context),
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
