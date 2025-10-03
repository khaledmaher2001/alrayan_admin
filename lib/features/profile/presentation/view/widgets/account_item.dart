import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';

class AccountItem extends StatelessWidget {
  const AccountItem({super.key, required this.icon, required this.title, required this.onTap, this.isLogout=false});

  final String icon, title;
  final Function() onTap;
  final bool isLogout;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            width: AppConstants.width20(context),
            height: AppConstants.width20(context),
            color: isLogout?const Color(0xffC32B43): const Color(0xff0F0F0E),
          ),
          SizedBox(width: AppConstants.width10(context)),
          Expanded(
              child: Text(
            title,
            style: Styles.inter16500black(context),
          )),
          if(!isLogout)
          Icon(
            Icons.arrow_forward_ios_sharp,
            size: AppConstants.sp20(context),
            color: Color(0x80111111),
          ),
        ],
      ),
    );
  }
}
