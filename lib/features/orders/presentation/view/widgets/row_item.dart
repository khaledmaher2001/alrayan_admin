import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:flutter/material.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';
class RowItem extends StatelessWidget {
  const RowItem({super.key, required this.value, required this.title, this.discount=false, this.valueColor, this.titleColor, this.fontWeight});
  final String value;
  final String title;
  final bool? discount;
  final Color? valueColor;
  final Color? titleColor;
  final FontWeight? fontWeight;
  @override
  Widget build(BuildContext context) {
    return  Row(
      children: [
        Expanded(child: Text(title,style: Styles.inter14500black(context).copyWith(
            color: discount==true?AppColors.redColor: titleColor??Color(0xff9CA4AB),
          fontWeight: fontWeight,
        ),)),
        SizedBox(width: AppConstants.width5(context),),
        Text(discount==true?"- $value":value,style: Styles.inter14500black(context).copyWith(
          color: discount==true?AppColors.redColor:valueColor??Colors.black,
          fontWeight: fontWeight,
        ),),
      ],
    );
  }
}
