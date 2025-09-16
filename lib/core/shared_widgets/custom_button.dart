import 'package:flutter/material.dart';
import '../utils/colors/colors.dart';
import '../utils/constants.dart';

class DefaultButton extends StatelessWidget {
  void Function()? onPress;
  String text;
  Widget? icon;
  double? borderRadius;
  double? height;
  double? fontSize;
  String? fontFamily;
  Color? backgroundColor;
  Color? textColor;
  Color? surfaceTintColor;
  Color? shadowColor;
  bool hasBorder;
  double? elevation;

  DefaultButton({
    Key? key,
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
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor
  }) : super(key: key);

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
            side: BorderSide(color: hasBorder ? AppColors.primaryColor: Colors.transparent)
          )),
      onPressed: onPress,
      child: Stack(
        children: [
          if (icon != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: icon!,
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize ?? MediaQuery.of(context).size.height*.02,
                      fontFamily: fontFamily??"Inter")),
            ],
          ),

        ],
      ),
    );
  }
}
