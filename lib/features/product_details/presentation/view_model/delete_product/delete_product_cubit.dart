import 'package:alrayan_admin/features/product_details/presentation/view_model/delete_product/delete_product_states.dart';
import 'package:alrayan_admin/features/products/data/repo/products_repo.dart';
import 'package:bloc/bloc.dart';

class DeleteProductCubit extends Cubit<DeleteProductStates> {
  DeleteProductCubit(this.productsRepo) : super(DeleteProductInitState());
  ProductsRepo? productsRepo;

  Future<void> deleteProduct({required int id}) async {
    emit(DeleteProductLoadingState());

    var result = await productsRepo!.deleteProduct(id: id);
    return result.fold(
      (failure) {
        emit(DeleteProductErrorState(error: failure.errMessage));
      },
      (data) {
        emit(DeleteProductSuccessState(message: data));
      },
    );
  }
}
