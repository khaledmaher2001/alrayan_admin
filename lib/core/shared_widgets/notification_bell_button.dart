import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/notifications/presenatation/view/notifications_view.dart';
import 'package:alrayan_admin/features/notifications/presenatation/view_model/get_notifications/get_notifications_cubit.dart';
import 'package:alrayan_admin/features/notifications/presenatation/view_model/get_notifications/get_notifications_state.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/assets/assets.dart';
import '../utils/colors/colors.dart';
import '../utils/constants.dart';
import '../utils/text_styles/styles.dart';

class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key, this.backgroundColor = Colors.white});

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetNotificationsCubit, GetNotificationsState>(
      builder: (context, state) {
        final unreadCount = state is GetNotificationsSuccess
            ? state.model.data?.unreadCount ?? 0
            : 0;

        return GestureDetector(
          onTap: () {
            NavigationUtils.navigateTo(context: context, destinationScreen: const NotificationsView());
          },
          child: Container(
            height: AppConstants.width20(context) * 1.8,
            width: AppConstants.width20(context) * 1.8,
            padding: EdgeInsetsDirectional.all(AppConstants.sp5(context)),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
            ),
            child: Center(
              child: unreadCount > 0
                  ? badges.Badge(
                      badgeStyle: badges.BadgeStyle(badgeColor: AppColors.gray),
                      badgeContent: Text(
                        unreadCount.toString(),
                        style: Styles.inter16400white(context),
                      ),
                      position: badges.BadgePosition.topStart(top: -15),
                      child: SvgPicture.asset(
                        AssetData.bell,
                        fit: BoxFit.scaleDown,
                        color: AppColors.primaryColor,
                      ),
                    )
                  : SvgPicture.asset(AssetData.bell, fit: BoxFit.scaleDown, color: AppColors.primaryColor),
            ),
          ),
        );
      },
    );
  }
}
