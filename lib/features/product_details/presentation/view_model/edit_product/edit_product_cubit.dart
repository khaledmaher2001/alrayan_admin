import 'package:alrayan_admin/features/product_details/presentation/view_model/create_product/create_product_states.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/edit_product/edit_product_states.dart';
import 'package:alrayan_admin/features/products/data/repo/products_repo.dart';
import 'package:bloc/bloc.dart';

class EditProductCubit extends Cubit<EditProductStates> {
  EditProductCubit(this.productsRepo) : super(EditProductInitState());
  ProductsRepo? productsRepo;

  Future<void> editProduct({required Map<String, dynamic> data, required int id}) async {
    emit(EditProductLoadingState());

    var result = await productsRepo!.editProduct(data: data, id: id);
    return result.fold(
      (failure) {
        emit(EditProductErrorState(failure.errMessage));
      },
      (data) {
        emit(EditProductSuccessState(message: data));
      },
    );
  }
}
