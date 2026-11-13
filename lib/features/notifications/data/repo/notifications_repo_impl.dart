import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/utils/services/remote_services/endpoints.dart';
import '../../../../core/utils/services/remote_services/api_service.dart';
import '../model/notifications_model.dart';
import 'notifications_repo.dart';

class NotificationsRepoImpl implements NotificationsRepo {
  ApiService apiService;

  NotificationsRepoImpl(this.apiService);

  @override
  Future<Either<Failure, NotificationsModel>> getNotifications({
    required Map<String, dynamic> data,
    CancelToken? cancelToken,
  }) async {
    try {
      var response = await apiService.get(
        endPoint: EndPoints.userNotification,
        sendToken: true,
        query: data,
        cancelToken: cancelToken,
      );
      final model = NotificationsModel.fromJson(response.data);
      return Right(model);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
  @override
  Future<Either<Failure, String>> markAllAsRead() async {
    try {
      // One request: the server marks every unread notification at once.
      await apiService.patchData(
        endPoint: EndPoints.markAllNotificationsRead,
        sendToken: true,
      );
      return const Right("");
    } catch (e) {
      log("markAllAsRead Exception:: ${e.toString()}");
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> readMarkNotification({required int notificationId}) async {
    try {
      var response = await apiService.patchData(
        endPoint: EndPoints.readNotification(notificationId),
        sendToken: true,
      );
      log('markReadNotification successful:\n ${response.data}');

      return const Right("");
    } catch (e) {
      log("markReadNotification Exception:: ${e.toString()}");
      if (e is DioException) {
        log("markReadNotification Exception:: ${e.response}");
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
}
