import 'package:bloc/bloc.dart';

import '../../../data/repo/home_repo.dart';
import 'update_low_stock_config_state.dart';

class UpdateLowStockConfigCubit extends Cubit<UpdateLowStockConfigState> {
  UpdateLowStockConfigCubit(this.repo)
      : super(UpdateLowStockConfigInitial());

  final HomeRepo repo;

  Future<void> updateLowStockConfig({required int threshold}) async {
    emit(UpdateLowStockConfigLoading());
    final result = await repo.updateLowStockConfig(threshold: threshold);
    result.fold(
      (failure) => emit(UpdateLowStockConfigError(failure.errMessage)),
      (data) => emit(UpdateLowStockConfigSuccess(data)),
    );
  }
}
