import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'dart:async';

import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrayan_admin/features/ads/presentation/view_models/offer_banner_cubit/offer_banner_cubit.dart';
import 'package:alrayan_admin/features/ads/presentation/views/widgets/ads_item.dart';
import 'package:flutter/material.dart';

import '../../../../../core/shared_widgets/shimmer_helpers.dart';
import '../../../../../core/shared_widgets/toast.dart';
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
    final shouldDelete = await dsConfirm(
      context,
      title: "s_confirm_deletion".tr(),
      message: "s_are_you_sure_you_want_to_delete_this".tr(),
      confirmLabel: "s_delete".tr(),
      destructive: true,
    );

    if (shouldDelete && context.mounted) {
      context.read<DeleteBannersCubit>().deleteBanner(id: bannerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          DsTopBar(title: "s_ads_offers".tr()),
          const SizedBox(height: DsSpace.sm),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DsSpace.page),
            child: DsSearchField(hint: "s_search_ads".tr(), controller: searchController),
          ),
          const SizedBox(height: DsSpace.sm),
          Expanded(
            child: BlocListener<DeleteBannersCubit, DeleteBannersState>(
              listener: (context, state) {
                if (state is DeleteBannersLoaded) {
                  toast(text: state.message, color: DsColor.success);
                  context.read<OfferBannerCubit>().fetchOfferBanners();
                } else if (state is DeleteBannersError) {
                  toast(text: state.message, color: DsColor.danger);
                }
              },
              child: BlocBuilder<OfferBannerCubit, OfferBannerState>(
                builder: (context, state) {
                  final cubit = context.read<OfferBannerCubit>();

                  if (state is OfferBannerLoaded) {
                    if (state.banners.isEmpty) {
                      return DsMessage(
                        icon: cubit.search.isEmpty ? Icons.campaign_outlined : Icons.search_off_rounded,
                        title: cubit.search.isEmpty ? "s_no_ads_yet".tr() : "s_no_matching_ads".tr(),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<OfferBannerCubit>().fetchOfferBanners();
                      },
                      child: ListView.separated(
                        controller: scrollController,
                        // Bottom room so the FAB never covers the last card.
                        padding: const EdgeInsets.fromLTRB(DsSpace.page, DsSpace.xs, DsSpace.page, 96),
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
                          return const SizedBox(height: DsSpace.md);
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
          horizontal: DsSpace.page,
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
              border: Border.all(color: DsColor.border),
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
                Divider(color: DsColor.border, height: 1),
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
                      child: VerticalDivider(color: DsColor.border, width: 1),
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
