import 'package:flutter/material.dart';

import '../colors/colors.dart';

abstract class Styles {
  static TextStyle bottomNavBarTitle(context) => TextStyle(
      fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Inter");

  static TextStyle DIN12500(context) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      );

  static TextStyle DIN16400(context) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: const Color(0xffDEE5ED),
        fontFamily: "Inter",
      );

  static TextStyle DIN16500(context) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      );

  static TextStyle DIN18500(context) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      );

  static TextStyle DIN20500(context) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        fontFamily: "Inter",
      );

  static TextStyle DIN24500(context) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        fontFamily: "Inter",
      );

  static TextStyle DIN13500(context) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: const Color(0xff6B7280),
        fontFamily: "Inter",
      );

  static TextStyle DIN48700(context) => TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: const Color(0xff166057),
        fontFamily: "Inter",
      );

  static TextStyle DIN16700(context) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xff4B5563),
        fontFamily: "Inter",
      );

  static TextStyle hintText(context) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xff6B7280),
        fontFamily: "Inter",
      );

  static TextStyle inter32500white(context) => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        fontFamily: "Inter",
      );
  static TextStyle inter24600black(context) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: const Color(0xff111827),
        fontFamily: "Inter",
      );
  static TextStyle inter28600black(context) => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: const Color(0xff111827),
        fontFamily: "Inter",
      );

  static TextStyle inter16400white(context) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        fontFamily: "Inter",
      );

  static TextStyle inter10500Primary(context) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryColor,
        fontFamily: "Inter",
      );

  static TextStyle inter12500Black(context) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: const Color(0xff111827),
        fontFamily: "Inter",
      );

  static TextStyle inter18500Black(context) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xff111827),
        fontFamily: "Inter",
      );

  static TextStyle inter12400Primary(context) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryColor,
        fontFamily: "Inter",
      );

  static TextStyle inter12600Black(context) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: const Color(0xff111827),
        fontFamily: "Inter",
      );

  static TextStyle inter8500(context) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: const Color(0xff0CDCF8),
        fontFamily: "Inter",
      );

  static TextStyle inter10400grey(context) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xff6B7280),
        fontFamily: "Inter",
      );

  static TextStyle inter14600black(context) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xff111827),
        fontFamily: "Inter",
      );
  static TextStyle inter14500black(context) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xff111827),
        fontFamily: "Inter",
      );
  static TextStyle inter14600gray(context) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.gray,
        fontFamily: "Inter",
      );

  static TextStyle inter16500black(context) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xff111827),
        fontFamily: "Inter",
      );
  static TextStyle DIN32700(context) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: Colors.black,
    fontFamily: "Inter",
  );
  static TextStyle font14500Grey900(context) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.greyColor[900],
    fontFamily: "Inter",
  );
  static TextStyle font16500Grey600(context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.greyColor[600],
    fontFamily: "Inter",
  );
  static TextStyle font16600Grey700(context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.greyColor[700],
    fontFamily: "Inter",
  );
  static TextStyle font16500Grey900(context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.greyColor[900],
     fontFamily: "Inter",
  );
  static TextStyle font16500Grey500(context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.greyColor[500],
    fontFamily: "Inter",
  );
  static TextStyle font16500Primary(context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryColor,
    fontFamily: "Inter",
  );
  static TextStyle font16600Grey900(context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.greyColor[900],
     fontFamily: "Inter",
  );
  static TextStyle font18500Grey900(context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.greyColor[900],
     fontFamily: "Inter",
  );
  static TextStyle font18600Grey900(context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.greyColor[900],
     fontFamily: "Inter",
  );
  static TextStyle font20600Grey900(context) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.greyColor[900],
     fontFamily: "Inter",
  );
  static TextStyle font20700Grey900(context) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.greyColor[900],
     fontFamily: "Inter",
  );

  static TextStyle font18500Primary(context) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryColor,
  );
}
