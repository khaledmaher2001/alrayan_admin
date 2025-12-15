import 'package:alrayan_admin/features/top_products/data/repo/top_products_repo.dart';
import 'package:bloc/bloc.dart';

import '../../../../home/data/models/home_statistics_model.dart';
import '../../../data/repo/top_products_repo.dart';

part 'get_top_products_state.dart';

class GetTopProductsCubit extends Cubit<GetTopProductsState> {
  final TopProductsRepo repo;

  GetTopProductsCubit(this.repo) : super(GetTopProductsInitial());

  List<TopSellingProducts> products = [];

  Future<void> getTopProducts() async {
    emit(GetTopProductsLoading());
    var result = await repo.getTopProducts();
    result.fold(
          (failure) => emit(GetTopProductsError(failure.errMessage)),
          (products) {
        products = products;
        emit(GetTopProductsLoaded(products));
      },
    );
  }

}

