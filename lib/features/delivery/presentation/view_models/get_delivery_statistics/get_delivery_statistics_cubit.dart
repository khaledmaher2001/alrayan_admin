import 'package:bloc/bloc.dart';

import '../../../data/repo/delivery_repo.dart';
import 'get_delivery_statistics_states.dart';

class GetDeliveryStatisticsCubit extends Cubit<GetDeliveryStatisticsStates> {
  GetDeliveryStatisticsCubit(this.repo)
    : super(GetDeliveryStatisticsInitState());

  final DeliveryRepo repo;

  Future<void> getStatistics() async {
    emit(GetDeliveryStatisticsLoadingState());
    final result = await repo.getDeliveryStatistics();
    result.fold(
      (failure) => emit(GetDeliveryStatisticsErrorState(failure.errMessage)),
      (model) => emit(GetDeliveryStatisticsSuccessState(model)),
    );
  }
}
