import 'package:alrayan_admin/features/splash/presentation/views/widgets/splash_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/colors/colors.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(  SystemUiOverlayStyle(
      statusBarColor:Colors.white,
      systemNavigationBarColor:Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    return   Scaffold(
      backgroundColor:Colors.white,
      body: const SplashViewBody(),
    );
  }
}
