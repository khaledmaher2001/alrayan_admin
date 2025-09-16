import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/main_layout/view_model/change_nav_bar_status/change_nav_bar_status_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavBarItem extends StatelessWidget {
  const BottomNavBarItem({
    super.key,
    required this.icon,
    required this.index,
    required this.activeIcon,
    required this.title,
  });

  final String icon;
  final String activeIcon;
  final String title;
  final int index;

  @override
  Widget build(BuildContext context) {

    return Expanded(
      child: InkWell(
        onTap: (){
          context.read<ChangeNavBarStatusCubit>().changeNavBarIndex(index);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              ChangeNavBarStatusCubit.get(context).currentIndex == index
                  ? activeIcon
                  : icon,
              color:
              ChangeNavBarStatusCubit.get(context).currentIndex ==
                  index
                  ? AppColors.primaryColor
                  : null,
              width: MediaQuery.of(context).size.height * .03,
            ),
            SizedBox(height: AppConstants.height5(context)),
            Text(
              title,
              style: Styles.inter10500Primary(context).copyWith(
                color:
                ChangeNavBarStatusCubit.get(context).currentIndex ==
                    index
                    ? null
                    : const Color(0xffC8C8C8),
              ),
            ),
          ],
        )
      ),
    );
  }
}
