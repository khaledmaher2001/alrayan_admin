import 'package:flutter/material.dart';

import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';


class ReviewSummeryItem extends StatelessWidget {
  const ReviewSummeryItem({super.key, required this.title, this.percentage});
final String title;
  final dynamic percentage;
  @override
  Widget build(BuildContext context) {
    return  Row(
      children: [
        Text(title,style: Styles.font16600Grey700(context).copyWith(
            color: AppColors.greyColor[600]
        )),
        SizedBox(width: AppConstants.width10(context)),
        Expanded(
          flex: 4,
          child: LinearProgressIndicator(
            backgroundColor: const Color(0xffD9D9D9),
            color: AppColors.primaryColor,
            value:percentage* 0.01,
            minHeight: AppConstants.height10(context)-2,
            borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
          ),
        ),
        SizedBox(width: AppConstants.width10(context)),
        Expanded(
          flex: 1,
          child: Text("${percentage.toStringAsFixed(0)}%",style: Styles.font16600Grey700(context).copyWith(
              color: AppColors.primaryColor[400]
          )),
        ),
      ],
    );
  }
}
