import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/ads/presentation/views/add_ads_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrayan_admin/features/ads/presentation/view_models/offer_banner_cubit/offer_banner_cubit.dart';
import 'package:alrayan_admin/features/ads/presentation/views/widgets/ads_item.dart';
import 'package:flutter/material.dart';

import '../../../../../core/shared_widgets/custom_app_bar.dart';
import '../../../../../core/shared_widgets/toast.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/text_styles/styles.dart';
import '../../view_models/delete_banner/delete_banner_cubit.dart';

class AdsViewBody extends StatelessWidget {
  const AdsViewBody({super.key});

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, {
        required int bannerId,
      }) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "تأكيد الحذف",
            style: Styles.inter24600black(context),
          ),
          content: Text(
            "هل أنت متأكد أنك تريد حذف الإعلان؟",
            style: Styles.font18500Grey900(context),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.sp10(dialogContext),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(
                "إلغاء",
                style: Styles.inter18500Black(context),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redColor,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(
                "حذف",
                style: Styles.inter16400white(context),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      context.read<DeleteBannersCubit>().deleteBanner(id: bannerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: AppConstants.height20(context)),
          CustomAppBar(
            title: "الاعلانات والعروض",
            textColor: Colors.black,
            hasBack: true,
            withNotifications: false,
          ),
          SizedBox(height: AppConstants.height20(context)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.width20(context),
              ),
              child: BlocListener<DeleteBannersCubit, DeleteBannersState>(
                listener: (context, state) {
                  if (state is DeleteBannersLoaded) {
                    toast(text: state.message, color: Colors.green);
                    context.read<OfferBannerCubit>().fetchOfferBanners(
                      withLoading: false,
                    );
                  } else if (state is DeleteBannersError) {
                    toast(text: state.message, color: AppColors.redColor);
                  }
                },
                child: BlocBuilder<OfferBannerCubit, OfferBannerState>(
                  builder: (context, state) {
                    if (state is OfferBannerLoaded) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<OfferBannerCubit>().fetchOfferBanners();
                        },
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            final banner = state.banners[index];

                            return AdsItem(
                              instance: banner,
                              onDeleteTap: () async {
                                await _showDeleteConfirmationDialog(
                                  context,
                                  bannerId: banner.id!,
                                );
                              },
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              height: AppConstants.height15(context),
                            );
                          },
                          itemCount: state.banners.length,
                        ),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: AppConstants.height20(context)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.width20(context),
            ),
            child: DefaultButton(
              onPress: () {
                NavigationUtils.navigateTo(
                  context: context,
                  destinationScreen: AddAdsView(),
                );
              },
              text: "اضافة اعلان او عرض",
              borderRadius: AppConstants.sp10(context),
            ),
          ),
          SizedBox(height: AppConstants.height20(context)),
        ],
      ),
    );
  }
}