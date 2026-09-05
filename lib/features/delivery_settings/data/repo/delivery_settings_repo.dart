import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/delivery_app_settings_model.dart';

abstract class DeliverySettingsRepo {
  Future<Either<Failure, DeliveryAppSettingsModel>> getAppSettings();

  Future<Either<Failure, DeliveryAppSettingsModel>> updateAppSettings({
    required Map<String, dynamic> data,
  });
}
