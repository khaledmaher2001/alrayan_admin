import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/shared_widgets/details_loader_scaffold.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/get_product_details/get_product_details_cubit.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/get_product_details/get_product_details_states.dart';
import 'package:alrayan_admin/features/product_details/presentation/views/products_details_view.dart';
import 'package:alrayan_admin/features/products/data/repo/products_repo_impl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Opens a product's details/edit screen when only its id is known (push
/// notification): fetches `GET products/{id}`, then shows [ProductsDetailsView].
class ProductDetailsLoaderView extends StatelessWidget {
  const ProductDetailsLoaderView({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetProductsDetailsCubit(getIt<ProductsRepoImpl>())..getProductDetails(productId: productId),
      child: BlocBuilder<GetProductsDetailsCubit, GetProductsDetailsStates>(
        builder: (context, state) {
          if (state is GetProductsDetailsSuccessState) {
            return ProductsDetailsView(productData: state.productDetails);
          }
          return DetailsLoaderScaffold(
            title: "s_product_details".tr(),
            body: state is GetProductsDetailsErrorState
                ? LoadErrorView(
                    message: state.error ?? "notif_load_failed".tr(),
                    onRetry: () => context.read<GetProductsDetailsCubit>().getProductDetails(productId: productId),
                  )
                : const CustomLoadingItem(),
          );
        },
      ),
    );
  }
}
