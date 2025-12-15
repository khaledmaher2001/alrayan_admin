import 'package:flutter/material.dart';

import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/navigation_utility.dart';

class CustomBottomSheetHeader extends StatelessWidget {
  const CustomBottomSheetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            NavigationUtils.navigateBack(context: context);
          },
          child: Container(
            padding: EdgeInsets.all(AppConstants.sp10(context)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xffE7E6F4)),
            ),
            child: const Icon(Icons.close),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.18,
          height: AppConstants.height5(context),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
              color: AppColors.greyColor[200]),
        ),
        Container(
          padding: EdgeInsets.all(AppConstants.sp10(context)),
          child: const Icon(Icons.close, color: Colors.transparent),
        ),
      ],
    );
  }
}
