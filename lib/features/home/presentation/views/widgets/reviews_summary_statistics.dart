import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/home/data/models/home_statistics_model.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/review_summery_item.dart';
import 'package:alrayan_admin/features/reviews/presentation/view/reviews_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';

class ReviewsSummaryStatistic extends StatefulWidget {
  const ReviewsSummaryStatistic({super.key, required this.instance});

  final ReviewStats instance;

  @override
  State<ReviewsSummaryStatistic> createState() =>
      _ReviewsSummaryStatisticState();
}

class _ReviewsSummaryStatisticState extends State<ReviewsSummaryStatistic> {
  double calcPercentage(int? value, int total) {
    if (value == null || total == 0) return 0;
    return (value / total) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp20(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        border: Border.all(color: DsColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "i_customer_reviews_x_54".tr(namedArgs: {"a": "${widget.instance.totalReviews.toString()}"}),
                  style: Styles.inter16500black(context),
                ),
              ),
              InkWell(
                onTap: () {
                  NavigationUtils.navigateTo(
                    context: context,
                    destinationScreen: ReviewsView(),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.width15(context),
                    vertical: AppConstants.height10(context) / 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.shade50,
                    borderRadius: BorderRadius.circular(
                      AppConstants.sp5(context),
                    ),
                  ),
                  child: Text(
                    "s_view_details".tr(),
                    style: Styles.inter10400grey(
                      context,
                    ).copyWith(color: AppColors.primaryColor),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height10(context)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  RatingBar.builder(
                    initialRating: double.parse(
                      widget.instance.averageRating.toString(),
                    ),
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    ignoreGestures: true,
                    glowColor: const Color(0xFFF5A623),
                    itemPadding: EdgeInsetsDirectional.only(
                      end: AppConstants.width10(context),
                    ),
                    unratedColor: DsColor.border,
                    itemBuilder: (context, _) => SvgPicture.asset(
                      AssetData.star5,
                      color: Color(0xFFF5A623),
                    ),
                    itemSize: MediaQuery.of(context).size.width * 0.06,
                    onRatingUpdate: (rating) {},
                  ),
                  Row(
                    children: [
                      Text(
                        widget.instance.averageRating.toString(),
                        style: Styles.inter24600black(context),
                      ),
                      SizedBox(width: AppConstants.width5(context)),
                      Text(
                        "s_out_of_5_stars".tr(),
                        style: Styles.inter16500black(
                          context,
                        ).copyWith(color: AppColors.gray),
                      ),
                    ],
                  ),
                  SizedBox(height: AppConstants.height10(context)),
                ],
              ),
              SizedBox(height: AppConstants.height20(context)),
              ReviewSummeryItem(
                title: "s_excellent".tr(),
                percentage: calcPercentage(
                  widget.instance.ratingDistribution!.i5,
                  widget.instance.totalReviews!,
                ),
                main: const Color(0xFFF5A623),
                back: DsColor.fill,
              ),
              SizedBox(height: AppConstants.height20(context)),

              ReviewSummeryItem(
                title: "s_very_good".tr(),
                percentage: calcPercentage(
                  widget.instance.ratingDistribution!.i4,
                  widget.instance.totalReviews!,
                ),
                main: const Color(0xFFF5A623),
                back: DsColor.fill,
              ),
              SizedBox(height: AppConstants.height20(context)),

              ReviewSummeryItem(
                title: "s_average".tr(),
                percentage: calcPercentage(
                  widget.instance.ratingDistribution!.i3,
                  widget.instance.totalReviews!,
                ),
                main: const Color(0xFFF5A623),
                back: DsColor.fill,
              ),
              SizedBox(height: AppConstants.height20(context)),

              ReviewSummeryItem(
                title: "s_good".tr(),
                percentage: calcPercentage(
                  widget.instance.ratingDistribution!.i2,
                  widget.instance.totalReviews!,
                ),
                main: const Color(0xFFF5A623),
                back: DsColor.fill,
              ),
              SizedBox(height: AppConstants.height20(context)),

              ReviewSummeryItem(
                title: "s_fair".tr(),
                percentage: calcPercentage(
                  widget.instance.ratingDistribution!.i1,
                  widget.instance.totalReviews!,
                ),
                main: const Color(0xFFF5A623),
                back: DsColor.fill,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
