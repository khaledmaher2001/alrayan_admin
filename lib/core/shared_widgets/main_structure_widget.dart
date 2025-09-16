import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/assets/assets.dart';
import '../utils/constants.dart';
import '../utils/navigation_utility.dart';
import '../utils/text_styles/styles.dart';

class MainStructureWidget extends StatelessWidget {
  const MainStructureWidget({
    super.key,
    required this.title,
    this.withBack = true,
    required this.widget,
  });

  final String title;
  final bool? withBack;
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: AppConstants.height20(context)),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.width20(context),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Styles.inter24600black(
                    context,
                  ).copyWith(color: Colors.white),
                ),
              ),
              SizedBox(width: AppConstants.width20(context)),
              if (withBack!)
                InkWell(
                  onTap: () {
                    NavigationUtils.navigateBack(context: context);
                  },
                  child: Container(
                    
                    padding: EdgeInsets.all(AppConstants.sp10(context)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle
                    ),
                    child: SvgPicture.asset(
                      AssetData.back,
                      width: MediaQuery.of(context).size.width * .05,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: AppConstants.height20(context)),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(AppConstants.sp10(context)),
            decoration: BoxDecoration(
              borderRadius: BorderRadiusDirectional.vertical(
                top: Radius.circular(AppConstants.sp30(context)),
              ),
              color: Colors.white,
            ),
            child: widget,
          ),
        ),
      ],
    );
  }
}
