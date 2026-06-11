import 'dart:async';
import 'dart:io';

import 'package:alrayan_admin/bloc_observer.dart';
import 'package:alrayan_admin/core/shared_cubit/file_picker_cubit/file_picker_cubit.dart';
import 'package:alrayan_admin/core/shared_widgets/overlay_controller.dart';
import 'package:alrayan_admin/core/shared_widgets/overlay_widget.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_keys.dart';
import 'package:alrayan_admin/features/ads/data/repo/ads/ads_repo_impl.dart';
import 'package:alrayan_admin/features/ads/presentation/view_models/ads_assets/ads_assets_cubit.dart';
import 'package:alrayan_admin/features/ads/presentation/view_models/offer_banner_cubit/offer_banner_cubit.dart';
import 'package:alrayan_admin/features/all_users/data/repo/all_users_repo_impl.dart';
import 'package:alrayan_admin/features/all_users/presentation/view_models/get_all_users/get_all_users_cubit.dart';
import 'package:alrayan_admin/features/auth/data/repo/auth_repo_impl.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/update_settings/update_settings_cubit.dart';
import 'package:alrayan_admin/features/categories/data/repo/categories_repo_impl.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_categories/get_categories_cubit.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_sub_categories/get_sub_categories_cubit.dart';
import 'package:alrayan_admin/features/coupons/data/repo/coupons_repo_impl.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/view_model/create_coupon_assets/create_coupon_assets_cubit.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/view_model/get_coupons/get_coupons_cubit.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_home_statistics/get_home_statistics_cubit.dart';
import 'package:alrayan_admin/features/lucky_wheel/data/repo/lucky_wheel_repo_impl.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/get_lucky_wheel_items/get_lucky_wheel_items_cubit.dart';
import 'package:alrayan_admin/features/main_layout/view_model/change_nav_bar_status/change_nav_bar_status_cubit.dart';
import 'package:alrayan_admin/features/notifications/data/repo/notifications_repo_impl.dart';
import 'package:alrayan_admin/features/notifications/presenatation/view_model/get_notifications/get_notifications_cubit.dart';
import 'package:alrayan_admin/features/products/data/repo/products_repo_impl.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/change_category/change_category_cubit.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/get_products/get_products_cubit.dart';
import 'package:alrayan_admin/features/profile/data/repo/profile_repo/profile_repo_impl.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/get_profile/get_profile_cubit.dart';
import 'package:alrayan_admin/features/reviews/data/repo/reviews_repo_impl.dart';
import 'package:alrayan_admin/features/reviews/presentation/view_model/get_reviews/get_reviews_cubit.dart';
import 'package:alrayan_admin/features/reviews/presentation/view_model/get_reviews_summery/get_reviews_summery_cubit.dart';
import 'package:alrayan_admin/features/top_products/data/repo/top_products_repo_impl.dart';
import 'package:alrayan_admin/features/top_products/presentation/view_models/get_top_products_cubit/get_top_products_cubit.dart';
import 'package:alrayan_admin/features/top_users/data/repo/top_users_repo_impl.dart';
import 'package:alrayan_admin/features/top_users/presentation/view_models/get_top_users_cubit/get_top_users_cubit.dart';
import 'package:alrayan_admin/features/zones/data/repo/zones_repo_impl.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/get_zones/get_zones_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'core/utils/roots/app_router.dart';
import 'core/utils/services/local_services/cache_helper.dart';
import 'core/utils/services/remote_services/service_locator.dart';
import 'core/utils/theme/app_theme.dart';
import 'features/auth/presentation/view_model/forget_password/forget_password_cubit.dart';
import 'features/auth/presentation/view_model/get_settings/get_settings_cubit.dart';
import 'features/auth/presentation/view_model/reset_password/reset_password_cubit.dart';
import 'features/auth/presentation/view_model/user_login/login_cubit.dart';
import 'features/auth/presentation/view_model/user_register/register_cubit.dart';
import 'features/home/data/repo/home_repo_impl.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _androidNotificationChannel =
AndroidNotificationChannel(
  'high_importance_channel_v1',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
  playSound: true,
  sound: RawResourceAndroidNotificationSound('notification_sound'),
);

Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_androidNotificationChannel);
}

Future<void> showLocalNotificationWithSound({
  required String title,
  required String body,
}) async {
  const AndroidNotificationDetails androidDetails =
  AndroidNotificationDetails(
    'high_importance_channel_v1',
    'High Importance Notifications',
    channelDescription: 'This channel is used for important notifications.',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notification_sound'),
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    sound: 'notification_sound.aiff',
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    notificationDetails,
  );
}

Future<void> setupOneSignalForegroundNotifications() async {
  OneSignal.Notifications.addForegroundWillDisplayListener((event) async {
    event.preventDefault();

    final notification = event.notification;
    final title = notification.title ?? 'الريان - أدمن';
    final body = notification.body ?? '';

    await showLocalNotificationWithSound(
      title: title,
      body: body,
    );
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  Bloc.observer = MyBlocObserver();

  await CacheHelper.init();
  setup();

  OneSignal.initialize("b0493d6a-f68a-48a8-a5c5-a8659369fc5a");
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  await OneSignal.Notifications.requestPermission(true);

  await initializeLocalNotifications();
  await setupOneSignalForegroundNotifications();

  print("Token : ${CacheKeysManger.tokenStatus()}");

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale("en"), Locale("ar")],
      saveLocale: true,
      startLocale: const Locale("ar"),
      path: "lib/core/language",
      child: const AlRayanAdmin(),
    ),
  );
}

