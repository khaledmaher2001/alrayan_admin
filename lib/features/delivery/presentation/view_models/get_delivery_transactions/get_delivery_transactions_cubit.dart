import 'package:bloc/bloc.dart';
import 'package:alrayan_admin/core/shared_cubit/request_guard_mixin.dart';

import '../../../data/models/delivery_transaction_model.dart';
import '../../../data/repo/delivery_repo.dart';
import 'get_delivery_transactions_states.dart';

class GetDeliveryTransactionsCubit extends Cubit<GetDeliveryTransactionsStates>
    with RequestGuardMixin {
  GetDeliveryTransactionsCubit(this.repo)
    : super(GetDeliveryTransactionsInitState());

  final DeliveryRepo repo;

  /// Items for the *current* page only — pagination here is a numbered
  /// pager (matching the courier details screen), not infinite scroll, so
  /// each fetch replaces this list rather than appending to it.
  List<DeliveryTransaction> transactionsList = [];
  DeliveryTransactionsModel? transactionsModel;
  int page = 1;
  String? startDate;
  String? endDate;
  String sortBy = 'createdAt';
  String sortOrder = 'DESC';

  Future<void> getTransactions({
    required int userId,
    bool withLoading = true,
  }) async {
    final reqId = beginRequest();
    if (withLoading) {
      emit(GetDeliveryTransactionsLoadingState());
    }

    final result = await repo.getDeliveryTransactions(
      userId: userId,
      data: {
        'page': page,
        'limit': 15,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      },
      cancelToken: requestCancelToken,
    );
    if (!isCurrentRequest(reqId)) return;

    result.fold(
      (failure) => emit(GetDeliveryTransactionsErrorState(failure.errMessage)),
      (data) {
        transactionsModel = data;
        transactionsList = data.data?.items ?? [];
        emit(GetDeliveryTransactionsSuccessState(model: data));
      },
    );
  }

  @override
  Future<void> close() {
    cancelInFlightRequest();
    return super.close();
  }

  /// Jumps to [pageNumber] and re-fetches, replacing the currently shown
  /// page's items.
  Future<void> goToPage(int pageNumber, {required int userId}) async {
    if (pageNumber == page) return;
    page = pageNumber;
    await getTransactions(userId: userId);
  }

  void setDateFilter({String? startDate, String? endDate}) {
    this.startDate = startDate;
    this.endDate = endDate;
    page = 1;
  }
}
