import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';
class StatisticsHomeItem extends StatelessWidget {
  const StatisticsHomeItem({super.key, required this.icon, required this.title, required this.value});
  final String icon;
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(AppConstants.sp10(context)),
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
            ]
        ),
        child: Column(
          children: [
            SvgPicture.asset(icon,width: MediaQuery.of(context).size.width*.1,),
            SizedBox(height: AppConstants.height10(context),),
            Text(title,style: Styles.inter12400Primary(context).copyWith(
              color: AppColors.gray
            ),),
            SizedBox(height: AppConstants.height5(context),),
            Text(value,style: Styles.inter14500black(context).copyWith(
              fontWeight: FontWeight.w600
            ),),
          ],
        ),
      ),
    );
  }
}
