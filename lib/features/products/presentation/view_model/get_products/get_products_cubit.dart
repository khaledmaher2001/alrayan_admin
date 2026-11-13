import 'package:alrayan_admin/core/shared_cubit/request_guard_mixin.dart';
import 'package:alrayan_admin/features/products/data/models/products_model.dart';
import 'package:alrayan_admin/features/products/data/repo/products_repo.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/get_products/get_products_states.dart';
import 'package:bloc/bloc.dart';

class GetProductsCubit extends Cubit<GetProductsStates> with RequestGuardMixin {
  GetProductsCubit(this.productsRepo) : super(GetProductsInitState());
  ProductsRepo? productsRepo;

  ProductsModel? productsModel;
  List<Items> productsList = [];
  int page = 1;
  bool hasMore = true;
  bool isLoadingMore = false;

  int? _lastCategoryId;
  int? _lastSubCategoryId;
  String? _lastName;

  void updateHiddenLocally(int productId, bool newIsHidden) {
    final index = productsList.indexWhere((p) => p.id == productId);
    if (index != -1) {
      productsList[index].isHidden = newIsHidden;
    }
  }

  Future<void> getProducts({
    int? categoryId,
    String? name,
    int? subCategoryId,
    bool withLoading = true,
  }) async {
    _lastCategoryId = categoryId;
    _lastSubCategoryId = subCategoryId;
    _lastName = name;

    final reqId = beginRequest();
    if (withLoading) {
      page = 1;
      hasMore = true;
      productsList.clear();
      productsModel = null;
      emit(GetProductsLoadingState());
    }
    var result = await productsRepo!.getProducts(
      data: {
        "page": page,
        if (name != null) "name": name,
        if (categoryId != null) "categoryId": categoryId,
        if (subCategoryId != null) "subCategoryId": subCategoryId,
      },
      cancelToken: requestCancelToken,
    );
    if (!isCurrentRequest(reqId)) return;
    return result.fold(
      (failure) {
        emit(GetProductsErrorState(error: failure.errMessage));
      },
      (data) {
        productsModel = data;
        productsList = productsList + (data.data?.items ?? []);
        final metadata = data.data?.metadata;
        hasMore = metadata?.totalPages != null
            ? page < metadata!.totalPages!
            : (data.data?.items?.isNotEmpty ?? false);
        emit(GetProductsSuccessState(productsModel: data));
      },
    );
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || isClosed || productsModel == null) return;
    isLoadingMore = true;
    emit(GetProductsSuccessState(productsModel: productsModel!));
    page++;
    try {
      await getProducts(
        withLoading: false,
        categoryId: _lastCategoryId,
        subCategoryId: _lastSubCategoryId,
        name: _lastName,
      );
    } finally {
      if (!isClosed) {
        isLoadingMore = false;
        if (productsModel != null) {
          emit(GetProductsSuccessState(productsModel: productsModel!));
        }
      }
    }
  }

  @override
  Future<void> close() {
    cancelInFlightRequest();
    return super.close();
  }
}
