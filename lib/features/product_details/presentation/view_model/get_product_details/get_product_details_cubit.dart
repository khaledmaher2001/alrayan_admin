import 'package:alrayan_admin/features/product_details/presentation/view_model/get_product_details/get_product_details_states.dart';
import 'package:alrayan_admin/features/products/data/repo/products_repo.dart';
import 'package:bloc/bloc.dart';

class GetProductsDetailsCubit extends Cubit<GetProductsDetailsStates> {
  GetProductsDetailsCubit(this.productsRepo) : super(GetProductsDetailsInitState());
  ProductsRepo? productsRepo;

  Future<void> getProductDetails({required int productId}) async {
    emit(GetProductsDetailsLoadingState());

    var result = await productsRepo!.getProductDetails(productId: productId);
    return result.fold(
      (failure) {
        emit(GetProductsDetailsErrorState());
      },
      (data) {
        emit(GetProductsDetailsSuccessState(productDetails: data));
      },
    );
  }
}
