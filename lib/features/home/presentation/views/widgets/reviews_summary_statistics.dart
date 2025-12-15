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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "تقييمات العملاء ( ${widget.instance.totalReviews.toString()} ) تقييم",
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
                    "عرض التفاصيل",
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
                    glowColor: const Color(0xffF5BE00),
                    itemPadding: EdgeInsetsDirectional.only(
                      end: AppConstants.width10(context),
                    ),
                    unratedColor: Colors.grey[300],
                    itemBuilder: (context, _) => SvgPicture.asset(
                      AssetData.star5,
                      color: Color(0xffF5BE00),
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
                        "من 5 نجوم",
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
                title: "ممتاز",
                percentage: calcPercentage(
                  widget.instance.ratingDistribution!.i5,
                  widget.instance.totalReviews!,
                ),
                main: const Color(0xFF4CAF50),
                back: const Color(0xFFE8F5E9),
              ),
              SizedBox(height: AppConstants.height20(context)),

              ReviewSummeryItem(
                title: "جيد جدا",
                percentage: calcPercentage(
                  widget.instance.ratingDistribution!.i4,
                  widget.instance.totalReviews!,
                ),
                main: const Color(0xFF26A69A),
                back: const Color(0xFFE0F2F1),
              ),
              SizedBox(height: AppConstants.height20(context)),

              ReviewSummeryItem(
                title: "متوسط",
                percentage: calcPercentage(
                  widget.instance.ratingDistribution!.i3,
                  widget.instance.totalReviews!,
                ),
                main: const Color(0xFFFFC107),
                back: const Color(0xFFFFF8E1),
              ),
              SizedBox(height: AppConstants.height20(context)),

              ReviewSummeryItem(
                title: "جيد",
                percentage: calcPercentage(
                  widget.instance.ratingDistribution!.i2,
                  widget.instance.totalReviews!,
                ),
                main: const Color(0xFFFF9800),
                back: const Color(0xFFFFF3E0),
              ),
              SizedBox(height: AppConstants.height20(context)),

              ReviewSummeryItem(
                title: "مقبول",
                percentage: calcPercentage(
                  widget.instance.ratingDistribution!.i1,
                  widget.instance.totalReviews!,
                ),
                main: const Color(0xFFF44336),
                back: const Color(0xFFFFEBEE),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
