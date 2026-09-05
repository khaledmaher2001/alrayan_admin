import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/services/remote_services/api_service.dart';
import '../../../../core/utils/services/remote_services/endpoints.dart';
import '../models/loyalty_config_model.dart';
import 'loyalty_settings_repo.dart';

class LoyaltySettingsRepoImpl implements LoyaltySettingsRepo {
  final ApiService apiService;

  LoyaltySettingsRepoImpl(this.apiService);

  @override
  Future<Either<Failure, LoyaltyConfigModel>> getLoyaltyConfig() async {
    try {
      final response = await apiService.get(
        endPoint: EndPoints.loyaltyConfig,
        sendToken: true,
      );
      final result = LoyaltyConfigModel.fromJson(response.data);
      return right(result);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, LoyaltyConfigModel>> updateLoyaltyConfig({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await apiService.patchData(
        endPoint: EndPoints.loyaltyConfig,
        sendToken: true,
        data: data,
      );
      final result = LoyaltyConfigModel.fromJson(response.data);
      return right(result);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
}
