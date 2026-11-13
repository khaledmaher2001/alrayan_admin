import 'dart:async';

import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_widgets/toast.dart';
import 'package:alrayan_admin/core/utils/helpers/staff_permissions.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/scheduled_notification_model.dart';
import '../../data/repo/scheduled_notifications_repo_impl.dart';
import '../view_models/cancel_scheduled_notification/cancel_scheduled_notification_cubit.dart';
import '../view_models/get_scheduled_notifications/get_scheduled_notifications_cubit.dart';
import 'scheduled_notification_form_view.dart';
import 'widgets/scheduled_notification_card.dart';

/// Pushes to customers: send now or schedule (once / daily / weekly), Cairo time.
class ScheduledNotificationsView extends StatelessWidget {
  const ScheduledNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetScheduledNotificationsCubit(getIt.get<ScheduledNotificationsRepoImpl>())..load()),
        BlocProvider(create: (_) => CancelScheduledNotificationCubit(getIt.get<ScheduledNotificationsRepoImpl>())),
      ],
      child: const _ScheduledNotificationsBody(),
    );
  }
}

class _ScheduledNotificationsBody extends StatefulWidget {
  const _ScheduledNotificationsBody();

  @override
  State<_ScheduledNotificationsBody> createState() => _ScheduledNotificationsBodyState();
}

class _ScheduledNotificationsBodyState extends State<_ScheduledNotificationsBody> {
  final _scroll = ScrollController();
  Timer? _refresh;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        context.read<GetScheduledNotificationsCubit>().loadMore();
      }
    });
    // Keep "sending"/"scheduled" rows fresh while the screen is open.
    _refresh = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) context.read<GetScheduledNotificationsCubit>().load(withLoading: false);
    });
  }

  @override
  void dispose() {
    _refresh?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _openForm({ScheduledNotificationModel? item, bool copy = false}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ScheduledNotificationFormView(item: item, copy: copy)),
    );
    if (saved == true && mounted) context.read<GetScheduledNotificationsCubit>().load(withLoading: false);
  }

  Future<void> _confirmCancel(ScheduledNotificationModel item) async {
    final ok = await dsConfirm(
      context,
      title: "sn_sure_stop".tr(),
      message: "sn_sure_stop_body".tr(),
      confirmLabel: "sn_yes_stop".tr(),
      destructive: true,
    );
    if (ok && mounted) context.read<CancelScheduledNotificationCubit>().cancel(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final canSend = staffCan(context, 'notifications.send');
    return BlocListener<CancelScheduledNotificationCubit, CancelScheduledNotificationState>(
      listener: (context, state) {
        if (state is CancelScheduledNotificationSuccessState) {
          toast(text: "sn_stopped".tr(), color: DsColor.success);
          context.read<GetScheduledNotificationsCubit>().load(withLoading: false);
        } else if (state is CancelScheduledNotificationErrorState) {
          toast(text: state.error, color: DsColor.danger);
        }
      },
      child: Scaffold(
        backgroundColor: DsColor.page,
        floatingActionButton: canSend
            ? FloatingActionButton.extended(
                heroTag: "scheduled_add",
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add_rounded),
                label: Text("sn_add".tr()),
              )
            : null,
        body: SafeArea(
          child: BlocBuilder<GetScheduledNotificationsCubit, GetScheduledNotificationsState>(
            builder: (context, state) {
              final cubit = context.read<GetScheduledNotificationsCubit>();
              return Column(
                children: [
                  DsTopBar(
                    title: "sn_title".tr(),
                    subtitle: "sn_subtitle".tr(),
                    actions: [
                      IconButton(
                        tooltip: "sn_refresh".tr(),
                        onPressed: () => cubit.load(),
                        icon: const Icon(Icons.refresh_rounded, color: DsColor.text),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 56,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: DsSpace.page, vertical: DsSpace.sm),
                      children: [
                        for (final t in scheduledNotificationTabs) ...[
                          DsChip(
                            label: "sn_tab_$t".tr(),
                            count: cubit.counts.isEmpty ? null : cubit.countFor(t),
                            selected: cubit.tab == t,
                            onTap: () => cubit.load(tab: t),
                          ),
                          const SizedBox(width: DsSpace.sm),
                        ],
                      ],
                    ),
                  ),
                  Expanded(child: _buildList(context, state, cubit, canSend)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, GetScheduledNotificationsState state, GetScheduledNotificationsCubit cubit, bool canSend) {
    if (state is GetScheduledNotificationsLoadingState || state is GetScheduledNotificationsInitial) {
      return ListView.separated(
        padding: const EdgeInsets.all(DsSpace.page),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: DsSpace.sm),
        itemBuilder: (_, _) => const DsSkeleton(height: 150, radius: DsRadius.lg),
      );
    }
    if (state is GetScheduledNotificationsErrorState) {
      return DsMessage(
        icon: Icons.cloud_off_rounded,
        title: "sn_load_fail".tr(),
        subtitle: state.error,
        actionLabel: "s_retry".tr(),
        onAction: () => cubit.load(),
      );
    }
    if (cubit.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => cubit.load(withLoading: false),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            DsMessage(icon: Icons.notifications_none_rounded, title: "sn_empty".tr(), subtitle: "sn_empty_desc".tr()),
          ],
        ),
      );
    }
    return BlocBuilder<CancelScheduledNotificationCubit, CancelScheduledNotificationState>(
      builder: (context, cancelState) => RefreshIndicator(
        onRefresh: () => cubit.load(withLoading: false),
        child: ListView.separated(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          // Bottom room so the FAB never covers the last card.
          padding: const EdgeInsets.fromLTRB(DsSpace.page, DsSpace.xs, DsSpace.page, 96),
          itemCount: cubit.items.length + (cubit.isLoadingMore ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: DsSpace.sm),
          itemBuilder: (context, i) {
            if (i >= cubit.items.length) {
              return const Padding(
                padding: EdgeInsets.all(DsSpace.lg),
                child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
              );
            }
            final item = cubit.items[i];
            return ScheduledNotificationCard(
              item: item,
              canSend: canSend,
              cancelling: cancelState is CancelScheduledNotificationLoadingState && cancelState.id == item.id,
              onEdit: () => _openForm(item: item),
              onCopy: () => _openForm(item: item, copy: true),
              onCancel: () => _confirmCancel(item),
            );
          },
        ),
      ),
    );
  }
}
