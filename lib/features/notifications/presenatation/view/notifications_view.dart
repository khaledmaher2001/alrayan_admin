import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
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
  bool isLoading = false;
  int selectedIndex = 0;

  pagination() async {
    if (context.read<GetNotificationsCubit>().page <
        context
            .read<GetNotificationsCubit>()
            .notificationsModel!
            .data!
            .metadata!
            .totalPages! &&
        scrollController.position.maxScrollExtent ==
            scrollController.position.pixels) {
      setState(() {
        isLoading = true;
        context.read<GetNotificationsCubit>().page++;
      });
      await context
          .read<GetNotificationsCubit>()
          .getNotifications(withLoading: false);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    context.read<GetNotificationsCubit>().getNotifications();
    scrollController.addListener(pagination);
    super.initState();
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
                SizedBox(height: AppConstants.height10(context)),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: AppConstants.width15(context)),
                  child: _buildHeader(context),
                ),
                SizedBox(height: AppConstants.height15(context)),
                Divider(color: Colors.grey.shade200, height: 1),
                BlocConsumer<MarkAllNotificationsReadCubit, MarkAllNotificationsReadState>(
                  listener: (context, state) {
                    if (state is MarkAllNotificationsReadSuccess) {
                      toast(text: "تم تحديد كل الاشعارات كمقروءة", color: Colors.green);
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
                                "$unreadCount إشعارات غير مقروءة",
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
                                            "قراءة الكل",
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
                                          if (!context
                                              .read<GetNotificationsCubit>()
                                              .notificationsList[index]
                                              .recipients!
                                              .first
                                              .isRead!) {
                                            selectedIndex = index;
                                            await context
                                                .read<
                                                ReadMarkNotificationsCubit>()
                                                .readMarkNotification(
                                                notificationId: context
                                                    .read<
                                                    GetNotificationsCubit>()
                                                    .notificationsList[
                                                index]
                                                    .id!);
                                          }
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
                                    title: "لا توجد اشعارات الان",
                                    description:
                                    "ستتوفر الاشعارات في حين ارسالها من قبل الادمن"
                                        );
                              }),
                            ),
                            if (isLoading)
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
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            Row(
              children: [
                Expanded(child: Text("الإشعارات",textAlign: TextAlign.center, style: Styles.inter18500Black(context))),
              ],
            ),
            SizedBox(height: AppConstants.height5(context),),
            Text(
              "متابعة الاشعارات الواردة",
              style: Styles.inter14500black(context).copyWith(color: const Color(0xff9CA4AB)),
            ),
          ],
        ),
        PositionedDirectional(
          start: 0,
          child: InkWell(
            onTap: () => NavigationUtils.navigateBack(context: context),
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: AppConstants.width20(context) * 2.2,
              height: AppConstants.width20(context) * 2.2,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.gray.withValues(alpha: .15)),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
