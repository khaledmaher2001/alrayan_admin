import 'package:alrayan_admin/core/errors/failure.dart';
import 'package:alrayan_admin/core/shared_widgets/search_pick_sheet.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../models/scheduled_notification_model.dart';

abstract class ScheduledNotificationsRepo {
  Future<Either<Failure, ScheduledNotificationsPage>> getScheduledNotifications({
    String? status,
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  });

  Future<Either<Failure, ScheduledNotificationModel>> getScheduledNotification(int id);

  Future<Either<Failure, ScheduledNotificationModel>> createScheduledNotification(Map<String, dynamic> body);

  Future<Either<Failure, ScheduledNotificationModel>> updateScheduledNotification(int id, Map<String, dynamic> body);

  Future<Either<Failure, bool>> cancelScheduledNotification(int id);

  Future<Either<Failure, UploadedImage>> uploadImage(String filePath);

  // Pickers for the form.
  Future<List<PickOption>> searchCustomers(String keyword);
  Future<List<PickOption>> searchProducts(String keyword);
  Future<List<NotificationCategoryOption>> getCategories();

  /// "Name · phone" for an id stored on an existing notification.
  Future<PickOption> customerById(int id);
}
