import 'package:alrayan_admin/features/auth/presentation/view/widgets/reset_password_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/colors/colors.dart';

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key, required this.email, required this.otp});
  final String email, otp;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor:AppColors.primarySwatchColor,
        systemNavigationBarColor: const Color(0xffE9F1FF),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: ResetPasswordViewBody(email: email, otp: otp,),
      ),
    );
  }
}
