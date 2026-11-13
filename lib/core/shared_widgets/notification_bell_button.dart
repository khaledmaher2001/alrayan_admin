import 'package:easy_localization/easy_localization.dart';
import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/notifications/presenatation/view/notifications_view.dart';
import 'package:alrayan_admin/features/notifications/presenatation/view_model/get_notifications/get_notifications_cubit.dart';
import 'package:alrayan_admin/features/notifications/presenatation/view_model/get_notifications/get_notifications_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


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

        // 48dp bordered icon button; unread count as a small accent pill.
        return Stack(
          clipBehavior: Clip.none,
          children: [
            DsIconButton(
              icon: Icons.notifications_none_rounded,
              label: "s_notifications".tr(),
              onPressed: () => NavigationUtils.navigateTo(context: context, destinationScreen: const NotificationsView()),
            ),
            if (unreadCount > 0)
              PositionedDirectional(
                top: 2,
                end: 2,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(color: DsColor.accent, borderRadius: BorderRadius.circular(9), border: Border.all(color: Colors.white, width: 1.5)),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
