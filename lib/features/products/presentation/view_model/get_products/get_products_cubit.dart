import 'package:alrayan_admin/features/products/data/models/products_model.dart';
import 'package:alrayan_admin/features/products/data/repo/products_repo.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/get_products/get_products_states.dart';
import 'package:bloc/bloc.dart';

class GetProductsCubit extends Cubit<GetProductsStates> {
  GetProductsCubit(this.productsRepo) : super(GetProductsInitState());
  ProductsRepo? productsRepo;

  ProductsModel? productsModel;
  List<Items> productsList = [];
  int page = 1;

  Future<void> getProducts({int? categoryId, String? name, int? subCategoryId, bool withLoading = true}) async {
    print("Called Nowwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww");
    print(categoryId);
    print(subCategoryId);
    if (withLoading) {
      page = 1;
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
    );
    return result.fold(
      (failure) {
        emit(GetProductsErrorState());
      },
      (data) {
        productsModel = data;
        productsList = productsList + productsModel!.data!.items!;
        emit(GetProductsSuccessState(productsModel: data));
      },
    );
  }
}
