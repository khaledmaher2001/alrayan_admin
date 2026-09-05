import 'package:bloc/bloc.dart';

import '../../../data/models/release_log_model.dart';
import '../../../data/repo/delivery_repo.dart';
import 'get_release_logs_states.dart';

class GetReleaseLogsCubit extends Cubit<GetReleaseLogsStates> {
  GetReleaseLogsCubit(this.repo) : super(GetReleaseLogsInitState());

  final DeliveryRepo repo;

  List<ReleaseLog> logsList = [];
  ReleaseLogsModel? logsModel;
  int page = 1;

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
    if (withLoading) {
      logsModel = null;
      logsList.clear();
      page = 1;
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
    );

    result.fold(
      (failure) => emit(GetReleaseLogsErrorState(failure.errMessage)),
      (data) {
        logsModel = data;
        logsList = logsList + (data.data?.items ?? []);
        emit(GetReleaseLogsSuccessState(model: data));
      },
    );
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
