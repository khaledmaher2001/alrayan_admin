import 'package:alrayan_admin/features/all_users/presentation/views/widgets/all_users_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/colors/colors.dart';
import '../../../../core/utils/services/remote_services/service_locator.dart';
import '../../data/repo/all_users_repo_impl.dart';
import '../view_models/get_all_users/get_all_users_cubit.dart';
class AllUsersView extends StatelessWidget {
  const AllUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.white,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      child: BlocProvider(
        create: (context) => GetAllUsersCubit(getIt<AllUsersRepoImpl>())..getAllUsers(data: {"page": 1,'limit': 12}),

        child: const Scaffold(
          body: AllUsersViewBody(),
        ),
      ),
    );
  }
}
