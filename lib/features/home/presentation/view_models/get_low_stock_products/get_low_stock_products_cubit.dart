import 'package:bloc/bloc.dart';

import '../../../data/models/low_stock_product_model.dart';
import '../../../data/repo/home_repo.dart';
import 'get_low_stock_products_state.dart';

class GetLowStockProductsCubit extends Cubit<GetLowStockProductsState> {
  GetLowStockProductsCubit(this.repo) : super(GetLowStockProductsInitial());

  final HomeRepo repo;
  final List<LowStockProductModel> products = [];
  final Set<int> _loadedIds = {};

  int page = 1;
  final int limit = 20;
  bool hasMore = true;
  bool isLoadingMore = false;
  String search = '';

  Future<void> getLowStockProducts({
    bool withLoading = true,
    String? search,
  }) async {
    if (search != null) {
      this.search = search.trim();
    }

    if (withLoading) {
      page = 1;
      hasMore = true;
      products.clear();
      _loadedIds.clear();
      emit(GetLowStockProductsLoading());
    }

    final result = await repo.getLowStockProducts(
      page: page,
      limit: limit,
      search: this.search.isEmpty ? null : this.search,
    );
    result.fold(
      (failure) => emit(GetLowStockProductsError(failure.errMessage)),
      (response) {
        final newItems = response.items
            .where((item) => item.id == null || _loadedIds.add(item.id!))
            .toList();

        products.addAll(newItems);
        hasMore = response.links?.hasNext ??
            (response.items.length >= limit && newItems.isNotEmpty);
        emit(GetLowStockProductsSuccess(products));
      },
    );
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore) return;
    isLoadingMore = true;
    page++;
    await getLowStockProducts(withLoading: false);
    isLoadingMore = false;
  }
}
