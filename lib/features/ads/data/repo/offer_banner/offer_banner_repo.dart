import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failure.dart';
import '../../models/offer_banner_model.dart';

abstract class OfferBannerRepo {
  Future<Either<Failure, OfferBannerModel>> getOfferBanner();

}
