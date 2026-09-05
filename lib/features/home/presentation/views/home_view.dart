import 'package:alrayan_admin/features/home/presentation/views/widgets/home_view_body.dart';
import 'package:alrayan_admin/features/profile/presentation/view/widgets/account_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: const Scaffold(
        drawer: AccountDrawer(),
        body: HomeViewBody(),
      ),
    );
  }
}
