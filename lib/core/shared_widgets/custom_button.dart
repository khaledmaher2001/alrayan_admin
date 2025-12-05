import 'package:flutter/material.dart';
import '../utils/colors/colors.dart';
import '../utils/constants.dart';

class DefaultButton extends StatelessWidget {
  final void Function()? onPress;
  final String text;
  final Widget? icon;
  final double? borderRadius;
  final double? height;
  final double? fontSize;
  final String? fontFamily;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final Color? surfaceTintColor;
  final Color? shadowColor;
  final bool hasBorder;
  final double? elevation;

  const DefaultButton({
    super.key,
    required this.onPress,
    required this.text,
    this.icon,
    this.borderRadius,
    this.height,
    this.fontFamily,
    this.fontSize,
    this.backgroundColor,
    this.textColor,
    this.hasBorder = false,
    this.borderColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryColor,
          surfaceTintColor:surfaceTintColor,
          shadowColor: shadowColor,
          elevation: elevation?? 3,
          padding: EdgeInsets.symmetric(vertical: height ?? AppConstants.height20(context)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ??0,
              ),
              side: BorderSide(color: hasBorder ? borderColor??AppColors.primaryColor: Colors.transparent)
          )),
      onPressed: onPress,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: icon!,
            ),
          ],
          Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize ?? MediaQuery.of(context).size.height*.02,
                  fontFamily: fontFamily??"Inter")),

        ],
      ),
    );
  }
}
