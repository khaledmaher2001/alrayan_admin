import 'package:alrayan_admin/core/errors/failure.dart';
import 'package:alrayan_admin/core/shared_widgets/search_pick_sheet.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_keys.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/api_service.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/endpoints.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/scheduled_notification_model.dart';
import 'scheduled_notifications_repo.dart';

class ScheduledNotificationsRepoImpl implements ScheduledNotificationsRepo {
  final ApiService? apiService;

  ScheduledNotificationsRepoImpl(this.apiService);

  Either<Failure, T> _fail<T>(Object e) {
    debugPrint(e.toString());
    if (e is DioException) return left(ServerFailure.fromDioError(e));
    return left(ServerFailure(e.toString()));
  }

  /// Most endpoints here answer without the {data: …} wrapper; accept both.
  static Map<String, dynamic> _body(dynamic raw) {
    if (raw is Map && raw['data'] is Map) return Map<String, dynamic>.from(raw['data']);
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return const {};
  }

  @override
  Future<Either<Failure, ScheduledNotificationsPage>> getScheduledNotifications({
    String? status,
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await apiService!.get(
        endPoint: EndPoints.scheduledNotifications,
        sendToken: true,
        cancelToken: cancelToken,
        query: {"page": page, "limit": limit, if (status != null) "status": status},
      );
      return right(ScheduledNotificationsPage.fromJson(Map<String, dynamic>.from(response.data)));
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Either<Failure, ScheduledNotificationModel>> getScheduledNotification(int id) async {
    try {
      final response = await apiService!.get(endPoint: EndPoints.scheduledNotification(id), sendToken: true);
      return right(ScheduledNotificationModel.fromJson(_body(response.data)));
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Either<Failure, ScheduledNotificationModel>> createScheduledNotification(Map<String, dynamic> body) async {
    try {
      final response = await apiService!.postData(endPoint: EndPoints.scheduledNotifications, sendToken: true, data: body);
      return right(ScheduledNotificationModel.fromJson(_body(response.data)));
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Either<Failure, ScheduledNotificationModel>> updateScheduledNotification(int id, Map<String, dynamic> body) async {
    try {
      final response = await apiService!.patchData(endPoint: EndPoints.scheduledNotification(id), sendToken: true, data: body);
      return right(ScheduledNotificationModel.fromJson(_body(response.data)));
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Either<Failure, bool>> cancelScheduledNotification(int id) async {
    try {
      await apiService!.postData(endPoint: EndPoints.cancelScheduledNotification(id), sendToken: true);
      return right(true);
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Either<Failure, UploadedImage>> uploadImage(String filePath) async {
    try {
      final form = FormData.fromMap({"file": await MultipartFile.fromFile(filePath)});
      final response = await apiService!.postDataWithImage(
        endPoint: EndPoints.scheduledNotificationImage,
        sendToken: true,
        data: form,
      );
      final d = _body(response.data);
      final path = d['path']?.toString();
      if (path == null || path.isEmpty) return left(ServerFailure("unexpectedError"));
      return right(UploadedImage(path: path, url: d['url']?.toString()));
    } catch (e) {
      return _fail(e);
    }
  }

  static String _localized(dynamic name) {
    if (name is Map) {
      final lang = CacheKeysManger.getUserLanguageFromCache();
      final first = lang == 'en' ? name['en'] : name['ar'];
      return (first ?? name['ar'] ?? name['en'] ?? '').toString();
    }
    return name?.toString() ?? '';
  }

  static PickOption _customer(Map u) {
    final id = int.tryParse('${u["id"]}') ?? 0;
    final name = (u["fullName"] ?? '').toString().trim();
    return PickOption(
      id: id,
      label: name.isEmpty ? '#$id' : name,
      subtitle: u["phoneNumber"]?.toString() ?? u["email"]?.toString(),
    );
  }

  @override
  Future<List<PickOption>> searchCustomers(String keyword) async {
    final response = await apiService!.get(
      endPoint: EndPoints.users,
      sendToken: true,
      query: {"role": "user", "page": 1, "limit": 20, if (keyword.isNotEmpty) "keyword": keyword},
    );
    final items = (response.data?["data"]?["items"] as List?) ?? const [];
    return [for (final u in items) if (u is Map && u["id"] != null) _customer(u)];
  }

  @override
  Future<PickOption> customerById(int id) async {
    try {
      final response = await apiService!.get(endPoint: EndPoints.userById(id), sendToken: true);
      final u = response.data?["data"];
      if (u is Map) return _customer(u);
    } catch (_) {}
    return PickOption(id: id, label: '#$id');
  }

  @override
  Future<List<PickOption>> searchProducts(String keyword) async {
    final response = await apiService!.get(
      endPoint: EndPoints.products,
      sendToken: true,
      query: {"page": 1, "limit": 20, if (keyword.isNotEmpty) "name": keyword},
    );
    final items = (response.data?["data"]?["items"] as List?) ?? const [];
    return [
      for (final p in items)
        if (p is Map && p["id"] != null)
          PickOption(id: int.tryParse('${p["id"]}') ?? 0, label: _localized(p["name"])),
    ];
  }

  @override
  Future<List<NotificationCategoryOption>> getCategories() async {
    final response = await apiService!.get(endPoint: EndPoints.categories, sendToken: true);
    final raw = response.data?["data"];
    final items = raw is List ? raw : (raw is Map ? (raw["items"] as List? ?? const []) : const []);
    return [
      for (final c in items)
        if (c is Map && c["id"] != null)
          NotificationCategoryOption(
            id: int.tryParse('${c["id"]}') ?? 0,
            name: _localized(c["name"]),
            subCategories: [
              for (final s in (c["subCategories"] as List? ?? const []))
                if (s is Map && s["id"] != null)
                  NotificationCategoryOption(id: int.tryParse('${s["id"]}') ?? 0, name: _localized(s["name"])),
            ],
          ),
    ];
  }
}
