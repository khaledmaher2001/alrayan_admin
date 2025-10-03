import 'package:alrayan_admin/features/categories/presentation/view/categories_view.dart';
import 'package:alrayan_admin/features/home/presentation/views/home_view.dart';
import 'package:alrayan_admin/features/main_layout/presentation/views/widgets/bottom_nav_bar.dart';
import 'package:alrayan_admin/features/main_layout/view_model/change_nav_bar_status/change_nav_bar_status_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view/orders_view.dart';
import 'package:alrayan_admin/features/products/presentation/views/products_view.dart';
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
    CategoriesView(),
    OrdersView(),
    ProductsView(),
    SizedBox(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BlocBuilder<ChangeNavBarStatusCubit, ChangeNavBarStatusState>(
        builder: (context, state) {
          return AnnotatedRegion(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarColor: Colors.white,
              statusBarBrightness: Brightness.dark,
            ),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(child: screens[ChangeNavBarStatusCubit.get(context).currentIndex]),
                    const BottomNavBar(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    // bottomNavigationBar: const ,
  }
}
