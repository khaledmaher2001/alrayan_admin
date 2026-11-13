import 'package:bloc/bloc.dart';
import 'package:alrayan_admin/core/shared_cubit/request_guard_mixin.dart';

import '../../../data/models/release_log_model.dart';
import '../../../data/repo/delivery_repo.dart';
import 'get_release_logs_states.dart';

class GetReleaseLogsCubit extends Cubit<GetReleaseLogsStates>
    with RequestGuardMixin {
  GetReleaseLogsCubit(this.repo) : super(GetReleaseLogsInitState());

  final DeliveryRepo repo;

  List<ReleaseLog> logsList = [];
  ReleaseLogsModel? logsModel;
  int page = 1;
  bool hasMore = true;
  bool isLoadingMore = false;

  // Filters. `orderId`/`courierId` are the verified query params for this
  // endpoint. `releaseType`, `startDate`, `endDate` follow the naming used
  // by the other filtered delivery endpoints in this app but are NOT
  // documented for `GET /delivery/release-logs` — flagged as a
  // backend-confirmation item. A param the server ignores is simply a no-op.
  int? orderId;
  int? courierId;
  String? releaseType;
  String? startDate;
  String? endDate;

  String sortBy = 'createdAt';
  String sortOrder = 'DESC';

  bool get hasActiveFilters =>
      orderId != null ||
      courierId != null ||
      releaseType != null ||
      startDate != null ||
      endDate != null;

  Future<void> getReleaseLogs({bool withLoading = true}) async {
    final reqId = beginRequest();
    if (withLoading) {
      logsModel = null;
      logsList.clear();
      page = 1;
      hasMore = true;
      emit(GetReleaseLogsLoadingState());
    }

    final result = await repo.getReleaseLogs(
      data: {
        'page': page,
        'limit': 15,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
        if (orderId != null) 'orderId': orderId,
        if (courierId != null) 'courierId': courierId,
        if (releaseType != null) 'releaseType': releaseType,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      },
      cancelToken: requestCancelToken,
    );
    if (!isCurrentRequest(reqId)) return;

    result.fold(
      (failure) => emit(GetReleaseLogsErrorState(failure.errMessage)),
      (data) {
        logsModel = data;
        logsList = logsList + (data.data?.items ?? []);
        final totalPages = data.data?.metadata?.totalPages;
        hasMore = totalPages != null
            ? page < totalPages
            : (data.data?.items?.isNotEmpty ?? false);
        emit(GetReleaseLogsSuccessState(model: data));
      },
    );
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || isClosed || logsModel == null) return;
    isLoadingMore = true;
    emit(GetReleaseLogsSuccessState(model: logsModel!));
    page++;
    try {
      await getReleaseLogs(withLoading: false);
    } finally {
      if (!isClosed) {
        isLoadingMore = false;
        if (logsModel != null) {
          emit(GetReleaseLogsSuccessState(model: logsModel!));
        }
      }
    }
  }

  @override
  Future<void> close() {
    cancelInFlightRequest();
    return super.close();
  }

  void setFilters({
    int? orderId,
    int? courierId,
    String? releaseType,
    String? startDate,
    String? endDate,
  }) {
    this.orderId = orderId;
    this.courierId = courierId;
    this.releaseType = releaseType;
    this.startDate = startDate;
    this.endDate = endDate;
  }
}
