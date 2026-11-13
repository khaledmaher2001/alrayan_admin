import 'package:alrayan_admin/core/shared_cubit/request_guard_mixin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/spin_attempts_model.dart';
import '../../../data/repo/luck_wheel_repo.dart';

part 'customer_spins_state.dart';

/// Customers holding saved spins (or, with a search, any matching customer)
/// plus the wheel figures.
class CustomerSpinsCubit extends Cubit<CustomerSpinsState> with RequestGuardMixin {
  CustomerSpinsCubit(this.repo) : super(CustomerSpinsInitial());

  final LuckyWheelRepo repo;
  static const _limit = 20;

  List<SpinCustomer> customers = [];
  SpinStats? stats;
  int totalItems = 0;
  int _page = 1;
  int _totalPages = 1;
  String search = '';
  bool isLoadingMore = false;

  bool get hasMore => _page < _totalPages;

  Future<void> load({String? search, bool withLoading = true}) async {
    if (search != null) this.search = search;
    final reqId = beginRequest();
    isLoadingMore = false;
    if (withLoading) emit(CustomerSpinsLoadingState());
    final result = await repo.getSpinAttempts(search: this.search, page: 1, limit: _limit, cancelToken: requestCancelToken);
    if (!isCurrentRequest(reqId)) return;
    result.fold(
      (failure) => emit(CustomerSpinsErrorState(failure.errMessage)),
      (data) {
        customers = data.items;
        stats = data.stats;
        totalItems = data.totalItems;
        _page = data.currentPage;
        _totalPages = data.totalPages;
        emit(CustomerSpinsSuccessState());
      },
    );
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore || state is! CustomerSpinsSuccessState) return;
    isLoadingMore = true;
    emit(CustomerSpinsSuccessState());
    final reqId = beginRequest();
    final result = await repo.getSpinAttempts(search: search, page: _page + 1, limit: _limit, cancelToken: requestCancelToken);
    if (!isCurrentRequest(reqId)) return;
    isLoadingMore = false;
    result.fold(
      (_) => emit(CustomerSpinsSuccessState()),
      (data) {
        final known = customers.map((c) => c.id).toSet();
        customers = [...customers, ...data.items.where((c) => !known.contains(c.id))];
        _page = data.currentPage;
        _totalPages = data.totalPages;
        emit(CustomerSpinsSuccessState());
      },
    );
  }

  /// After "edit count": show the new number right away.
  void updateCount(int userId, int attemptCount) {
    for (final c in customers) {
      if (c.id == userId) c.attemptCount = attemptCount;
    }
    emit(CustomerSpinsSuccessState());
  }

  @override
  Future<void> close() {
    cancelInFlightRequest();
    return super.close();
  }
}
