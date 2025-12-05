import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/ads/presentation/views/add_ads_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrayan_admin/features/ads/presentation/view_models/offer_banner_cubit/offer_banner_cubit.dart';
import 'package:alrayan_admin/features/ads/presentation/views/widgets/ads_item.dart';
import 'package:flutter/material.dart';

import '../../../../../core/shared_widgets/custom_app_bar.dart';

class AdsViewBody extends StatelessWidget {
  const AdsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: AppConstants.height20(context),),
          CustomAppBar(
            title: "الاعلانات والعروض",
            textColor: Colors.black,
            hasBack: true,
            withNotifications: false,
          ),
          SizedBox(height: AppConstants.height20(context),),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.width20(context)),
              child: BlocBuilder<OfferBannerCubit, OfferBannerState>(
                  builder: (context, state) {
                    if (state is OfferBannerLoaded) {
                      return ListView.separated(
                        itemBuilder: (BuildContext context, int index) {
                          return AdsItem(instance:state.banners[index]);
                        }, separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(height: AppConstants.height15(context),);
                      }, itemCount: state.banners.length,);
                    } else {
                      return const Center(child: CircularProgressIndicator(),);
                    }
                  }
              ),
            ),
          ),
          SizedBox(height: AppConstants.height20(context),),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppConstants.width20(context)),
            child: DefaultButton(onPress: (){
              NavigationUtils.navigateTo(context: context, destinationScreen: AddAdsView());
            }, text: "اضافة اعلان او عرض",
              borderRadius: AppConstants.sp10(context),
            ),
          ),
          SizedBox(height: AppConstants.height20(context),),

        ],
      ),
    );
  }
}
