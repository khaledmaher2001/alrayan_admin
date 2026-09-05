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
  Future<Either<Failure, NotificationsModel>> getNotifications({required Map<String, dynamic> data}) async {
    try {
      var response = await apiService.get(
        endPoint: EndPoints.userNotification,
        sendToken: true,
        query: data,
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
      // No bulk "mark all read" endpoint exists, so every unread page is
      // walked first to collect ids, then each one is marked read.
      final unreadIds = <int>[];
      var page = 1;
      while (true) {
        final response = await apiService.get(
          endPoint: EndPoints.userNotification,
          sendToken: true,
          query: {"page": page, "limit": 100},
        );
        final model = NotificationsModel.fromJson(response.data);
        final items = model.data?.items ?? [];
        unreadIds.addAll(
          items
              .where((item) =>
                  (item.recipients?.isNotEmpty ?? false) &&
                  item.recipients!.first.isRead == false)
              .map((item) => item.id!),
        );
        if (items.isEmpty || model.data?.links?.hasNext != true) break;
        page++;
      }

      await Future.wait(
        unreadIds.map(
          (id) => apiService.patchData(
            endPoint: EndPoints.readNotification(id),
            sendToken: true,
          ),
        ),
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
