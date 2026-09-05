import 'package:alrayan_admin/features/ads/data/models/offer_banner_model.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/utils/services/remote_services/api_service.dart';
import '../../../../../core/utils/services/remote_services/endpoints.dart';
import 'ads_repo.dart';



class AdsRepoImpl implements AdsRepo{
  final ApiService apiService;

  AdsRepoImpl(this.apiService);

  @override
  Future<Either<Failure, bool>> addAds({required data,void Function(int, int)? onSendProgress,}) async {
    try {
      var response = await apiService.postDataWithImage(
        endPoint: EndPoints.getOfferBanner,
        data: FormData.fromMap(data),
        onSendProgress: onSendProgress,
      );
      return Right(response.data['success']);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, OfferBannerModel>> getBanner({
    int page = 1,
    int limit = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final response = await apiService.get(
        endPoint: EndPoints.getOfferBanner,
        sendToken: true,
        query: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
          if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
          if (sortOrder != null && sortOrder.isNotEmpty) 'sortOrder': sortOrder,
        },
      );
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

  @override
  Future<Either<Failure, bool>> updateBanner({required int id, required data, void Function(int, int)? onSendProgress}) async {
    try {
      var response = await apiService.patchDataWithImage(
        endPoint: "${EndPoints.getOfferBanner}/$id",
        data: FormData.fromMap(data),
        onSendProgress: onSendProgress,
      );
      return Right(response.data['success']);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> deleteBanner({required int id}) async {
    try {
      final response = await apiService.deleteData(endPoint: "${EndPoints.getOfferBanner}/$id",sendToken: true);
      return Right(response.data["message"]);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

}
