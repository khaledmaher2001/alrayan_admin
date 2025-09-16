import 'package:alrayan_admin/features/product_details/presentation/view_model/create_product/create_product_states.dart';
import 'package:alrayan_admin/features/products/data/repo/products_repo.dart';
import 'package:bloc/bloc.dart';

class CreateProductCubit extends Cubit<CreateProductStates> {
  CreateProductCubit(this.productsRepo) : super(CreateProductInitState());
  ProductsRepo? productsRepo;

  Future<void> createProduct({required Map<String, dynamic> data}) async {
    print("------------------ data -------------------------");
    print(data);
    emit(CreateProductLoadingState());

    var result = await productsRepo!.createProduct(data: data);
    return result.fold(
      (failure) {
        emit(CreateProductErrorState(failure.errMessage));
      },
      (data) {
        emit(CreateProductSuccessState(message: data));
      },
    );
  }
}
