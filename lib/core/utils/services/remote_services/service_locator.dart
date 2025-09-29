import 'package:alrayan_admin/features/auth/data/repo/auth_repo_impl.dart';
import 'package:alrayan_admin/features/categories/data/repo/categories_repo_impl.dart';
import 'package:alrayan_admin/features/orders/data/repo/orders_repo_impl.dart';
import 'package:alrayan_admin/features/products/data/repo/products_repo_impl.dart';
import 'package:dio/dio.dart';
import 'package:alrayan_admin/features/notifications/data/repo/notifications_repo_impl.dart';
import 'package:get_it/get_it.dart';
import 'api_service.dart';
//dependency Injection

final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<ApiService>(ApiService(Dio()));
  getIt.registerSingleton<AuthRepoImpl>(AuthRepoImpl(getIt.get<ApiService>()));
  getIt.registerLazySingleton<CategoriesRepoImpl>(() => CategoriesRepoImpl(getIt.get<ApiService>()));
  getIt.registerLazySingleton<ProductsRepoImpl>(() => ProductsRepoImpl(getIt.get<ApiService>()));
  getIt.registerLazySingleton<NotificationsRepoImpl>(() => NotificationsRepoImpl(getIt.get<ApiService>()));
  getIt.registerLazySingleton<OrdersRepoImpl>(() => OrdersRepoImpl(getIt.get<ApiService>()));
}
