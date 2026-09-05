import 'package:alrayan_admin/features/ads/data/models/offer_banner_model.dart';
import 'package:alrayan_admin/features/ads/presentation/view_models/edit_banner/edit_banner_cubit.dart';
import 'package:alrayan_admin/features/ads/presentation/views/widgets/add_ads_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/services/remote_services/service_locator.dart';
import '../../data/repo/ads/ads_repo_impl.dart';
import '../view_models/add_new_ads_model/add_ads_cubit.dart';

class AddAdsView extends StatelessWidget {
  const AddAdsView({super.key, this.editingBanner});

  final Data? editingBanner;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AddAdsCubit(getIt<AdsRepoImpl>())),
          BlocProvider(create: (context) => EditBannerCubit(getIt<AdsRepoImpl>())),
        ],
        child: Scaffold(body: AddAdsViewBody(editingBanner: editingBanner)),
      ),
    );
  }
}
