import 'package:bloc/bloc.dart';
import 'package:alrayan_admin/features/all_users/data/repo/all_users_repo.dart';
import 'get_customer_lifetime_value_state.dart';

class GetCustomerLifetimeValueCubit extends Cubit<GetCustomerLifetimeValueState> {
  GetCustomerLifetimeValueCubit(this.repo) : super(GetCustomerLifetimeValueInitial());

  final AllUsersRepo repo;

  Future<void> getCustomerLifetimeValue(int id) async {
    emit(GetCustomerLifetimeValueLoading());
    final result = await repo.getCustomerLifetimeValue(id);
    result.fold(
      (failure) => emit(GetCustomerLifetimeValueError(failure.errMessage)),
      (data) => emit(GetCustomerLifetimeValueSuccess(data)),
    );
  }
}
