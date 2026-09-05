import 'package:bloc/bloc.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_helper.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/auth/data/repo/auth_repo.dart';
import 'package:alrayan_admin/features/orders/data/services/orders_socket_service.dart';
import 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit(this.repo) : super(LogoutInitial());

  final AuthRepo repo;

  Future<void> logout() async {
    emit(LogoutLoading());
    final result = await repo.logout();
    result.fold(
      (failure) => emit(LogoutError(failure.errMessage)),
      (_) async {
        await CacheHelper.removeData(key: "token");
        await CacheHelper.removeData(key: "guestUser");
        getIt<OrdersSocketService>().disconnect();
        emit(LogoutSuccess());
      },
    );
  }
}
