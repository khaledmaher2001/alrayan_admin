import 'package:bloc/bloc.dart';

import '../../../data/models/inventory_analytics_model.dart';
import '../../../data/repo/home_repo.dart';
import 'get_inventory_analytics_state.dart';

class GetInventoryAnalyticsCubit extends Cubit<GetInventoryAnalyticsState> {
  GetInventoryAnalyticsCubit(this.repo) : super(GetInventoryAnalyticsInitial());

  final HomeRepo repo;
  final List<InventoryAnalyticsModel> items = [];
  final Set<int> _loadedIds = {};

  int page = 1;
  final int limit = 20;
  bool hasMore = true;
  bool isLoadingMore = false;
  String search = '';

  Future<void> getInventoryAnalytics({
    bool withLoading = true,
    String? search,
  }) async {
    if (search != null) {
      this.search = search.trim();
    }

    if (withLoading) {
      page = 1;
      hasMore = true;
      items.clear();
      _loadedIds.clear();
      emit(GetInventoryAnalyticsLoading());
    }

    final result = await repo.getInventoryAnalytics(
      page: page,
      limit: limit,
      search: this.search.isEmpty ? null : this.search,
    );
    result.fold(
      (failure) => emit(GetInventoryAnalyticsError(failure.errMessage)),
      (response) {
        final sortedData = response.items.toList()
          ..sort(
            (a, b) =>
                (b.sellThroughRate ?? 0).compareTo(a.sellThroughRate ?? 0),
          );

        final newItems = sortedData
            .where((item) => item.id == null || _loadedIds.add(item.id!))
            .toList();

        items.addAll(newItems);
        final metadata = response.metadata;
        hasMore = metadata != null
            ? (metadata.currentPage ?? page) < (metadata.totalPages ?? page)
            : (response.items.length >= limit && newItems.isNotEmpty);
        emit(GetInventoryAnalyticsSuccess(items));
      },
    );
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore) return;
    isLoadingMore = true;
    page++;
    await getInventoryAnalytics(withLoading: false);
    isLoadingMore = false;
  }
}
