import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:alrayan_admin/core/errors/failure.dart';

import '../../../../../core/utils/services/remote_services/api_service.dart';
import '../../../../../core/utils/services/remote_services/endpoints.dart';
import '../models/lucky_wheel_model.dart';
import '../models/spin_attempts_model.dart';
import '../models/spin_wheel_config_model.dart';
import 'package:alrayan_admin/core/shared_widgets/search_pick_sheet.dart';
import 'luck_wheel_repo.dart';

class LuckyWheelRepoImpl implements LuckyWheelRepo {
  final ApiService? apiService;

  LuckyWheelRepoImpl(this.apiService);

  @override
  Future<Either<Failure, String>> createLuckyItem({required Map<String,dynamic> data}) async {
    try {
      var response = await apiService!.postData(endPoint: EndPoints.luckyWheel, data: data,sendToken: true);
      return right(response.data["message"]);
    } catch (e) {
      print("RRRRRRRRRRRRRRRRRRRR:${e.toString()}");
      if (e is DioException) {
        print(e.response);
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
  @override
  Future<Either<Failure, LuckyWheelModel>> getLuckyWheelItems({CancelToken? cancelToken}) async {
    try {
      var response = await apiService!.get(
        endPoint: EndPoints.luckyWheel,
        sendToken: true,
        cancelToken: cancelToken,
      );
      var result = LuckyWheelModel.fromJson(response.data);
      return right(result);
    } catch (e) {
      print("RRRRRRRRRRRRRRRRRRRR:${e.toString()}");

      if (e is DioException) {
        print(e.response);

        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
  @override
  Future<Either<Failure, String>> deleteLuckyItem({required int itemId}) async {
    try {
      var response = await apiService!.deleteData(
        endPoint: "${EndPoints.luckyWheel}/$itemId",
        sendToken: true,
      );
      return right(response.data["message"]);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> editLuckyItem({required int itemId, required Map<String, dynamic> data}) async {
    try {
      var response = await apiService!.patchData(
        endPoint: "${EndPoints.luckyWheel}/$itemId",
        data: data,
        sendToken: true,
      );
      return right(response.data["message"] ?? "");
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> toggleSpinWheel() async {
    try {
      var response = await apiService!.postData(
        endPoint: EndPoints.toggleSpinWheel,
        sendToken: true,
      );
      return right(response.data["message"] ?? "");
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  Either<Failure, T> _fail<T>(Object e) {
    if (e is DioException) return left(ServerFailure.fromDioError(e));
    return left(ServerFailure(e.toString()));
  }

  @override
  Future<Either<Failure, SpinWheelConfigModel>> getSpinConfig({CancelToken? cancelToken}) async {
    try {
      final response = await apiService!.get(endPoint: EndPoints.spinWheelConfig, sendToken: true, cancelToken: cancelToken);
      return right(SpinWheelConfigModel.fromJson(Map<String, dynamic>.from(response.data)));
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Either<Failure, SpinWheelConfigModel>> updateSpinConfig({bool? earningOpen, List<SpinOrderRule>? orderRules}) async {
    try {
      final response = await apiService!.patchData(
        endPoint: EndPoints.spinWheelConfig,
        sendToken: true,
        data: {
          if (earningOpen != null) "earningOpen": earningOpen,
          if (orderRules != null) "orderRules": orderRules.map((r) => r.toJson()).toList(),
        },
      );
      return right(SpinWheelConfigModel.fromJson(Map<String, dynamic>.from(response.data)));
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Either<Failure, SpinAttemptsModel>> getSpinAttempts({String? search, int page = 1, int limit = 20, CancelToken? cancelToken}) async {
    try {
      final response = await apiService!.get(
        endPoint: EndPoints.spinAttempts,
        sendToken: true,
        cancelToken: cancelToken,
        query: {
          "page": page,
          "limit": limit,
          if ((search ?? "").trim().isNotEmpty) "search": search!.trim(),
        },
      );
      return right(SpinAttemptsModel.fromJson(Map<String, dynamic>.from(response.data)));
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Either<Failure, int>> grantSpins({List<int> userIds = const [], bool allCustomers = false, required int spins, bool notify = true, String? note}) async {
    try {
      final response = await apiService!.postData(
        endPoint: EndPoints.spinAttempts,
        sendToken: true,
        data: {
          if (allCustomers) "allCustomers": true else "userIds": userIds,
          "spins": spins,
          "notify": notify,
          if ((note ?? "").trim().isNotEmpty) "note": note!.trim(),
        },
      );
      final data = response.data is Map ? response.data["data"] : null;
      return right(int.tryParse("${data is Map ? data["customers"] : userIds.length}") ?? userIds.length);
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Either<Failure, int>> activeCustomersCount() async {
    try {
      final response = await apiService!.get(endPoint: EndPoints.spinCustomersCount, sendToken: true);
      final data = response.data is Map ? response.data["data"] : null;
      return right(int.tryParse("${data is Map ? data["customers"] : 0}") ?? 0);
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Either<Failure, int>> setSpins({required int userId, required int attemptCount}) async {
    try {
      final response = await apiService!.patchData(
        endPoint: EndPoints.spinAttemptsOf(userId),
        sendToken: true,
        data: {"attemptCount": attemptCount},
      );
      final data = response.data is Map ? response.data["data"] : null;
      return right(int.tryParse("${data is Map ? data["attemptCount"] : attemptCount}") ?? attemptCount);
    } catch (e) {
      return _fail(e);
    }
  }

  /// Customers for the "give spins" picker (same search the dashboard uses).
  @override
  Future<List<PickOption>> searchCustomers(String keyword) async {
    final response = await apiService!.get(
      endPoint: EndPoints.users,
      sendToken: true,
      query: {"role": "user", "page": 1, "limit": 20, if (keyword.isNotEmpty) "keyword": keyword},
    );
    final items = (response.data?["data"]?["items"] as List?) ?? const [];
    return [
      for (final u in items)
        if (u is Map && u["id"] != null)
          PickOption(
            id: int.tryParse("${u["id"]}") ?? 0,
            label: (u["fullName"] ?? "").toString().trim().isEmpty ? "#${u["id"]}" : u["fullName"].toString(),
            subtitle: u["phoneNumber"]?.toString() ?? u["email"]?.toString(),
          ),
    ];
  }
}