class AlRayanAdmin extends StatelessWidget {
  const AlRayanAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ChangeNavBarStatusCubit()),
        BlocProvider(create: (context) => AdsAssetsCubit()),
        BlocProvider(create: (context) => FilePickerCubit(getIt())),
        BlocProvider(create: (context) => CreateCouponAssetsCubit()),
        BlocProvider(create: (context) => LoginCubit(getIt.get<AuthRepoImpl>())),
        BlocProvider(create: (context) => GetAllUsersCubit(getIt.get<AllUsersRepoImpl>())),
        BlocProvider(create: (context) => RegisterCubit(getIt.get<AuthRepoImpl>())),
        BlocProvider(create: (context) => ForgetPasswordCubit(getIt.get<AuthRepoImpl>())),
        BlocProvider(create: (context) => ResetPasswordCubit(getIt.get<AuthRepoImpl>())),
        BlocProvider(create: (context) => GetTopUsersCubit(getIt<TopUsersRepoImpl>())),
        BlocProvider(create: (context) => GetTopProductsCubit(getIt<TopProductsRepoImpl>())),
        BlocProvider(create: (context) => GetReviewsCubit(getIt<ReviewRepoImpl>())),
        BlocProvider(create: (context) => GetReviewsSummeryCubit(getIt<ReviewRepoImpl>())),
        BlocProvider(create: (context) => GetSettingsCubit(getIt.get<AuthRepoImpl>())),
        BlocProvider(create: (context) => UpdateSettingsCubit(getIt.get<AuthRepoImpl>())),
        BlocProvider(create: (context) => GetNotificationsCubit(getIt.get<NotificationsRepoImpl>())),
        BlocProvider(create: (context) => GetCategoriesCubit(getIt.get<CategoriesRepoImpl>())..getCategories()),
        BlocProvider(create: (context) => GetSubCategoriesCubit(getIt<CategoriesRepoImpl>())),
        BlocProvider(create: (context) => ChangeCategoryCubit()),
        BlocProvider(create: (context) => GetProductsCubit(getIt.get<ProductsRepoImpl>())),
        BlocProvider(create: (context) => OfferBannerCubit(getIt.get<AdsRepoImpl>())),
        BlocProvider(create: (context) => GetProfileCubit(getIt.get<ProfileRepoImpl>())),
        BlocProvider(create: (context) => GetCouponsCubit(getIt.get<CouponsRepoImpl>())..getCoupons()),
        BlocProvider(create: (context) => GetLuckyWheelItemsCubit(getIt.get<LuckyWheelRepoImpl>())),
        BlocProvider(create: (context) => GetZonesCubit(getIt.get<ZonesRepoImpl>())),
        BlocProvider(create: (context) => GetHomeStatisticsCubit(getIt.get<HomeRepoImpl>())),
      ],
      child: const _AdminAppBootstrap(),
    );
  }
}

class _AdminAppBootstrap extends StatefulWidget {
  const _AdminAppBootstrap();

  @override
  State<_AdminAppBootstrap> createState() => _AdminAppBootstrapState();
}

class _AdminAppBootstrapState extends State<_AdminAppBootstrap> {
  StreamSubscription<InternetConnectionStatus>? _subscription;
  bool _isRefreshing = false;
  bool _didInitialLoad = false;

  @override
  void initState() {
    super.initState();
    _initInternetHandling();
  }

  Future<void> _initInternetHandling() async {
    await _checkConnectivityAndApply(forceRefreshWhenOnline: true);

    _subscription = InternetConnectionChecker().onStatusChange.listen((_) async {
      if (!mounted) return;
      await _checkConnectivityAndApply(forceRefreshWhenOnline: false);
    });
  }

  Future<bool> _hasUsableInternet() async {
    final checker = InternetConnectionChecker();

    final hasGeneralConnection = await checker.hasConnection;
    if (!hasGeneralConnection) return false;

    try {
      final result = await InternetAddress.lookup(
        'api.elrayan.acwad.tech',
      ).timeout(const Duration(seconds: 3));

      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkConnectivityAndApply({
    required bool forceRefreshWhenOnline,
  }) async {
    final wasOffline = InternetOverlayController.isOffline.value;
    final hasInternet = await _hasUsableInternet();

    if (!mounted) return;

    if (hasInternet) {
      InternetOverlayController.hide();

      final shouldRefresh =
          forceRefreshWhenOnline || !_didInitialLoad || wasOffline;

      if (shouldRefresh) {
        await _refreshAppData();
      }
    } else {
      InternetOverlayController.show();
    }
  }

  Future<void> _refreshAppData() async {
    if (_isRefreshing) return;

    _isRefreshing = true;

    try {
      _didInitialLoad = true;

      context.read<GetAllUsersCubit>().getAllUsers(
        data: {
          'page': 1,
          'limit': 12,
        },
      );
      context.read<GetTopUsersCubit>().getTopUsers();
      context.read<GetTopProductsCubit>().getTopProducts();
      context.read<GetReviewsCubit>().getReviews(page: 1);
      context.read<GetReviewsSummeryCubit>().getReviewsSummery();
      context.read<GetSettingsCubit>().getSettings();
      context.read<GetNotificationsCubit>().getNotifications();
      context.read<GetCategoriesCubit>().getCategories();
      context.read<GetProductsCubit>().getProducts();
      context.read<OfferBannerCubit>().fetchOfferBanners();
      context.read<GetProfileCubit>().getProfile();
      context.read<GetCouponsCubit>().getCoupons();
      context.read<GetLuckyWheelItemsCubit>().getLuckyWheelItems();
      context.read<GetZonesCubit>().getZones(withLoading: true);
      context.read<GetHomeStatisticsCubit>().getHomeStatistics();
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "الريان - أدمن",
      theme: themeDataLight,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              const NoInternetOverlay(),
            ],
          ),
        );
      },
    );
  }
}