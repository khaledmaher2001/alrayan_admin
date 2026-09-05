import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/loyalty_config_model.dart';
import '../../../data/repo/loyalty_settings_repo.dart';

part 'get_loyalty_config_state.dart';

class GetLoyaltyConfigCubit extends Cubit<GetLoyaltyConfigState> {
  GetLoyaltyConfigCubit(this.repo) : super(GetLoyaltyConfigInitial());

  final LoyaltySettingsRepo repo;
  LoyaltyConfigModel? configModel;

  Future<void> getLoyaltyConfig() async {
    emit(GetLoyaltyConfigLoadingState());
    final result = await repo.getLoyaltyConfig();
    result.fold(
      (failure) {
        emit(GetLoyaltyConfigErrorState(failure.errMessage));
      },
      (data) {
        configModel = data;
        emit(GetLoyaltyConfigSuccessState(configModel: data));
      },
    );
  }
}
