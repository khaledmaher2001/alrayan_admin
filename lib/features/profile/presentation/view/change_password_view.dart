import 'package:alrayan_admin/features/profile/data/repo/profile_repo/profile_repo_impl.dart';
import 'package:alrayan_admin/features/profile/presentation/view/widgets/change_password_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/colors/colors.dart';
import '../../../../core/utils/services/remote_services/service_locator.dart';
import '../view_model/change_password/change_password_cubit.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return  AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor:AppColors.primarySwatchColor,
        systemNavigationBarColor: const Color(0xffE9F1FF),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: const ChangePasswordViewBody(),
      ),
    );
  }
}
