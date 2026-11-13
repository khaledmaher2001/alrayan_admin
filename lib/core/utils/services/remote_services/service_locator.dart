import 'package:alrayan_admin/features/orders/data/repo/order_finance_repo.dart';
import 'package:alrayan_admin/features/ads/data/repo/ads/ads_repo_impl.dart';
import 'package:alrayan_admin/features/all_users/data/repo/all_users_repo_impl.dart';
import 'package:alrayan_admin/features/auth/data/repo/auth_repo_impl.dart';
import 'package:alrayan_admin/features/categories/data/repo/categories_repo_impl.dart';
import 'package:alrayan_admin/features/coupons/data/repo/coupons_repo_impl.dart';
import 'package:alrayan_admin/features/delivery/data/repo/delivery_repo_impl.dart';
import 'package:alrayan_admin/features/delivery_settings/data/repo/delivery_settings_repo_impl.dart';
import 'package:alrayan_admin/features/home/data/repo/home_repo_impl.dart';
import 'package:alrayan_admin/features/loyalty_settings/data/repo/loyalty_settings_repo_impl.dart';
import 'package:alrayan_admin/features/lucky_wheel/data/repo/lucky_wheel_repo_impl.dart';
import 'package:alrayan_admin/features/orders/data/repo/orders_repo_impl.dart';
import 'package:alrayan_admin/features/orders/data/services/orders_socket_service.dart';
import 'package:alrayan_admin/features/products/data/repo/products_repo_impl.dart';
import 'package:alrayan_admin/features/scheduled_notifications/data/repo/scheduled_notifications_repo_impl.dart';
import 'package:alrayan_admin/features/profile/data/repo/profile_repo/profile_repo_impl.dart';
import 'package:alrayan_admin/features/top_users/data/repo/top_users_repo_impl.dart';
import 'package:alrayan_admin/features/zones/data/repo/zones_repo_impl.dart';
import 'package:dio/dio.dart';
import 'package:alrayan_admin/features/notifications/data/repo/notifications_repo_impl.dart';
import 'package:get_it/get_it.dart';
import '../../../../features/reviews/data/repo/reviews_repo_impl.dart';
import '../../../../features/top_products/data/repo/top_products_repo_impl.dart';
import '../file_picker/file_picker_service.dart';
import '../file_picker/i_file_picker_service.dart';
import 'api_service.dart';
//dependency Injection

final getIt = GetIt.instance;

void setup() {
  getIt.registerLazySingleton<IFilePickerService>(() => FilePickerService());

  // Without timeouts one dropped request on a weak network never returns,
  // leaving its screen stuck on loading forever.
  getIt.registerSingleton<ApiService>(ApiService(Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 30),
  ))));
  getIt.registerSingleton<AuthRepoImpl>(AuthRepoImpl(getIt.get<ApiService>()));
  getIt.registerLazySingleton<CategoriesRepoImpl>(
    () => CategoriesRepoImpl(getIt.get<ApiService>()),
  );
  getIt.registerLazySingleton<ProductsRepoImpl>(
    () => ProductsRepoImpl(getIt.get<ApiService>()),
  );
  getIt.registerLazySingleton<NotificationsRepoImpl>(
    () => NotificationsRepoImpl(getIt.get<ApiService>()),
  );
  getIt.registerLazySingleton<OrderFinanceRepo>(() => OrderFinanceRepo(getIt.get<ApiService>()));
  getIt.registerLazySingleton<OrdersRepoImpl>(
    () => OrdersRepoImpl(getIt.get<ApiService>()),
  );
  getIt.registerLazySingleton<OrdersSocketService>(
    () => OrdersSocketService(),
  );
  getIt.registerLazySingleton<HomeRepoImpl>(
    () => HomeRepoImpl(getIt.get<ApiService>()),
  );
  getIt.registerLazySingleton<ProfileRepoImpl>(
    () => ProfileRepoImpl(getIt.get<ApiService>()),
  );
  getIt.registerLazySingleton<ZonesRepoImpl>(
    () => ZonesRepoImpl(getIt.get<ApiService>()),
  );
  getIt.registerLazySingleton<AllUsersRepoImpl>(
    () => AllUsersRepoImpl(getIt.get<ApiService>()),
  );
  getIt.registerLazySingleton<CouponsRepoImpl>(
    () => CouponsRepoImpl(getIt.get<ApiService>()),
  );
  getIt.registerLazySingleton<LuckyWheelRepoImpl>(
    () => LuckyWheelRepoImpl(getIt.get<ApiService>()),
  );
  getIt.registerLazySingleton<AdsRepoImpl>(
    () => AdsRepoImpl(getIt.get<ApiService>()),
  );
  getIt.registerLazySingleton<ReviewRepoImpl>(
    () => ReviewRepoImpl(getIt.get<ApiService>()),
  );
  getIt.registerLazySingleton<TopUsersRepoImpl>(
    () => TopUsersRepoImpl(getIt.get<ApiService>()),
  );
  getIt.registerLazySingleton<TopProductsRepoImpl>(
    () => TopProductsRepoImpl(getIt.get<ApiService>()),
  );
  getIt.registerLazySingleton<LoyaltySettingsRepoImpl>(
    () => LoyaltySettingsRepoImpl(getIt.get<ApiService>()),
  );
  getIt.registerLazySingleton<DeliveryRepoImpl>(
    () => DeliveryRepoImpl(getIt.get<ApiService>()),
  );
  getIt.registerLazySingleton<DeliverySettingsRepoImpl>(
    () => DeliverySettingsRepoImpl(getIt.get<ApiService>()),
  );
  getIt.registerLazySingleton<ScheduledNotificationsRepoImpl>(
    () => ScheduledNotificationsRepoImpl(getIt.get<ApiService>()),
  );
}
