import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/services/remote_services/api_service.dart';
import '../../../../core/utils/services/remote_services/endpoints.dart';
import '../models/delivery_app_settings_model.dart';
import 'delivery_settings_repo.dart';

class DeliverySettingsRepoImpl implements DeliverySettingsRepo {
  final ApiService apiService;

  DeliverySettingsRepoImpl(this.apiService);

  @override
  Future<Either<Failure, DeliveryAppSettingsModel>> getAppSettings() async {
    try {
      final response = await apiService.get(
        endPoint: EndPoints.appSettings,
        sendToken: true,
      );
      final result = DeliveryAppSettingsModel.fromJson(response.data);
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
  Future<Either<Failure, DeliveryAppSettingsModel>> updateAppSettings({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await apiService.patchData(
        endPoint: EndPoints.appSettings,
        sendToken: true,
        data: data,
      );
      final result = DeliveryAppSettingsModel.fromJson(response.data);
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
