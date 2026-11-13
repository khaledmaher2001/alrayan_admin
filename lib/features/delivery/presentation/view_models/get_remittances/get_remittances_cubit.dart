import 'package:bloc/bloc.dart';
import 'package:alrayan_admin/core/shared_cubit/request_guard_mixin.dart';

import '../../../data/models/remittance_model.dart';
import '../../../data/repo/delivery_repo.dart';
import 'get_remittances_states.dart';

class GetRemittancesCubit extends Cubit<GetRemittancesStates>
    with RequestGuardMixin {
  GetRemittancesCubit(this.repo) : super(GetRemittancesInitState());

  final DeliveryRepo repo;

  List<Remittance> remittancesList = [];
  RemittancesModel? remittancesModel;
  int page = 1;
  bool hasMore = true;
  bool isLoadingMore = false;
  String? status;
  int? courierId;
  String sortBy = 'createdAt';
  String sortOrder = 'DESC';

  Future<void> getRemittances({bool withLoading = true}) async {
    final reqId = beginRequest();
    if (withLoading) {
      remittancesModel = null;
      remittancesList.clear();
      page = 1;
      hasMore = true;
      emit(GetRemittancesLoadingState());
    }

    final result = await repo.getRemittances(
      data: {
        'page': page,
        'limit': 15,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
        if (status != null) 'status': status,
        if (courierId != null) 'courierId': courierId,
      },
      cancelToken: requestCancelToken,
    );
    if (!isCurrentRequest(reqId)) return;

    result.fold(
      (failure) => emit(GetRemittancesErrorState(failure.errMessage)),
      (data) {
        remittancesModel = data;
        remittancesList = remittancesList + (data.data?.items ?? []);
        final totalPages = data.data?.metadata?.totalPages;
        hasMore = totalPages != null
            ? page < totalPages
            : (data.data?.items?.isNotEmpty ?? false);
        emit(GetRemittancesSuccessState(model: data));
      },
    );
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || isClosed || remittancesModel == null) {
      return;
    }
    isLoadingMore = true;
    emit(GetRemittancesSuccessState(model: remittancesModel!));
    page++;
    try {
      await getRemittances(withLoading: false);
    } finally {
      if (!isClosed) {
        isLoadingMore = false;
        if (remittancesModel != null) {
          emit(GetRemittancesSuccessState(model: remittancesModel!));
        }
      }
    }
  }

  void setFilters({String? status, int? courierId}) {
    this.status = status;
    this.courierId = courierId;
  }

  /// Re-fetches the first page after an approve/reject action so the list
  /// reflects the real server state, without emitting a loading state first
  /// — the list stays on screen as-is and only swaps once the fresh data
  /// arrives, instead of flashing a spinner.
  Future<void> refreshSilently() async {
    final reqId = beginRequest();
    final result = await repo.getRemittances(
      data: {
        'page': 1,
        'limit': 15,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
        if (status != null) 'status': status,
        if (courierId != null) 'courierId': courierId,
      },
      cancelToken: requestCancelToken,
    );
    if (!isCurrentRequest(reqId)) return;

    result.fold((failure) {}, (data) {
      page = 1;
      hasMore = (data.data?.metadata?.totalPages ?? 1) > 1;
      remittancesModel = data;
      remittancesList = data.data?.items ?? [];
      emit(GetRemittancesSuccessState(model: data));
    });
  }

  @override
  Future<void> close() {
    cancelInFlightRequest();
    return super.close();
  }
}
