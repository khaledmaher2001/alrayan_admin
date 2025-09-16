import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/assets/assets.dart';
import '../utils/text_styles/styles.dart';

class CustomDropDownButton extends StatelessWidget {
  const CustomDropDownButton({
    required this.hintText,
    required this.onChanged,
    required this.items,
    super.key,
    required this.validator,
  this.onTap,
  this.height,
  this.hasBorder=true,
    this.borderRadius = 10,
  this.borderSideColor,
  this.borderSideEnabledColor,
    this.borderSideWidth = 1.0,  this.enabledBorderRadiusColor = Colors.grey,
    this.prefixIcon, required this.value,
  });

  final List<String>? items;
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final Function()? onTap;
  final String hintText;
  final String? value;
  final double? height;
  final double borderRadius;
  final double borderSideWidth;
  final Color enabledBorderRadiusColor;
  final Color? borderSideColor;
  final Color? borderSideEnabledColor;
  final bool hasBorder;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2(
      dropdownStyleData: DropdownStyleData(
        maxHeight: MediaQuery.of(context).size.height*.4,
      ),
      buttonStyleData:  ButtonStyleData(
        height:height?? AppConstants.height30(context)*1.8,
        padding: EdgeInsetsDirectional.only(end: AppConstants.width10(context)),
      ),
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        isDense: true,
        contentPadding: EdgeInsets.zero,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              borderRadius,
            ),
          ),
          borderSide: (!hasBorder)
              ? BorderSide.none
              : BorderSide(
            color: borderSideColor?? AppColors.primaryColor,
            width: borderSideWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              borderRadius,
            ),
          ),
          borderSide: (!hasBorder)
              ? BorderSide.none
              : BorderSide(
            color: borderSideColor?? AppColors.primaryColor,
            width: borderSideWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              borderRadius,
            ),
          ),
          borderSide: (!hasBorder)
              ? BorderSide.none
              : BorderSide(
            color: borderSideEnabledColor?? Colors.grey.shade300,
            width: borderSideWidth,
          ),
        ),
      ),
      isExpanded: true,
      value: value,
      hint: Text(
        hintText,
        style: Styles.hintText(context),
      ),
      items: items!
          .map((item) => DropdownMenuItem<String>(
                onTap: onTap,
                value: item.toString(),
                child: Text(
                  item.toString(),
                  style: Styles.inter14500black(context),
                ),
              ))
          .toList(),
      validator: validator,
      iconStyleData: IconStyleData(
        icon: SvgPicture.asset(AssetData.dropDown),
      ),
      onChanged: onChanged,
    );
  }
}
