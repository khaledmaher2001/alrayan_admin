import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/utils/services/remote_services/api_service.dart';
import '../../../../../core/utils/services/remote_services/endpoints.dart';
import '../../models/offer_banner_model.dart';
import 'offer_banner_repo.dart';



class OfferBannerRepoImpl implements OfferBannerRepo{
  final ApiService apiService;

  OfferBannerRepoImpl(this.apiService);

  @override
  Future<Either<Failure, OfferBannerModel>> getOfferBanner()async {
    try {
      final response = await apiService.get(endPoint: EndPoints.getOfferBanner,sendToken: true);
      var result= OfferBannerModel.fromJson(response.data);
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }


}
