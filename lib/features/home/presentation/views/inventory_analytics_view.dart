import 'package:alrayan_admin/features/home/data/repo/home_repo_impl.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_inventory_analytics/get_inventory_analytics_cubit.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/inventory_analytics_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/services/remote_services/service_locator.dart';

class InventoryAnalyticsView extends StatelessWidget {
  const InventoryAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetInventoryAnalyticsCubit(getIt.get<HomeRepoImpl>())
            ..getInventoryAnalytics(),
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: const Scaffold(body: InventoryAnalyticsViewBody()),
      ),
    );
  }
}
