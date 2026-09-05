import 'package:bloc/bloc.dart';

import '../../../data/models/delivery_account_model.dart';
import '../../../data/repo/delivery_repo.dart';
import 'get_delivery_accounts_states.dart';

class GetDeliveryAccountsCubit extends Cubit<GetDeliveryAccountsStates> {
  GetDeliveryAccountsCubit(this.repo) : super(GetDeliveryAccountsInitState());

  final DeliveryRepo repo;

  List<DeliveryAccount> accountsList = [];
  DeliveryAccountsModel? accountsModel;
  int page = 1;
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

    if (withLoading) {
      accountsModel = null;
      accountsList.clear();
      page = 1;
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
    );

    result.fold(
      (failure) => emit(GetDeliveryAccountsErrorState(failure.errMessage)),
      (data) {
        accountsModel = data;
        accountsList = accountsList + (data.data?.items ?? []);
        emit(GetDeliveryAccountsSuccessState(model: data));
      },
    );
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
