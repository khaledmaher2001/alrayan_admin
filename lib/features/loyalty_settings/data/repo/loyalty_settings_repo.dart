import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/loyalty_config_model.dart';

abstract class LoyaltySettingsRepo {
  Future<Either<Failure, LoyaltyConfigModel>> getLoyaltyConfig();

  Future<Either<Failure, LoyaltyConfigModel>> updateLoyaltyConfig({
    required Map<String, dynamic> data,
  });
}
