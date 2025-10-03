import 'package:flutter/material.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';

class ReviewSummeryItem extends StatelessWidget {
  const ReviewSummeryItem({super.key, required this.title, this.percentage, required this.main, required this.back});
final String title;
final Color main;
final Color back;
  final dynamic percentage;
  @override
  Widget build(BuildContext context) {
    return  Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width*.15,
          child: Text(title,style: Styles.inter16500black(context).copyWith(
              color: Colors.grey[600]
          )),
        ),
        SizedBox(width: AppConstants.width10(context)),
        Expanded(
          child: LinearProgressIndicator(
            backgroundColor: back,
            color: main,
            value:percentage* 0.01,
            minHeight: AppConstants.height10(context)-2,
            borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
          ),
        ),
      ],
    );
  }
}
