import 'package:alrayan_admin/features/profile/presentation/view/widgets/change_password_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xffF7F7F8),
        body: const ChangePasswordViewBody(),
      ),
    );
  }
}
