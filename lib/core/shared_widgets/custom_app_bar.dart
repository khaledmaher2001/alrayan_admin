import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/notifications/presenatation/view/notifications_view.dart';
import 'package:alrayan_admin/features/notifications/presenatation/view_model/get_notifications/get_notifications_state.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/notifications/presenatation/view_model/get_notifications/get_notifications_cubit.dart';
import '../utils/assets/assets.dart';
import '../utils/colors/colors.dart';
import '../utils/constants.dart';
import '../utils/text_styles/styles.dart';

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
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: BlocBuilder<GetNotificationsCubit, GetNotificationsState>(
                builder: (context, state) {
                  if (state is GetNotificationsSuccess) {
                    return GestureDetector(
                      onTap: () {
                        NavigationUtils.navigateTo(context: context, destinationScreen: const NotificationsView());
                      },
                      child: Container(
                        height: AppConstants.width20(context) * 1.8,
                        width: AppConstants.width20(context) * 1.8,
                        padding: EdgeInsetsDirectional.all(AppConstants.sp5(context)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
                        ),
                        child: Center(
                          child: badges.Badge(
                            badgeStyle: badges.BadgeStyle(badgeColor: AppColors.gray),
                            badgeContent: Text(
                              state.model.data!.unreadCount.toString(),
                              style: Styles.inter16400white(context),
                            ),
                            position: badges.BadgePosition.topStart(top: -15),
                            child: SvgPicture.asset(
                              AssetData.bell,
                              fit: BoxFit.scaleDown,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return GestureDetector(
                      onTap: () {
                        NavigationUtils.navigateTo(context: context, destinationScreen: const NotificationsView());
                      },
                      child: Container(
                        height: AppConstants.width20(context) * 2.2,
                        width: AppConstants.width20(context) * 2.2,
                        padding: EdgeInsetsDirectional.all(AppConstants.sp5(context)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
                        ),
                        child: SvgPicture.asset(AssetData.bell, fit: BoxFit.scaleDown, color: AppColors.primaryColor),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
