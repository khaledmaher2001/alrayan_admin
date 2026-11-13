import 'package:alrayan_admin/core/utils/helpers/staff_permissions.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/ads/presentation/view_models/offer_banner_cubit/offer_banner_cubit.dart';
import 'package:alrayan_admin/features/ads/presentation/views/add_ads_view.dart';
import 'package:alrayan_admin/features/ads/presentation/views/widgets/ads_view_body.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/services/remote_services/service_locator.dart';
import '../../data/repo/ads/ads_repo_impl.dart';
import '../view_models/delete_banner/delete_banner_cubit.dart';

class AdsView extends StatefulWidget {
  const AdsView({super.key});

  @override
  State<AdsView> createState() => _AdsViewState();
}

class _AdsViewState extends State<AdsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfferBannerCubit>().fetchOfferBanners();
    });
  }

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
        floatingActionButton: staffCan(context, 'banners.create')
            ? FloatingActionButton.extended(
                heroTag: "ads_add",
                onPressed: () => NavigationUtils.navigateTo(context: context, destinationScreen: const AddAdsView()),
                icon: const Icon(Icons.add_rounded),
                label: Text("s_add_ad".tr()),
              )
            : null,
        body: BlocProvider(
          create: (context) => DeleteBannersCubit(getIt<AdsRepoImpl>()),
          child: AdsViewBody(),
        ),
      ),
    );
  }
}
