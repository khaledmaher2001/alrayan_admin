import 'package:alrayan_admin/features/home/data/repo/home_repo_impl.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_low_stock_config/get_low_stock_config_cubit.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/update_low_stock_config/update_low_stock_config_cubit.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/low_stock_settings_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/services/remote_services/service_locator.dart';

class LowStockSettingsView extends StatelessWidget {
  const LowStockSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              GetLowStockConfigCubit(getIt.get<HomeRepoImpl>())
                ..getLowStockConfig(),
        ),
        BlocProvider(
          create: (context) =>
              UpdateLowStockConfigCubit(getIt.get<HomeRepoImpl>()),
        ),
      ],
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          systemNavigationBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: const Scaffold(body: LowStockSettingsViewBody()),
      ),
    );
  }
}
