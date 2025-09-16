import 'package:alrayan_admin/features/auth/presentation/view/widgets/otp_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/colors/colors.dart';


class OTPView extends StatelessWidget {
  const OTPView({super.key, required this.email, this.fromForget=false});
  final String email;
  final bool? fromForget;
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
        body: OTPViewBody(email: email,fromForget:fromForget),
      ),
    );
  }
}
