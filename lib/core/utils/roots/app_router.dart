import 'package:go_router/go_router.dart';
import 'package:alrayan_admin/features/auth/presentation/view/forget_password_view.dart';
import 'package:alrayan_admin/features/auth/presentation/view/login_view.dart';
import '../../../features/auth/presentation/view/otp_view.dart';
import '../../../features/auth/presentation/view/register_view.dart';
import '../../../features/main_layout/presentation/views/main_layout_view.dart';
import '../../../features/splash/presentation/views/splash_view.dart';

abstract class AppRouter {
  static final router = GoRouter(routes: [
    //Splash Roots
    GoRoute(
      path: "/",
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: "/mainLayoutView",
      builder: (context, state) => MainLayoutView(),
    ),
    //  Login Routes
    GoRoute(
      path: "/loginView",
      builder: (context, state) => const LoginView(),
    ),
    //  Register Routes
    GoRoute(
      path: "/registerView",
      builder: (context, state) =>  RegisterView(),
    ),
    //  Register Routes
    GoRoute(
      path: "/forgetPasswordView",
      builder: (context, state) => const ForgetPasswordView(),
    ),
  ]);
}
