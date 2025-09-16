import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/create_product/create_product_cubit.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/delete_product/delete_product_cubit.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/delete_product_attachments/delete_product_attachments_cubit.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/edit_product/edit_product_cubit.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/get_product_details/get_product_details_cubit.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/select_product_photos/select_product_photos_cubit.dart';
import 'package:alrayan_admin/features/product_details/presentation/views/widgets/products_details_view_body.dart';
import 'package:alrayan_admin/features/products/data/models/products_model.dart';
import 'package:alrayan_admin/features/products/data/repo/products_repo_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductsDetailsView extends StatelessWidget {
  const ProductsDetailsView({super.key, this.productData});

  final Items? productData;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SelectProductPhotosCubit()),
          BlocProvider(create: (context) => GetProductsDetailsCubit(getIt<ProductsRepoImpl>())),
          BlocProvider(create: (context) => CreateProductCubit(getIt<ProductsRepoImpl>())),
          BlocProvider(create: (context) => EditProductCubit(getIt<ProductsRepoImpl>())),
          BlocProvider(create: (context) => DeleteProductCubit(getIt<ProductsRepoImpl>())),
          BlocProvider(create: (context) => DeleteProductAttachmentsCubit(getIt<ProductsRepoImpl>())),
        ],
        child: Scaffold(body: ProductsDetailsViewBody(productData: productData)),
      ),
    );
  }
}
