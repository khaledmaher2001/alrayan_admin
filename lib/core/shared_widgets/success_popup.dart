import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/assets/assets.dart';
import '../utils/constants.dart';
import '../utils/text_styles/styles.dart';

class SuccessPopup extends StatelessWidget {
  const SuccessPopup({
    super.key,
    required this.message,
    required this.title,
    required this.widget,
    this.icon,
    this.withWidget = false, this.iconColor,
  });

  final String title;
  final String message;
  final Widget widget;
  final String? icon;
  final Color? iconColor;
  final bool? withWidget;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: AlertDialog(

        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        ),
        shadowColor: Colors.white,
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: AppConstants.height30(context)),
              SvgPicture.asset(
                icon??AssetData.success,
                width: MediaQuery.of(context).size.width * .25,
                color: iconColor??null,
              ),
              SizedBox(height: AppConstants.height30(context)),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.width20(context),
                ),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: Styles.inter24600black(context),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppConstants.height5(context)),
                    Text(
                      message,
                      style: Styles.inter14600gray(context),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              if (withWidget!) ...[
                SizedBox(height: AppConstants.height20(context)),
                widget,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
