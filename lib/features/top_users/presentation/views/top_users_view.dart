import 'package:alrayan_admin/features/top_users/presentation/views/widgets/top_users_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TopUsersView extends StatelessWidget {
  const TopUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(body: TopUsersViewBody()),
    );
  }
}
