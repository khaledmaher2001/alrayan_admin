import 'package:bloc/bloc.dart';

import '../../../data/repo/home_repo.dart';
import 'get_low_stock_config_state.dart';

class GetLowStockConfigCubit extends Cubit<GetLowStockConfigState> {
  GetLowStockConfigCubit(this.repo) : super(GetLowStockConfigInitial());

  final HomeRepo repo;

  Future<void> getLowStockConfig() async {
    emit(GetLowStockConfigLoading());
    final result = await repo.getLowStockConfig();
    result.fold(
      (failure) => emit(GetLowStockConfigError(failure.errMessage)),
      (data) => emit(GetLowStockConfigSuccess(data)),
    );
  }
}
