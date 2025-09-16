import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../model/notifications_model.dart';

abstract class NotificationsRepo {
  Future<Either<Failure, NotificationsModel>> getNotifications({required Map<String,dynamic> data});
  Future<Either<Failure, String>> readMarkNotification({required int notificationId});

}
