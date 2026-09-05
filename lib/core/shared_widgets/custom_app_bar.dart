import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'notification_bell_button.dart';
import '../utils/assets/assets.dart';
import '../utils/colors/colors.dart';
import '../utils/constants.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.hasBack = false,
    this.withNotifications = true,
    this.textColor,
  });

  final String title;
  final bool? hasBack;
  final bool? withNotifications;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: "Inter",
                  color: textColor ?? Colors.white,
                  fontSize: MediaQuery.of(context).size.height * .018,
                ),
              ),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: hasBack!
                ? InkWell(
                    onTap: () {
                      NavigationUtils.navigateBack(context: context);
                    },
                    child: Container(
                      height: AppConstants.width20(context) * 2.2,
                      width: AppConstants.width20(context) * 2.2,
                      padding: EdgeInsets.all(AppConstants.sp5(context)),
                      decoration:  BoxDecoration(shape: BoxShape.circle, color: AppColors.gray.withOpacity(.2)),
                      child: RotatedBox(
                        quarterTurns: 2,
                        child: SvgPicture.asset(AssetData.back, color: Colors.black, fit: BoxFit.scaleDown),
                      ),
                    ),
                  )
                : Image.asset(
                    AssetData.logo,
                    height: AppConstants.width20(context) * 2.2,
                    width: AppConstants.width20(context) * 2.2,
                    color: Colors.white,
                  ),
          ),
          if (withNotifications!) ...[
            const Align(
              alignment: AlignmentDirectional.centerEnd,
              child: NotificationBellButton(),
            ),
          ],
        ],
      ),
    );
  }
}
