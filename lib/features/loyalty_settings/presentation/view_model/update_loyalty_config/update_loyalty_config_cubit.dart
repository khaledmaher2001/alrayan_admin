import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/loyalty_settings_repo.dart';
import 'update_loyalty_config_state.dart';

class UpdateLoyaltyConfigCubit extends Cubit<UpdateLoyaltyConfigState> {
  UpdateLoyaltyConfigCubit(this.repo) : super(UpdateLoyaltyConfigInitialState());

  final LoyaltySettingsRepo repo;

  Future<void> updateLoyaltyConfig({required Map<String, dynamic> data}) async {
    emit(UpdateLoyaltyConfigLoadingState());
    final result = await repo.updateLoyaltyConfig(data: data);
    result.fold(
      (failure) {
        emit(UpdateLoyaltyConfigErrorState(failure.errMessage));
      },
      (success) {
        emit(UpdateLoyaltyConfigSuccessState(success));
      },
    );
  }
}
