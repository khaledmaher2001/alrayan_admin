import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/lucky_wheel_model.dart';
import '../../../data/repo/luck_wheel_repo.dart';

part 'get_lucky_wheel_items_state.dart';

class GetLuckyWheelItemsCubit extends Cubit<GetLuckyWheelItemsState> {
  GetLuckyWheelItemsCubit(this.repo) : super(GetLuckyWheelItemsInitial());

  LuckyWheelRepo repo;

  LuckyWheelModel? luckyWheelModel;
  List<Rewards> luckyWheelList = [];
  int page = 1;

  Future<void> getLuckyWheelItems({bool withLoading = true}) async {
    if (withLoading) {
      luckyWheelList.clear();
      luckyWheelModel = null;
      page = 1;
      emit(GetLuckyWheelItemsLoadingState());
    }

    final result = await repo.getLuckyWheelItems();
    result.fold(
      (failure) {
        emit(GetLuckyWheelItemsErrorState(failure.errMessage));
      },
      (data) {
        luckyWheelModel = data;
        luckyWheelList = List<Rewards>.from(data.data?.rewards ?? []);
        emit(GetLuckyWheelItemsSuccessState(data));
      },
    );
  }

  Future<void> toggleSpinWheel() async {
    emit(GetLuckyWheelToggleLoadingState());
    final result = await repo.toggleSpinWheel();
    result.fold(
      (failure) => emit(GetLuckyWheelToggleErrorState(failure.errMessage)),
      (_) => getLuckyWheelItems(withLoading: false),
    );
  }

  double get totalProbability {
    if (luckyWheelList.isEmpty) return 0.0;
    return luckyWheelList.fold(0.0, (sum, item) {
      final p = (item.probability is num) ? (item.probability as num).toDouble() : 0.0;
      return sum + p;
    });
  }
}
