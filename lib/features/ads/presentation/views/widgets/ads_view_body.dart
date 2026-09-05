import 'dart:async';

import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/ads/presentation/views/add_ads_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrayan_admin/features/ads/presentation/view_models/offer_banner_cubit/offer_banner_cubit.dart';
import 'package:alrayan_admin/features/ads/presentation/views/widgets/ads_item.dart';
import 'package:flutter/material.dart';

import '../../../../../core/shared_widgets/custom_app_bar.dart';
import '../../../../../core/shared_widgets/shimmer_helpers.dart';
import '../../../../../core/shared_widgets/toast.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/text_styles/styles.dart';
import '../../view_models/delete_banner/delete_banner_cubit.dart';

class AdsViewBody extends StatefulWidget {
  const AdsViewBody({super.key});

  @override
  State<AdsViewBody> createState() => _AdsViewBodyState();
}

class _AdsViewBodyState extends State<AdsViewBody> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  Timer? _searchDebounce;
  bool isLoading = false;

  Future<void> pagination() async {
    final cubit = context.read<OfferBannerCubit>();
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 80 &&
        cubit.hasMore &&
        !isLoading) {
      setState(() => isLoading = true);
      await cubit.loadMore();
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      context
          .read<OfferBannerCubit>()
          .fetchOfferBanners(search: searchController.text);
    });
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(pagination);
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    scrollController.removeListener(pagination);
    scrollController.dispose();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

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
          SizedBox(height: AppConstants.height15(context)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
            child: TextField(
              controller: searchController,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                isDense: true,
                hintText: "ابحث في الإعلانات",
                hintStyle: Styles.inter14600gray(context),
                prefixIcon: Icon(Icons.search, color: AppColors.gray),
                filled: true,
                fillColor: AppColors.gray.withOpacity(.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(height: AppConstants.height15(context)),
          Expanded(
            child: BlocListener<DeleteBannersCubit, DeleteBannersState>(
              listener: (context, state) {
                if (state is DeleteBannersLoaded) {
                  toast(text: state.message, color: Colors.green);
                  context.read<OfferBannerCubit>().fetchOfferBanners();
                } else if (state is DeleteBannersError) {
                  toast(text: state.message, color: AppColors.redColor);
                }
              },
              child: BlocBuilder<OfferBannerCubit, OfferBannerState>(
                builder: (context, state) {
                  final cubit = context.read<OfferBannerCubit>();

                  if (state is OfferBannerLoaded) {
                    if (state.banners.isEmpty) {
                      return Center(
                        child: Text(
                          cubit.search.isEmpty
                              ? "لا توجد إعلانات حتى الآن"
                              : "لا توجد إعلانات مطابقة",
                          style: Styles.inter14600gray(context),
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<OfferBannerCubit>().fetchOfferBanners();
                      },
                      child: ListView.separated(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.width20(context),
                          vertical: AppConstants.height10(context),
                        ),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          if (index == state.banners.length) {
                            return isLoading
                                ? Padding(
                                    padding: EdgeInsets.all(
                                      AppConstants.sp10(context),
                                    ),
                                    child: CustomLoadingItem(
                                      size: MediaQuery.of(context).size.width *
                                          .08,
                                    ),
                                  )
                                : const SizedBox.shrink();
                          }

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
                        itemCount:
                            state.banners.length + (cubit.hasMore ? 1 : 0),
                      ),
                    );
                  } else {
                    return const _AdsShimmer();
                  }
                },
              ),
            ),
          ),
          SizedBox(height: AppConstants.height15(context)),
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
              icon: const Icon(Icons.add, color: Colors.white),
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

class _AdsShimmer extends StatelessWidget {
  const _AdsShimmer();

  @override
  Widget build(BuildContext context) {
    final imageSize = MediaQuery.of(context).size.width * .22;

    return appShimmer(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.width20(context),
          vertical: AppConstants.height10(context),
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) => SizedBox(height: AppConstants.height15(context)),
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(AppConstants.sp15(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 3),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          shimmerBox(context, width: 80, height: AppConstants.height20(context), radius: AppConstants.sp5(context)),
                          SizedBox(height: AppConstants.height10(context)),
                          shimmerBox(context, width: double.infinity, height: AppConstants.height15(context)),
                          SizedBox(height: AppConstants.height5(context)),
                          shimmerBox(context, width: double.infinity, height: AppConstants.height10(context)),
                          SizedBox(height: AppConstants.height5(context)),
                          shimmerBox(context, width: MediaQuery.of(context).size.width * .35, height: AppConstants.height10(context)),
                          SizedBox(height: AppConstants.height10(context)),
                          Row(
                            children: [
                              shimmerCircle(size: 14),
                              SizedBox(width: AppConstants.width5(context)),
                              Expanded(
                                child: shimmerBox(context, width: double.infinity, height: AppConstants.height10(context)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppConstants.width10(context)),
                    shimmerBox(context, width: imageSize, height: imageSize, radius: AppConstants.sp10(context)),
                  ],
                ),
                SizedBox(height: AppConstants.height15(context)),
                Divider(color: Colors.grey.shade300, height: 1),
                SizedBox(height: AppConstants.height5(context)),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: AppConstants.height10(context) - 2),
                        child: Center(
                          child: shimmerBox(context, width: 50, height: AppConstants.height15(context)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: AppConstants.height20(context) * 1.2,
                      child: VerticalDivider(color: Colors.grey.shade300, width: 1),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: AppConstants.height10(context) - 2),
                        child: Center(
                          child: shimmerBox(context, width: 50, height: AppConstants.height15(context)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
