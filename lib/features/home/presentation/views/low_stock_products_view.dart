import 'package:alrayan_admin/features/home/data/repo/home_repo_impl.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_low_stock_products/get_low_stock_products_cubit.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/low_stock_products_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/services/remote_services/service_locator.dart';

class LowStockProductsView extends StatelessWidget {
  const LowStockProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetLowStockProductsCubit(getIt.get<HomeRepoImpl>())
            ..getLowStockProducts(),
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: const Scaffold(body: LowStockProductsViewBody()),
      ),
    );
  }
}
