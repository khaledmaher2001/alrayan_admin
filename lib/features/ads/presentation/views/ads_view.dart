import 'package:alrayan_admin/features/ads/presentation/views/widgets/ads_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/services/remote_services/service_locator.dart';
import '../../data/repo/ads/ads_repo_impl.dart';
import '../view_models/delete_banner/delete_banner_cubit.dart';

class AdsView extends StatelessWidget {
  const AdsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: BlocProvider(
          create: (context) => DeleteBannersCubit(getIt<AdsRepoImpl>()),
          child: AdsViewBody(),
        ),
      ),
    );
  }
}
