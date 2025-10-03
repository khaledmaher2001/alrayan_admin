import 'package:alrayan_admin/features/profile/presentation/view/widgets/profile_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: const Scaffold(
        body: ProfileViewBody(),
      ),
    );
  }
}
