import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/features/notifications/presenatation/view/widgets/notification_item.dart';
import 'package:alrayan_admin/features/notifications/presenatation/view/widgets/notification_loading_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/colors/colors.dart';

import '../../../../core/shared_widgets/custom_app_bar.dart';
import '../../../../core/shared_widgets/empty_widget.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../../core/utils/assets/assets.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/services/remote_services/service_locator.dart';
import '../../../../core/utils/text_styles/styles.dart';
import '../../data/repo/notifications_repo_impl.dart';
import '../view_model/get_notifications/get_notifications_cubit.dart';
import '../view_model/get_notifications/get_notifications_state.dart';
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
      onWillPop: ()async{
        context.read<GetNotificationsCubit>().getNotifications(withLoading: false);
        return true;
      },
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: AppColors.primarySwatchColor,
          systemNavigationBarColor: Colors.white,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: BlocProvider(
          create: (context) =>
              ReadMarkNotificationsCubit(getIt<NotificationsRepoImpl>()),
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration:  BoxDecoration(color: AppColors.primaryColor),
                      child: Column(
                        children: [
                          SizedBox(height: AppConstants.height10(context)),
                          CustomAppBar(title: "notifications".tr(),hasBack: true,withNotifications: false,),
                          SizedBox(height: AppConstants.height10(context)),
                        ],
                      ),
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
                                          .length, separatorBuilder: (BuildContext context, int index) {
                                        return Column(
                                          children: [
                                            Divider(color: Color(0xffF2F2F2),height: 0,)
                                          ],
                                        );
                                    },
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
                )),
          ),
        ),
      ),
    );
  }
}
