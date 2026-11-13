import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrayan_admin/core/shared_cubit/request_guard_mixin.dart';
import 'package:alrayan_admin/features/home/data/repo/home_repo.dart';
import 'get_item_analytics_state.dart';

class GetItemAnalyticsCubit extends Cubit<GetItemAnalyticsState>
    with RequestGuardMixin {
  GetItemAnalyticsCubit(this.repo) : super(GetItemAnalyticsInitial());

  final HomeRepo repo;

  Future<void> getItemAnalytics({
    required int productId,
    String? groupBy,
    String? startDate,
    String? endDate,
  }) async {
    final reqId = beginRequest();
    emit(GetItemAnalyticsLoading());
    final result = await repo.getItemAnalytics(
      productId: productId,
      groupBy: groupBy,
      startDate: startDate,
      endDate: endDate,
      cancelToken: requestCancelToken,
    );
    if (!isCurrentRequest(reqId)) return;
    result.fold(
      (failure) => emit(GetItemAnalyticsError(failure.errMessage)),
      (analytics) => emit(GetItemAnalyticsSuccess(analytics)),
    );
  }

  @override
  Future<void> close() {
    cancelInFlightRequest();
    return super.close();
  }
}
