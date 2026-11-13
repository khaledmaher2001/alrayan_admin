import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/main_layout/view_model/change_nav_bar_status/change_nav_bar_status_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_orders/get_orders_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_orders/get_orders_states.dart';
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
    this.showNewBadge = false,
    this.iconData,
  });

  /// Material icon used instead of the SVG pair (e.g. the "More" tab).
  final IconData? iconData;

  final String icon;
  final String activeIcon;
  final String title;
  final int index;

  /// Shows a small live dot on the icon — used for the Orders tab while
  /// there are new realtime orders that haven't been opened yet.
  final bool showNewBadge;

  @override
  Widget build(BuildContext context) {

    final selected = ChangeNavBarStatusCubit.get(context).currentIndex == index;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: title,
        excludeSemantics: true,
        child: InkWell(
        onTap: (){
          context.read<ChangeNavBarStatusCubit>().changeNavBarIndex(index);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                if (iconData != null)
                  Icon(iconData, color: selected ? AppColors.primaryColor : const Color(0xff8A8F98), size: MediaQuery.of(context).size.height * .03)
                else
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
                if (showNewBadge)
                  PositionedDirectional(
                    top: -2,
                    end: -4,
                    child: BlocBuilder<GetOrdersCubit, GetOrdersStates>(
                      builder: (context, state) {
                        final hasNew = context.read<GetOrdersCubit>().hasUnseenNewOrders;
                        if (!hasNew) return const SizedBox.shrink();
                        return Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppConstants.height5(context)),
            Text(
              title,
              style: Styles.inter10500Primary(context).copyWith(
                color:
                ChangeNavBarStatusCubit.get(context).currentIndex ==
                    index
                    ? null
                    : const Color(0xff8A8F98),
              ),
            ),
          ],
        )
      ),
      ),
    );
  }
}
