import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:flutter/material.dart';

import '../utils/assets/assets.dart';
import '../utils/constants.dart';
import '../utils/text_styles/styles.dart';

class AuthLogoWidget extends StatelessWidget {
  const AuthLogoWidget({super.key, required this.title, required this.description});
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          AssetData.logo,
          width: MediaQuery.of(context).size.width * .5,
          height: MediaQuery.of(context).size.width * .5,
          color: AppColors.primaryColor,
        ),
        SizedBox(height: AppConstants.height10(context),),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,style: Styles.inter24600black(context),),
          ],
        ),
        SizedBox(height: AppConstants.height20(context),),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)*2),
          child: Text(description,textAlign: TextAlign.center,style: Styles.inter14600gray(context),),
        ),
      ],
    );
  }
}
