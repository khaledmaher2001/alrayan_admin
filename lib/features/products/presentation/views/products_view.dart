import 'package:easy_localization/easy_localization.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/product_details/presentation/views/products_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alrayan_admin/features/products/presentation/views/widgets/products_view_body.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: const ProductsViewBody(),
        // Labelled add button (the list keeps 96dp of space under the last row).
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            NavigationUtils.navigateTo(context: context, destinationScreen: ProductsDetailsView());
          },
          backgroundColor: AppColors.primaryColor,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text("prd_add".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
        ),
      ),
    );
  }
}
