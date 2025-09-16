import 'dart:async';
import 'package:alrayan_admin/core/shared_widgets/default_text_form_field.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/change_category/change_category_cubit.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/get_products/get_products_cubit.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/get_products/get_products_states.dart';
import 'package:alrayan_admin/features/products/presentation/views/widgets/categories_list_item.dart';
import 'package:alrayan_admin/features/products/presentation/views/widgets/filter_products_item.dart';
import 'package:alrayan_admin/features/products/presentation/views/widgets/main_product_item.dart';
import 'package:alrayan_admin/features/products/presentation/views/widgets/subCategories_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../../core/utils/constants.dart';

class ProductsViewBody extends StatefulWidget {
  const ProductsViewBody({super.key});

  @override
  State<ProductsViewBody> createState() => _ProductsViewBodyState();
}

class _ProductsViewBodyState extends State<ProductsViewBody> {
  TextEditingController search = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool isLoading = false;

  Future<void> pagination() async {
    final cubit = context.read<GetProductsCubit>();
    if (cubit.page < cubit.productsModel!.data!.metadata!.totalPages! &&
        scrollController.position.maxScrollExtent == scrollController.position.pixels &&
        !isLoading) {
      isLoading = true;
      setState(() {
        cubit.page++;
      });
      await cubit
          .getProducts(
            withLoading: false,
            categoryId: context.read<ChangeCategoryCubit>().mainCategoryId,
            subCategoryId: context.read<ChangeCategoryCubit>().subCategoryId,
            name: search.text.trim(),
          )
          .then((value) {
            setState(() {
              isLoading = false;
            });
          });
    }
  }

  @override
  void initState() {
    scrollController.addListener(pagination);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    scrollController.dispose();
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: AppConstants.height15(context)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.width15(context)),
            child: DefaultTextFormField(
              textInputType: TextInputType.text,
              controller: search,
              hintText: "ابحث عن المنتج...",
              onFilledSubmit: (value) {
                print(value.trim());
                context.read<GetProductsCubit>().getProducts(
                  categoryId: context.read<ChangeCategoryCubit>().mainCategoryId,
                  subCategoryId: context.read<ChangeCategoryCubit>().subCategoryId,
                  name: value.trim(),
                );
              },
            ),
          ),
          SizedBox(height: AppConstants.height15(context)),
          // CategoriesListItem(),
          FilterProductsItem(),
          SizedBox(height: AppConstants.height10(context)),
          // SubCategoriesListItem(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<GetProductsCubit>().getProducts(
                  categoryId: context.read<ChangeCategoryCubit>().mainCategoryId,
                  subCategoryId: context.read<ChangeCategoryCubit>().subCategoryId,
                  name: search.text.trim(),
                );
              },
              child: BlocBuilder<GetProductsCubit, GetProductsStates>(
                builder: (context, state) {
                  if (state is GetProductsSuccessState) {
                    return GridView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(
                        vertical: AppConstants.height10(context),
                        horizontal: AppConstants.width15(context),
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppConstants.width10(context),
                        mainAxisSpacing: AppConstants.height10(context),
                        childAspectRatio: .68,
                      ),
                      itemCount: context.read<GetProductsCubit>().productsList.length + (isLoading ? 2 : 0),
                      itemBuilder: (context, index) {
                        if (index >= context.read<GetProductsCubit>().productsList.length) {
                          return const _LoadingTile();
                        }
                        return MainProductItem(productDetails: context.read<GetProductsCubit>().productsList[index]);
                      },
                    );
                  }
                  return Skeletonizer(
                    enabled: true,
                    child: GridView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(
                        vertical: AppConstants.height10(context),
                        horizontal: AppConstants.width20(context),
                      ),
                      itemCount: 6,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppConstants.width10(context),
                        mainAxisSpacing: AppConstants.height10(context),
                        childAspectRatio: .71,
                      ),
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(height: 150, width: double.infinity, color: Colors.grey[300]),
                              SizedBox(height: AppConstants.height10(context)),
                              Container(height: 20, width: 100, color: Colors.grey[300]),
                              SizedBox(height: AppConstants.height10(context)),
                              Container(height: 15, width: 60, color: Colors.grey[300]),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          if (isLoading) ...[
            SizedBox(height: AppConstants.height10(context)),
            Center(
              child: SizedBox(
                height: AppConstants.height30(context),
                width: AppConstants.height30(context),
                child: const CircularProgressIndicator(),
              ),
            ),
            SizedBox(height: AppConstants.height10(context)),
          ],
        ],
      ),
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}
