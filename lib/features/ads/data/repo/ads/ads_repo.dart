import 'package:alrayan_admin/features/ads/data/models/offer_banner_model.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failure.dart';


abstract class AdsRepo {
  Future<Either<Failure, bool>> addAds({required var data,void Function(int, int)? onSendProgress,});
  Future<Either<Failure, OfferBannerModel>> getBanner();
  Future<Either<Failure, String>> deleteBanner({required int id});


}
