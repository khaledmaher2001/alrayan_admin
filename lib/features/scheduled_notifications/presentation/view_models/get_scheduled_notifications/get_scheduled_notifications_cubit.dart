import 'package:alrayan_admin/core/shared_cubit/request_guard_mixin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/scheduled_notification_model.dart';
import '../../../data/repo/scheduled_notifications_repo.dart';

part 'get_scheduled_notifications_state.dart';

/// Status tabs of the list (server statuses, plus "all").
const scheduledNotificationTabs = ['scheduled', 'sent', 'cancelled', 'failed', 'all'];

class GetScheduledNotificationsCubit extends Cubit<GetScheduledNotificationsState> with RequestGuardMixin {
  GetScheduledNotificationsCubit(this.repo) : super(GetScheduledNotificationsInitial());

  final ScheduledNotificationsRepo repo;
  static const _limit = 20;

  String tab = 'scheduled';
  List<ScheduledNotificationModel> items = [];
  Map<String, int> counts = {};
  int total = 0;
  int _page = 1;
  bool isLoadingMore = false;

  bool get hasMore => items.length < total;

  /// Count shown on a tab ("scheduled" includes the ones being sent now).
  int countFor(String t) {
    if (t == 'all') return counts.values.fold(0, (a, b) => a + b);
    if (t == 'scheduled') return (counts['scheduled'] ?? 0) + (counts['sending'] ?? 0);
    return counts[t] ?? 0;
  }

  Future<void> load({String? tab, bool withLoading = true}) async {
    if (tab != null) this.tab = tab;
    final reqId = beginRequest();
    isLoadingMore = false;
    if (withLoading) emit(GetScheduledNotificationsLoadingState());
    final result = await repo.getScheduledNotifications(
      status: this.tab == 'all' ? null : this.tab,
      page: 1,
      limit: _limit,
      cancelToken: requestCancelToken,
    );
    if (!isCurrentRequest(reqId)) return;
    result.fold(
      (failure) => emit(GetScheduledNotificationsErrorState(failure.errMessage)),
      (data) {
        items = data.items;
        counts = data.counts;
        total = data.total;
        _page = 1;
        emit(GetScheduledNotificationsSuccessState());
      },
    );
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore || state is! GetScheduledNotificationsSuccessState) return;
    isLoadingMore = true;
    emit(GetScheduledNotificationsSuccessState());
    final reqId = beginRequest();
    final result = await repo.getScheduledNotifications(
      status: tab == 'all' ? null : tab,
      page: _page + 1,
      limit: _limit,
      cancelToken: requestCancelToken,
    );
    if (!isCurrentRequest(reqId)) return;
    isLoadingMore = false;
    result.fold(
      (_) => emit(GetScheduledNotificationsSuccessState()),
      (data) {
        final known = items.map((e) => e.id).toSet();
        items = [...items, ...data.items.where((e) => !known.contains(e.id))];
        counts = data.counts;
        total = data.total;
        _page++;
        emit(GetScheduledNotificationsSuccessState());
      },
    );
  }

  @override
  Future<void> close() {
    cancelInFlightRequest();
    return super.close();
  }
}
