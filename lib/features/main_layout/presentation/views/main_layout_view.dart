import 'package:alrayan_admin/core/utils/notification_navigation_handler.dart';
import 'package:alrayan_admin/features/home/presentation/views/home_view.dart';
import 'package:alrayan_admin/features/main_layout/presentation/views/more_view.dart';
import 'package:alrayan_admin/features/main_layout/presentation/views/widgets/bottom_nav_bar.dart';
import 'package:alrayan_admin/features/main_layout/view_model/change_nav_bar_status/change_nav_bar_status_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view/orders_view.dart';
import 'package:alrayan_admin/features/products/presentation/views/products_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/get_profile/get_profile_cubit.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/get_profile/get_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class MainLayoutView extends StatefulWidget {
  const MainLayoutView({super.key});

  @override
  State<MainLayoutView> createState() => _MainLayoutViewState();
}

class _MainLayoutViewState extends State<MainLayoutView> {
  List<Widget> screens = [
    HomeView(),
    OrdersView(),
    ProductsView(),
    MoreView(),
  ];

  @override
  void initState() {
    super.initState();
    // Signed in and past splash/login: open the screen of a push that was
    // tapped while the app was closed (or before login).
    WidgetsBinding.instance.addPostFrameCallback((_) => NotificationNavigationHandler.markAppReady());
  }

  @override
  void dispose() {
    NotificationNavigationHandler.markAppNotReady();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BlocBuilder<ChangeNavBarStatusCubit, ChangeNavBarStatusState>(
        builder: (context, state) {
          return AnnotatedRegion(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarColor: Colors.white,
              statusBarBrightness: Brightness.dark,
            ),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Column(
                children: [
                  Expanded(child: _guarded(context, ChangeNavBarStatusCubit.get(context).currentIndex)),
                  const BottomNavBar(),
                ],
              ),
            ),
          );
        },
      ),
    );
    // bottomNavigationBar: const ,
  }

  // Permission each tab needs (server rules); home and "More" adapt themselves.
  static const _tabPermission = {1: 'orders', 2: 'products'};

  Widget _guarded(BuildContext context, int index) {
    final profileState = context.watch<GetProfileCubit>().state;
    final profile = profileState is GetProfileSuccessState ? profileState.model.data : null;
    final needed = _tabPermission[index];
    if (needed != null && profile != null && !profile.can(needed)) return const _NoAccess();
    return screens[index];
  }
}

class _NoAccess extends StatelessWidget {
  const _NoAccess();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: AppColors.primaryColor.withValues(alpha: .08), shape: BoxShape.circle),
                child: Icon(Icons.lock_outline_rounded, size: 40, color: AppColors.primaryColor),
              ),
              const SizedBox(height: 16),
              Text('home_no_access'.tr(), textAlign: TextAlign.center, style: Styles.inter16500black(context)),
              const SizedBox(height: 8),
              Text('home_no_access_hint'.tr(), textAlign: TextAlign.center,
                  style: Styles.inter14500black(context).copyWith(color: AppColors.gray)),
            ],
          ),
        ),
      ),
    );
  }
}
