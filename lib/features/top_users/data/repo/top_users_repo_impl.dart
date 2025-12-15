import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/utils/services/remote_services/api_service.dart';
import '../../../../../core/utils/services/remote_services/endpoints.dart';
import '../../../home/data/models/home_statistics_model.dart';
import 'top_users_repo.dart';



class TopUsersRepoImpl implements TopUsersRepo{
  final ApiService apiService;

  TopUsersRepoImpl(this.apiService);

  @override
  Future<Either<Failure, List<TopCustomers>>> getTopUsers() async {
    try {
      final response = await apiService.get(
        endPoint: EndPoints.topUsers,
        sendToken: true,
        query: {
          "startDate":"2025-10-10",
          "endDate":"2080-10-10",
          "limit":"10",
        }
      );
      if (response.data is List) {
        final List listData = response.data;
        final result =
        listData.map((e) => TopCustomers.fromJson(e)).toList();
        return Right(result);
      } else if (response.data is Map<String, dynamic> &&
          response.data['data'] is List) {
        final List listData = response.data['data'];
        final result =
        listData.map((e) => TopCustomers.fromJson(e)).toList();
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
