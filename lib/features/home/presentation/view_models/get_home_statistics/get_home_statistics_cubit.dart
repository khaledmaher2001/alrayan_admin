import 'package:bloc/bloc.dart';

import '../../../data/models/home_statistics_model.dart';
import '../../../data/repo/home_repo.dart';
import 'get_home_statistics_states.dart';

class GetHomeStatisticsCubit extends Cubit<GetHomeStatisticsStates> {
  GetHomeStatisticsCubit(this.repo) : super(GetHomeStatisticsInitState());
  HomeRepo? repo;

  HomeStatisticsModel? ordersModel;

  Future<void> getHomeStatistics({String? status, bool withLoading = true}) async {
      emit(GetHomeStatisticsLoadingState());
    var result = await repo!.getHomeStatistics();
    return result.fold(
      (failure) {
        emit(GetHomeStatisticsErrorState());
      },
      (data) {
        ordersModel = data;
        emit(GetHomeStatisticsSuccessState(model: data));
      },
    );
  }
}
