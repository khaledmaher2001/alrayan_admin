import 'dart:async';
import 'package:alrayan_admin/bloc_observer.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_keys.dart';
import 'package:alrayan_admin/features/auth/data/repo/auth_repo_impl.dart';
import 'package:alrayan_admin/features/categories/data/repo/categories_repo_impl.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_categories/get_categories_cubit.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_sub_categories/get_sub_categories_cubit.dart';
import 'package:alrayan_admin/features/notifications/data/repo/notifications_repo_impl.dart';
import 'package:alrayan_admin/features/products/data/repo/products_repo_impl.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/change_category/change_category_cubit.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/get_products/get_products_cubit.dart';
import 'package:alrayan_admin/features/profile/data/repo/profile_repo/profile_repo_impl.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/get_profile/get_profile_cubit.dart';
import 'package:alrayan_admin/features/zones/data/repo/zones_repo_impl.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/get_zones/get_zones_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/user_login/login_cubit.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/user_register/register_cubit.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'core/utils/roots/app_router.dart';
import 'core/utils/services/local_services/cache_helper.dart';
import 'core/utils/services/remote_services/service_locator.dart';
import 'core/utils/theme/app_theme.dart';
import 'features/auth/presentation/view_model/forget_password/forget_password_cubit.dart';
import 'features/auth/presentation/view_model/get_settings/get_settings_cubit.dart';
import 'features/auth/presentation/view_model/reset_password/reset_password_cubit.dart';
import 'features/main_layout/view_model/change_nav_bar_status/change_nav_bar_status_cubit.dart';
import 'features/notifications/presenatation/view_model/get_notifications/get_notifications_cubit.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  Bloc.observer = MyBlocObserver();

  await CacheHelper.init();
  setup();
  OneSignal.initialize("b0493d6a-f68a-48a8-a5c5-a8659369fc5a");
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.Notifications.requestPermission(true);
  print("Token : ${CacheKeysManger.tokenStatus()}");
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale("en"), Locale("ar")],
      saveLocale: true,
      startLocale: const Locale("ar"),
      path: "lib/core/language",
      // <-- change the path of the translation files
      child: const AlRayanAdmin(),
    ),
  );
}

class AlRayanAdmin extends StatefulWidget {
  const AlRayanAdmin({super.key});

  @override
  State<AlRayanAdmin> createState() => _AlRayanAdminState();
}

class _AlRayanAdminState extends State<AlRayanAdmin> {
  late StreamSubscription<InternetConnectionStatus> subscription;

  @override
  void initState() {
    // subscription = InternetConnectionChecker().onStatusChange.listen(
    //   (InternetConnectionStatus status) {
    //     switch (status) {
    //       case InternetConnectionStatus.connected:
    //         setState(() {
    //           AppConstants.hasInternet = true;
    //         });
    //         break;
    //       case InternetConnectionStatus.disconnected:
    //         // ignore: avoid_print
    //         setState(() {
    //           AppConstants.hasInternet = false;
    //         });
    //         break;
    //     }
    //   },
    // );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ChangeNavBarStatusCubit()),
        BlocProvider(create: (context) => LoginCubit(getIt.get<AuthRepoImpl>())),
        BlocProvider(create: (context) => RegisterCubit(getIt.get<AuthRepoImpl>())),
        BlocProvider(create: (context) => ForgetPasswordCubit(getIt.get<AuthRepoImpl>())),
        BlocProvider(create: (context) => ResetPasswordCubit(getIt.get<AuthRepoImpl>())),

        BlocProvider(create: (context) => GetSettingsCubit(getIt.get<AuthRepoImpl>())..getSettings()),
        BlocProvider(
          create: (context) => GetNotificationsCubit(getIt.get<NotificationsRepoImpl>())..getNotifications(),
        ),
        BlocProvider(create: (context) => GetCategoriesCubit(getIt.get<CategoriesRepoImpl>())..getCategories()),
        BlocProvider(create: (context) => GetSubCategoriesCubit(getIt<CategoriesRepoImpl>())),
        BlocProvider(create: (context) => ChangeCategoryCubit()),
        BlocProvider(create: (context) => GetProductsCubit(getIt.get<ProductsRepoImpl>())..getProducts()),
        BlocProvider(create: (context) => GetProfileCubit(getIt.get<ProfileRepoImpl>())..getProfile()),
        BlocProvider(create: (context) => GetZonesCubit(getIt.get<ZonesRepoImpl>())..getZones(withLoading: true)),
      ],
      child: MaterialApp.router(
        title: "الريان أدمن",
        theme: themeDataLight,
        builder: (context, child) {
          return MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), child: child!);
        },
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
      ),
    );
  }
}
