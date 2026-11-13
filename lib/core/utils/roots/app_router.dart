import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:alrayan_admin/features/auth/presentation/view/forget_password_view.dart';
import 'package:alrayan_admin/features/auth/presentation/view/login_view.dart';
import '../../../features/main_layout/presentation/views/main_layout_view.dart';
import '../../../features/onboarding/presentation/views/onboarding_view.dart';
import '../../../features/splash/presentation/views/splash_view.dart';

abstract class AppRouter {
  /// The router's root navigator, so code outside the widget tree (a push
  /// notification tap) can push screens.
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(navigatorKey: rootNavigatorKey, routes: [
    //Splash Roots
    GoRoute(
      path: "/",
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: "/mainLayoutView",
      builder: (context, state) => MainLayoutView(),
    ),
    //  Onboarding Routes
    GoRoute(
      path: "/onBoardingView",
      builder: (context, state) => const OnBoardingView(),
    ),
    //  Login Routes
    GoRoute(
      path: "/loginView",
      builder: (context, state) => const LoginView(),
    ),
    //  Register Routes
    //  Register Routes
    GoRoute(
      path: "/forgetPasswordView",
      builder: (context, state) => const ForgetPasswordView(),
    ),
  ]);
}
