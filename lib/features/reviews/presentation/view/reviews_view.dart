import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/features/reviews/presentation/view/widgets/review_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/shared_widgets/custom_loading_item.dart';
import '../../../../core/utils/assets/assets.dart';
import '../../../../core/utils/colors/colors.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/text_styles/styles.dart';
import '../../../home/presentation/views/widgets/review_summery_item.dart';
import '../view_model/get_reviews/get_reviews_cubit.dart';
import '../view_model/get_reviews_summery/get_reviews_summery_cubit.dart';

class ReviewsView extends StatefulWidget {
  const ReviewsView({super.key});

  @override
  State<ReviewsView> createState() => _ReviewsViewState();
}

class _ReviewsViewState extends State<ReviewsView> {
  final ScrollController scrollController = ScrollController();
  bool isLoading = false;
  int page = 1;

  /// -------- Helpers --------
  double calcPercentage(int? value, int total) {
    if (value == null || total == 0) return 0;
    return (value / total) * 100;
  }

  void pagination() async {
    final cubit = context.read<GetReviewsCubit>();
    final totalPages = cubit.reviewsModel?.data?.metadata?.totalPages ?? 1;

    if (page < totalPages &&
        scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
      setState(() {
        isLoading = true;
        page++;
      });

      await cubit.getReviews(page: page, withLoading: false);

      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(pagination);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: AppConstants.height20(context)),
            CustomAppBar(title: "تقييمات العملاء".tr(),textColor: Colors.black,withNotifications: false,hasBack: true,),
            SizedBox(height: AppConstants.height30(context)),
            Expanded(
              child: Padding(
                padding:
                EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          page = 1;
                          await context
                              .read<GetReviewsSummeryCubit>()
                              .getReviewsSummery();
                          await context.read<GetReviewsCubit>().getReviews(page: 1);
                        },
                        child: SingleChildScrollView(
                          controller: scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// -------- Reviews Summery --------
                              BlocBuilder<GetReviewsSummeryCubit,
                                  GetReviewsSummeryState>(
                                builder: (context, state) {
                                  if (state is GetReviewsSummerySuccessState) {
                                    final summery = state.summeryModel;
                                    final totalReviews =
                                        summery.data!.totalReviews ?? 0;
                                    final distribution =
                                        summery.data!.ratingDistribution;
                                    final averageRating =
                                    (summery.data!.averageRating ?? 0).toDouble();

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("reviews_and_comment".tr(),
                                            style: Styles.font20600Grey900(context)),
                                        SizedBox(
                                            height:
                                            AppConstants.height10(context)),

                                        Text(
                                          averageRating.toString(),
                                          style: Styles.font20700Grey900(context)
                                              .copyWith(
                                              fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                                  .064),
                                        ),

                                        SizedBox(
                                            height:
                                            AppConstants.height10(context)),

                                        RatingBar.builder(
                                          initialRating: averageRating,
                                          itemCount: 5,
                                          ignoreGestures: true,
                                          allowHalfRating: true,
                                          glowColor: const Color(0xffF5BE00),
                                          itemPadding: EdgeInsetsDirectional.only(
                                              end:
                                              AppConstants.width10(context)),
                                          unratedColor:
                                          AppColors.greyColor[300],
                                          itemBuilder: (_, __) =>
                                              SvgPicture.asset(AssetData.star),
                                          itemSize: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.06,
                                          onRatingUpdate: (_) {},
                                        ),

                                        SizedBox(
                                            height:
                                            AppConstants.height10(context)),

                                        Text(
                                          "$totalReviews ${"reviews_count".tr()}",
                                          style: Styles.font18500Grey900(context)
                                              .copyWith(
                                              color:
                                              AppColors.greyColor[600]),
                                        ),

                                        SizedBox(
                                            height:
                                            AppConstants.height15(context)),

                                        ReviewSummeryItem(
                                          title: "5_stars".tr(),
                                          percentage: calcPercentage(
                                              distribution?.i5, totalReviews),
                                          main: const Color(0xFF4CAF50),
                                          back: const Color(0xFFE8F5E9),
                                        ),
                                        SizedBox(
                                            height:
                                            AppConstants.height20(context)),

                                        ReviewSummeryItem(
                                          title: "4_stars".tr(),
                                          percentage: calcPercentage(
                                              distribution?.i4, totalReviews),
                                          main: const Color(0xFF26A69A),
                                          back: const Color(0xFFE0F2F1),
                                        ),
                                        SizedBox(
                                            height:
                                            AppConstants.height20(context)),

                                        ReviewSummeryItem(
                                          title: "3_stars".tr(),
                                          percentage: calcPercentage(
                                              distribution?.i3, totalReviews),
                                          main: const Color(0xFFFFC107),
                                          back: const Color(0xFFFFF8E1),
                                        ),
                                        SizedBox(
                                            height:
                                            AppConstants.height20(context)),

                                        ReviewSummeryItem(
                                          title: "2_stars".tr(),
                                          percentage: calcPercentage(
                                              distribution?.i2, totalReviews),
                                          main: const Color(0xFFFF9800),
                                          back: const Color(0xFFFFF3E0),
                                        ),
                                        SizedBox(
                                            height:
                                            AppConstants.height20(context)),

                                        ReviewSummeryItem(
                                          title: "1_stars".tr(),
                                          percentage: calcPercentage(
                                              distribution?.i1, totalReviews),
                                          main: const Color(0xFFF44336),
                                          back: const Color(0xFFFFEBEE),
                                        ),
                                      ],
                                    );
                                  }
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("reviews_and_comment".tr(), style: Styles.font20600Grey900(context)),
                                      SizedBox(height: AppConstants.height10(context)),
                                      Text("0",
                                          style: Styles.font20700Grey900(context)
                                              .copyWith(fontSize: MediaQuery.of(context).size.height * .064)),
                                      SizedBox(height: AppConstants.height10(context)),
                                      RatingBar.builder(
                                        initialRating: double.parse("0"),
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        ignoreGestures: true,
                                        glowColor: const Color(0xffF5BE00),
                                        itemPadding: EdgeInsetsDirectional.only(end: AppConstants.width10(context)),
                                        unratedColor: AppColors.greyColor[300],
                                        itemBuilder: (context, _) => SvgPicture.asset(AssetData.star),
                                        itemSize: MediaQuery.of(context).size.width * 0.06,
                                        onRatingUpdate: (rating) {},
                                      ),
                                      SizedBox(height: AppConstants.height10(context)),
                                      Text("0 ${"reviews_count".tr()}",
                                          style: Styles.font18500Grey900(context).copyWith(color: AppColors.greyColor[600])),
                                      SizedBox(height: AppConstants.height15(context)),
                                      ReviewSummeryItem(
                                          title: "5_stars".tr(),
                                          percentage: 0,
                                          back:Color(0xffD9D9D9), main: Color(0xffD9D9D9),
                                      ),
                                      SizedBox(height: AppConstants.height20(context)),
                                      ReviewSummeryItem(
                                        title: "4_stars".tr(),
                                        percentage: 0,
                                        back:Color(0xffD9D9D9), main: Color(0xffD9D9D9),
                                      ),
                                      SizedBox(height: AppConstants.height20(context)),
                                      ReviewSummeryItem(
                                        title: "3_stars".tr(),
                                        percentage: 0,
                                        back:Color(0xffD9D9D9), main: Color(0xffD9D9D9),
                                      ),
                                      SizedBox(height: AppConstants.height20(context)),
                                      ReviewSummeryItem(
                                        title: "2_stars".tr(),
                                        percentage: 0,
                                        back:Color(0xffD9D9D9), main: Color(0xffD9D9D9),
                                      ),
                                      SizedBox(height: AppConstants.height20(context)),
                                      ReviewSummeryItem(
                                        title: "1_stars".tr(),
                                        percentage: 0,
                                        back:Color(0xffD9D9D9), main: Color(0xffD9D9D9),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              SizedBox(
                                  height: AppConstants.height20(context) * 2),

                              Text("individual_ratings".tr(),
                                  style: Styles.font20600Grey900(context)),
                              SizedBox(height: AppConstants.height30(context)),
                              BlocBuilder<GetReviewsCubit, GetReviewsState>(
                                builder: (context, state) {
                                  if (state is GetReviewsSuccessState) {
                                    final reviews = context
                                        .read<GetReviewsCubit>()
                                        .allReviewsList;

                                    if (reviews.isEmpty) {
                                      return Center(
                                        child: Text(
                                          "no_reviews".tr(),
                                          style:
                                          Styles.font18500Grey900(context),
                                        ),
                                      );
                                    }

                                    return ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                      const NeverScrollableScrollPhysics(),
                                      itemCount: reviews.length,
                                      itemBuilder: (_, index) => ReviewItem(
                                        data: reviews[index],
                                        index: index,
                                      ),
                                      separatorBuilder: (_, __) => Column(
                                        children: [
                                          SizedBox(
                                              height:
                                              AppConstants.height10(context)),
                                          Divider(
                                              color:
                                              AppColors.greyColor[200]),
                                          SizedBox(
                                              height:
                                              AppConstants.height10(context)),
                                        ],
                                      ),
                                    );
                                  }
                                  return const CustomLoadingItem(size: 30);
                                },
                              ),

                              SizedBox(height: AppConstants.height20(context)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (isLoading)
                      Padding(
                        padding: EdgeInsets.all(AppConstants.sp15(context)),
                        child:
                        CustomLoadingItem(size: AppConstants.sp30(context)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
