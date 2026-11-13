import 'package:bloc/bloc.dart';
import 'package:alrayan_admin/core/shared_cubit/request_guard_mixin.dart';

import '../../../data/models/delivery_account_model.dart';
import '../../../data/repo/delivery_repo.dart';
import 'get_delivery_accounts_states.dart';

class GetDeliveryAccountsCubit extends Cubit<GetDeliveryAccountsStates>
    with RequestGuardMixin {
  GetDeliveryAccountsCubit(this.repo) : super(GetDeliveryAccountsInitState());

  final DeliveryRepo repo;

  List<DeliveryAccount> accountsList = [];
  DeliveryAccountsModel? accountsModel;
  int page = 1;
  bool hasMore = true;
  bool isLoadingMore = false;
  String? keyword;
  String sortBy = 'createdAt';
  String sortOrder = 'DESC';

  Future<void> getDeliveryAccounts({
    String? keyword,
    String? sortBy,
    String? sortOrder,
    bool withLoading = true,
  }) async {
    if (keyword != null) this.keyword = keyword;
    if (sortBy != null) this.sortBy = sortBy;
    if (sortOrder != null) this.sortOrder = sortOrder;

    final reqId = beginRequest();
    if (withLoading) {
      accountsModel = null;
      accountsList.clear();
      page = 1;
      hasMore = true;
      emit(GetDeliveryAccountsLoadingState());
    }

    final result = await repo.getDeliveryAccounts(
      data: {
        'page': page,
        'limit': 12,
        'sortBy': this.sortBy,
        'sortOrder': this.sortOrder,
        if (this.keyword != null && this.keyword!.trim().isNotEmpty)
          'keyword': this.keyword!.trim(),
      },
      cancelToken: requestCancelToken,
    );
    if (!isCurrentRequest(reqId)) return;

    result.fold(
      (failure) => emit(GetDeliveryAccountsErrorState(failure.errMessage)),
      (data) {
        accountsModel = data;
        accountsList = accountsList + (data.data?.items ?? []);
        final totalPages = data.data?.metadata?.totalPages;
        hasMore = totalPages != null
            ? page < totalPages
            : (data.data?.items?.isNotEmpty ?? false);
        emit(GetDeliveryAccountsSuccessState(model: data));
      },
    );
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || isClosed || accountsModel == null) return;
    isLoadingMore = true;
    emit(GetDeliveryAccountsSuccessState(model: accountsModel!));
    page++;
    try {
      await getDeliveryAccounts(withLoading: false);
    } finally {
      if (!isClosed) {
        isLoadingMore = false;
        if (accountsModel != null) {
          emit(GetDeliveryAccountsSuccessState(model: accountsModel!));
        }
      }
    }
  }

  @override
  Future<void> close() {
    cancelInFlightRequest();
    return super.close();
  }

  void removeAccount(int userId) {
    accountsList.removeWhere((a) => a.userId == userId);
    if (accountsModel != null) {
      emit(GetDeliveryAccountsSuccessState(model: accountsModel!));
    }
  }

  void updateAccountLocally(DeliveryAccount updated) {
    final index = accountsList.indexWhere((a) => a.userId == updated.userId);
    if (index != -1) {
      accountsList[index] = updated;
      if (accountsModel != null) {
        emit(GetDeliveryAccountsSuccessState(model: accountsModel!));
      }
    }
  }
}
