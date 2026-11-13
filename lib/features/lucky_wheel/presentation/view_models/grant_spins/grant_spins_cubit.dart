import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/luck_wheel_repo.dart';

part 'grant_spins_state.dart';

/// "Give spins": adds the same number of spins to several customers.
class GrantSpinsCubit extends Cubit<GrantSpinsState> {
  GrantSpinsCubit(this.repo) : super(GrantSpinsInitial());

  final LuckyWheelRepo repo;

  Future<void> grant({List<int> userIds = const [], bool allCustomers = false, required int spins, required bool notify, String? note}) async {
    emit(GrantSpinsLoadingState());
    final result = await repo.grantSpins(userIds: userIds, allCustomers: allCustomers, spins: spins, notify: notify, note: note);
    if (isClosed) return;
    result.fold(
      (failure) => emit(GrantSpinsErrorState(failure.errMessage)),
      (count) => emit(GrantSpinsSuccessState(count)),
    );
  }
}
