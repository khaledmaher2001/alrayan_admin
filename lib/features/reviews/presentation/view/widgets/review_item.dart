import 'package:alrayan_admin/features/reviews/data/models/reviews_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/shared_widgets/custom_button.dart';
import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';
import 'order_bottom_sheet.dart';

class ReviewItem extends StatelessWidget {
  const ReviewItem({super.key, required this.data, required this.index});

  final Items data;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp10(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1a000000),
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, 4)
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.065, // نصف عرض الصورة القديمة
                      backgroundColor: Colors.primaries[
                      index % Colors.primaries.length], // لون عشوائي لكل يوزر
                      child: Text(
                        (data.user!.fullName ?? '')
                            .split(' ')
                            .take(2)
                            .map((e) => e.isNotEmpty ? e[0] : '')
                            .join()
                            .toUpperCase(), // أول حرفين من الاسم
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(width: AppConstants.width10(context)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.user?.fullName ?? "", style: Styles.font16500Grey900(context)),
                        SizedBox(height: AppConstants.height5(context)),
                        RatingBar.builder(
                          initialRating: double.parse(data.rating.toString()),
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          ignoreGestures: true,
                          glowColor: const Color(0xffF5BE00),
                          itemPadding: EdgeInsetsDirectional.only(end: AppConstants.width5(context)),
                          unratedColor: AppColors.greyColor[300],
                          itemBuilder: (context, _) => SvgPicture.asset(AssetData.star),
                          itemSize: MediaQuery.of(context).size.width * 0.03,
                          onRatingUpdate: (rating) {},
                        ),
                        SizedBox(height: AppConstants.height5(context)),
                        Text(
                          DateFormat("yyyy/MM/dd").format(DateTime.parse(data.createdAt ?? "")),
                          style: Styles.font16500Grey500(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                child: DefaultButton(
                  onPress: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      isScrollControlled: true,
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
                      builder: (context) => Container(decoration: BoxDecoration(
                        color: Colors.white
                      ),child: OrderBottomSheet(orderId: data.order!.id!)),
                    );
                  },
                  text: "عرض الطلب".tr(),
                  borderRadius: AppConstants.sp10(context),
                  backgroundColor: Colors.white,
                  hasBorder: true,
                  fontSize: 14,
                  elevation: 0,
                  height: AppConstants.height10(context),
                  borderColor: AppColors.primaryColor,
                  textColor: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height10(context)),
          Text(data.comment ?? "", style: Styles.font16500Grey900(context)),
        ],
      ),
    );
  }
}
