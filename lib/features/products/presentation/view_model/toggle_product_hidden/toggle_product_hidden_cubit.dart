import 'package:bloc/bloc.dart';
import '../../../data/repo/products_repo.dart';
import 'toggle_product_hidden_states.dart';

class ToggleProductHiddenCubit extends Cubit<ToggleProductHiddenStates> {
  ToggleProductHiddenCubit(this.productsRepo) : super(ToggleProductHiddenInitState());

  final ProductsRepo productsRepo;

  Future<void> toggleHidden({required int productId}) async {
    emit(ToggleProductHiddenLoadingState());
    var result = await productsRepo.toggleProductHidden(id: productId);
    result.fold(
      (failure) => emit(ToggleProductHiddenErrorState(failure.errMessage)),
      (_) => emit(ToggleProductHiddenSuccessState()),
    );
  }
}
