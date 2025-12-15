import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/utils/services/remote_services/api_service.dart';
import '../../../../../core/utils/services/remote_services/endpoints.dart';
import '../../../home/data/models/home_statistics_model.dart';
import 'top_products_repo.dart';



class TopProductsRepoImpl implements TopProductsRepo{
  final ApiService apiService;

  TopProductsRepoImpl(this.apiService);

  @override
  Future<Either<Failure, List<TopSellingProducts>>> getTopProducts() async {
    try {
      final response = await apiService.get(
        endPoint: EndPoints.topProducts,
        sendToken: true,
        query: {
          "limit":"10",
        }
      );
      if (response.data is List) {
        final List listData = response.data;
        final result =
        listData.map((e) => TopSellingProducts.fromJson(e)).toList();
        return Right(result);
      } else if (response.data is Map<String, dynamic> &&
          response.data['data'] is List) {
        final List listData = response.data['data'];
        final result =
        listData.map((e) => TopSellingProducts.fromJson(e)).toList();
        return Right(result);
      } else {
        return const Right([]);
      }
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }




}
