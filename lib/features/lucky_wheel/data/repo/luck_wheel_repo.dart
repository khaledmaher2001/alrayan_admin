import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import 'package:alrayan_admin/core/shared_widgets/search_pick_sheet.dart';
import '../models/lucky_wheel_model.dart';
import '../models/spin_attempts_model.dart';
import '../models/spin_wheel_config_model.dart';

abstract class LuckyWheelRepo{
  Future<Either<Failure,String>> createLuckyItem({required Map<String,dynamic> data});
  Future<Either<Failure, LuckyWheelModel>> getLuckyWheelItems({CancelToken? cancelToken});
  Future<Either<Failure, String>> deleteLuckyItem({required int itemId});
  Future<Either<Failure, String>> editLuckyItem({required int itemId, required Map<String,dynamic> data});
  Future<Either<Failure, String>> toggleSpinWheel();

  // Lucky time (orders earn spins) and the order rules.
  Future<Either<Failure, SpinWheelConfigModel>> getSpinConfig({CancelToken? cancelToken});
  Future<Either<Failure, SpinWheelConfigModel>> updateSpinConfig({bool? earningOpen, List<SpinOrderRule>? orderRules});

  // Customers' saved spins.
  Future<Either<Failure, SpinAttemptsModel>> getSpinAttempts({String? search, int page = 1, int limit = 20, CancelToken? cancelToken});
  /// Empty [userIds] with [allCustomers] = every active customer.
  Future<Either<Failure, int>> grantSpins({List<int> userIds = const [], bool allCustomers = false, required int spins, bool notify = true, String? note});
  /// Active customers (not blocked/deleted) that "all customers" reaches.
  Future<Either<Failure, int>> activeCustomersCount();
  Future<Either<Failure, int>> setSpins({required int userId, required int attemptCount});
  Future<List<PickOption>> searchCustomers(String keyword);
}
