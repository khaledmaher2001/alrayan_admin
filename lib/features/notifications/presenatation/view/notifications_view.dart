import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/utils/helpers/staff_permissions.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/notification_navigation_handler.dart';
import 'package:alrayan_admin/features/scheduled_notifications/presentation/views/scheduled_notifications_view.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/features/notifications/presenatation/view/widgets/notification_item.dart';
import 'package:alrayan_admin/features/notifications/presenatation/view/widgets/notification_loading_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/colors/colors.dart';

import '../../../../core/shared_widgets/empty_widget.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../../core/utils/assets/assets.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/services/remote_services/service_locator.dart';
import '../../../../core/utils/text_styles/styles.dart';
import '../../data/repo/notifications_repo_impl.dart';
import '../view_model/get_notifications/get_notifications_cubit.dart';
import '../view_model/get_notifications/get_notifications_state.dart';
import '../view_model/mark_all_notifications_read/mark_all_notifications_read_cubit.dart';
import '../view_model/mark_all_notifications_read/mark_all_notifications_read_state.dart';
import '../view_model/read_mark_notifications/read_mark_notifications_cubit.dart';
import '../view_model/read_mark_notifications/read_mark_notifications_state.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  ScrollController scrollController = ScrollController();
  int selectedIndex = 0;

  void _onScroll() {
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<GetNotificationsCubit>().loadMore();
    }
  }

  @override
  void initState() {
    context.read<GetNotificationsCubit>().getNotifications();
    scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<GetNotificationsCubit>().getNotifications(withLoading: false);
        return true;
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                ReadMarkNotificationsCubit(getIt<NotificationsRepoImpl>()),
          ),
          BlocProvider(
            create: (context) =>
                MarkAllNotificationsReadCubit(getIt<NotificationsRepoImpl>()),
          ),
        ],
        child: Scaffold(
          backgroundColor: const Color(0xffF7F7F8),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: DsSpace.sm),
                Divider(color: DsColor.border, height: 1),
                BlocConsumer<MarkAllNotificationsReadCubit, MarkAllNotificationsReadState>(
                  listener: (context, state) {
                    if (state is MarkAllNotificationsReadSuccess) {
                      toast(text: "s_all_notifications_marked_as_read".tr(), color: DsColor.success);
                      context.read<GetNotificationsCubit>().getNotifications();
                    } else if (state is MarkAllNotificationsReadError) {
                      toast(text: state.error, color: AppColors.redColor);
                    }
                  },
                  builder: (context, markAllState) {
                    return BlocBuilder<GetNotificationsCubit, GetNotificationsState>(
                      builder: (context, state) {
                        final unreadCount = state is GetNotificationsSuccess
                            ? state.model.data?.unreadCount ?? 0
                            : 0;
                        if (unreadCount <= 0) return const SizedBox.shrink();

                        final isMarkingAll = markAllState is MarkAllNotificationsReadLoading;
                        return Padding(
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: AppConstants.width15(context),
                            vertical: AppConstants.height15(context),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "i_x_unread_notifications_65".tr(namedArgs: {"a": "${unreadCount}"}),
                                style: Styles.inter16500black(context),
                              ),
                              GestureDetector(
                                onTap: isMarkingAll
                                    ? null
                                    : () => context
                                        .read<MarkAllNotificationsReadCubit>()
                                        .markAllAsRead(),
                                child: isMarkingAll
                                    ? SizedBox(
                                        width: AppConstants.width15(context),
                                        height: AppConstants.width15(context),
                                        child: const CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "s_mark_all_read".tr(),
                                            style: Styles.inter14500black(context)
                                                .copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                                          ),
                                          SizedBox(width: AppConstants.width5(context)),
                                          Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primaryColor),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                Expanded(child:
                BlocBuilder<GetNotificationsCubit, GetNotificationsState>(
                    builder: (context, state) {
                      if (state is GetNotificationsSuccess) {
                        return Column(
                          children: [
                            Expanded(
                              child: BlocConsumer<ReadMarkNotificationsCubit,
                                  ReadMarkNotificationsState>(
                                  listener: (context, readState) {
                                    if (readState is ReadMarkNotificationsSuccess) {
                                      context
                                          .read<GetNotificationsCubit>()
                                          .notificationsList[selectedIndex]
                                          .recipients!
                                          .first
                                          .isRead = true;
                                    } else if (readState
                                    is ReadMarkNotificationsError) {
                                   cherryToast(text: readState.error,isSuccess: false, context: context);
                                    }
                                  }, builder: (context, readState) {
                                return context
                                    .read<GetNotificationsCubit>()
                                    .notificationsList
                                    .isNotEmpty
                                    ? ListView.separated(
                                  controller: scrollController,
                                  padding: EdgeInsetsDirectional.symmetric(
                                    horizontal: AppConstants.width15(context),
                                    vertical: AppConstants.height10(context),
                                  ),
                                  itemBuilder: (context, index) =>
                                      GestureDetector(
                                        onTap: () async {
                                          final item = context
                                              .read<GetNotificationsCubit>()
                                              .notificationsList[index];
                                          if ((item.recipients?.isNotEmpty ?? false) &&
                                              item.recipients!.first.isRead == false) {
                                            selectedIndex = index;
                                            // Awaited so the read lands before a
                                            // tab switch can pop this screen.
                                            await context
                                                .read<
                                                ReadMarkNotificationsCubit>()
                                                .readMarkNotification(
                                                notificationId: item.id!);
                                          }
                                          if (!context.mounted) return;
                                          // Same targets (and permission checks)
                                          // as tapping the push itself.
                                          NotificationNavigationHandler.handleRaw(
                                              item.navigationData?.raw);
                                        },
                                        child: NotificationItem(
                                          data: context
                                              .read<GetNotificationsCubit>()
                                              .notificationsList[index],
                                          index: index,
                                        ),
                                      ),
                                  itemCount: context
                                      .read<GetNotificationsCubit>()
                                      .notificationsList
                                      .length,
                                  separatorBuilder: (BuildContext context, int index) =>
                                      SizedBox(height: AppConstants.height15(context)),
                                )
                                    : EmptyWidget(
                                    icon: AssetData.bell,
                                    title: "s_no_notifications_yet".tr(),
                                    description:
                                    "s_notifications_appear_here_when_admin".tr()
                                        );
                              }),
                            ),
                            if (context
                                .read<GetNotificationsCubit>()
                                .isLoadingMore)
                              Padding(
                                padding:
                                EdgeInsets.all(AppConstants.sp10(context)),
                                child: Center(
                                  child: SizedBox(
                                    width: AppConstants.width20(context),
                                    height: AppConstants.width20(context),
                                    child: const CircularProgressIndicator(),
                                  ),
                                ),
                              )
                          ],
                        );
                      } else if (state is GetNotificationsError) {
                        return Center(
                            child: Text(
                              state.error,
                              style: Styles.inter14500black(context)
                                  .copyWith(color: AppColors.redColor),
                            ));
                      } else {
                        return NotificationLoadingItem();
                      }
                    })),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DsTopBar(
      title: "s_notifications".tr(),
      subtitle: "s_follow_incoming_notifications".tr(),
      actions: [
        // Staff-written pushes to customers (send now / schedule).
        if (staffCan(context, 'notifications.view'))
          Padding(
            padding: const EdgeInsetsDirectional.only(start: DsSpace.xs),
            child: DsIconButton(
              icon: Icons.campaign_outlined,
              label: "sn_title".tr(),
              onPressed: () => NavigationUtils.navigateTo(context: context, destinationScreen: const ScheduledNotificationsView()),
            ),
          ),
      ],
    );
  }
}
